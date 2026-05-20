//
//  GGSession.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/18.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

class GGSession: @unchecked Sendable {
    
    static let `default` = GGSession()
    
    /// 统一管理整个 Alamofire 的线程资源，不乱开线程。
    public let rootQueue: DispatchQueue

    ///把 “构建请求” 的工作从主线程剥离，不卡 UI。
    public let requestQueue: DispatchQueue
    
    // 解析数据不卡网络队列，解析不影响请求发送。
    public let serializationQueue: DispatchQueue

    public let eventMonitor: CompositeEventMonitor

    public let requestSetup: RequestSetup

    public let interceptor: (any RequestInterceptor)?

    public let session: URLSession

    struct MutableState {
        /// Internal map between `Request`s and any `URLSessionTasks` that may be in flight for them.
        var requestTaskMap = RequestTaskMap()
        /// `Set` of currently active `Request`s.
        var activeRequests: Set<Request> = []
        /// Completion events awaiting `URLSessionTaskMetrics`.
        var waitingCompletions: [URLSessionTask: () -> Void] = [:]
    }

    let mutableState = Protected(MutableState())

    enum RequestSetup {
        case lazy
        case eager
    }
    
    init(rootQueue: DispatchQueue = DispatchQueue(label: "org.GGsession.rootQueue"),
        requestSetup: RequestSetup = .lazy,
        requestQueue: DispatchQueue? = nil,
        serializationQueue: DispatchQueue? = nil,
        eventMonitors: [any EventMonitor] = [AlamofireNotifications()]) {
        self.rootQueue = rootQueue
        self.requestQueue = requestQueue ?? DispatchQueue(label: "\(rootQueue.label).requestQueue",target: rootQueue)
        self.serializationQueue = serializationQueue ?? DispatchQueue(label: "\(rootQueue.label).serializationQueue",target: rootQueue)
        self.eventMonitor = CompositeEventMonitor(queue: rootQueue, monitors: eventMonitors)
        self.requestSetup = requestSetup
    }
    
//    let session:URLSession
//    
//    let rootQueue: DispatchQueue
//
//    let startRequestsImmediately: Bool
    
    //一句话：它是一个「闭包」，用来在单个请求发出去之前，就地修改底层的 URLRequest。
    typealias RequestModifier = @Sendable(inout URLRequest) throws -> Void
    
    struct RequestConvertible:URLRequestConvertible {
        let url :any URLConvertible
        let method: HTTPMethod
        let parameters: Parameters?
        let encoding: any ParameterEncoding
        let headers: HTTPHeaders?
        let requestModifier: RequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method,headers: headers)
            try requestModifier?(&request)
            return try encoding.encode(request, with: parameters)
        }
    }
    
    //interceptor 一句话：控制 Alamofire 在网络恢复时 **，是否自动重试刚才失败的请求。**
    func request(_ convertible:any URLConvertible,
                 method:HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: any ParameterEncoding = URLEncoding.default,
                 headers:HTTPHeaders? = nil,
                 interceptor: (any RequestInterceptor)? = nil,
                 shouldAutomaticallyResume: Bool? = nil,
                 requestModifier: RequestModifier? = nil
    ) -> DataRequest{
        
        let convertible = RequestConvertible(url: convertible,
                                             method: method,
                                             parameters: parameters,
                                             encoding: encoding,
                                             headers: headers,
                                             requestModifier: requestModifier)
        return self.request(convertible,interceptor: interceptor,shouldAutomaticallyResume: shouldAutomaticallyResume)
    }
    
    func request(_ convertible: any URLRequestConvertible,
                 interceptor: (any RequestInterceptor)? = nil,
                 shouldAutomaticallyResume: Bool? = nil,
    ) -> DataRequest {
        let request = DataRequest(convertible: convertible,
                                  underlyingQueue: rootQueue,
                                  serializationQueue: serializationQueue,
                                  eventMonitor: eventMonitor,
                                  interceptor: interceptor,
                                  shouldAutomaticallyResume: shouldAutomaticallyResume,
                                  delegate: self)
        
        // 是立即执行 → 马上启动请求
        performEagerlyIfNEcessary(request)
        return request
    }
    
    func performEagerlyIfNEcessary(_ request:Request) {
        guard requestSetup == .eager else { return }
        perform(request)
    }
 
    func perform(_ request: Request, forRetry isRetrying: Bool = false) {
        rootQueue.async {
            self.mutableState.write { mutableState in
                guard !request.isCancelled else { return }
                guard mutableState.activeRequests.insert(request).inserted || isRetrying else { return }
                self.requestQueue.async {
                    switch request {
                    case let r as DataRequest:
                        self.performDataRequest(r)
                    default:
                        fatalError("Attempted to perform unsupported Request subclass: \(type(of: request))")
                    }
                }
                
            }
        }
    }
    func performDataRequest(_ request: DataRequest) {
        /*
         作用：调试保护，确保代码一定跑在正确的队列
         这是GCD 调度断言
         作用：“这段代码必须在 requestQueue 上执行，否则直接崩溃”
         只在DEBUG 模式生效
         防止线程错误、队列错误
         大型框架必备的安全检查
         */
        dispatchPrecondition(condition: .onQueue(requestQueue))
        performSetupOperations(for: request, convertible: request.convertible)
    }
    
    // 这是真正的请求准备 + 发送逻辑
    func performSetupOperations(for request: Request,
                                convertible: any URLRequestConvertible,
                                shouldCreateTask: @escaping @Sendable () -> Bool = { true }) {
        dispatchPrecondition(condition: .onQueue(requestQueue))

        let initialRequet:URLRequest
        do {
            initialRequet = try convertible.asURLRequest()
            try initialRequet.validate()
        } catch {
            // 错误处理
            return
        }
        
        rootQueue.async {
            request.didCreateInitialURLRequest(initialRequet)
        }
        
        guard !request.isCancelled else { return }

        // 拦截
        guard let adapter = adapter(for: request) else {
            guard shouldCreateTask() else { return }
            rootQueue.async { self.didCreateURLRequest(initialRequet, for: request) }
            return
        }
    }
    
    func adapter(for request: Request) -> (any RequestAdapter)? {
        if let requestInterceptor = request.interceptor, let sessionInterceptor = interceptor {
            Interceptor(adapters: [sessionInterceptor, requestInterceptor])
        }else{
            request.interceptor ?? interceptor
        }
    }
    
    func didCreateURLRequest(_ urlRequest: URLRequest, for request: Request) {
        dispatchPrecondition(condition: .onQueue(rootQueue))
        request.didCreateURLRequest(urlRequest)
        
        guard !request.isCancelled else { return }

        let task = request.task(for: urlRequest, using: session)
        mutableState.write { $0.requestTaskMap[request] = task }
        request.did
    }
}

extension GGSession: RequestDelegate {
    
}
