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

    ///把 "构建请求" 的工作从主线程剥离，不卡 UI。
    public let requestQueue: DispatchQueue
    
    // 解析数据不卡网络队列，解析不影响请求发送。
    public let serializationQueue: DispatchQueue

    // 事件监控器
    public let eventMonitor: GGCompositeEventMonitor

    /// 决定“请求”创建后设置时间的值。`.默认情况下是懒惰的。
    public let requestSetup: GGRequestSetup

    /// 用于该实例所创建的所有“请求”的“请求拦截器”。“请求拦截器”也可以按每个“请求”进行添加，在这种情况下，来自“会话”的拦截器将首先执行。默认值为 nil。
    public let interceptor: (any GGRequestInterceptor)?

    public let session: URLSession

    /// 该实例的“会话委托”对象，负责处理“URLSessionDelegate”方法以及“请求”交互操作。
    public let delegate: GGSessionDelegate

    let mutableState = GGProtected(GGMutableState())

    public let startRequestsImmediately: Bool

    enum GGRequestSetup {
        case lazy
        case eager
    }
    
    struct GGMutableState {
        /// Internal map between `Request`s and any `URLSessionTasks` that may be in flight for them.
        var requestTaskMap = GGRequestTaskMap()
        /// `Set` of currently active `Request`s.
        var activeRequests: Set<GGRequest> = []
        /// Completion events awaiting `URLSessionTaskMetrics`.
        var waitingCompletions: [URLSessionTask: () -> Void] = [:]
    }


    /*
     // 1. 标准模式（最常用）
     let config = URLSessionConfiguration.default

     // 2. 临时模式（不缓存、不写磁盘，用完就丢）
     let config = URLSessionConfiguration.ephemeral

     // 3. 后台后台上传/下载模式（APP退后台也能继续）
     let config = URLSessionConfiguration.background(withIdentifier: "xxx")
     */
    convenience init(configuration: URLSessionConfiguration = URLSessionConfiguration.gg.default,
                     delegate: GGSessionDelegate = GGSessionDelegate(),
                     rootQueue: DispatchQueue = DispatchQueue(label: "org.GGsession.rootQueue"),
                     requestSetup: GGRequestSetup = .lazy,
                     requestQueue: DispatchQueue? = nil,
                     serializationQueue: DispatchQueue? = nil,
                     interceptor: (any GGRequestInterceptor)? = nil,
                     eventMonitors: [any GGEventMonitor] = [GGAlamofireNotifications()]) {
        
        precondition(configuration.identifier == nil, "Alamofire does not support background URLSessionConfigurations.")

        // 为确保安全，对传入的根队列进行重新定向，除非它是主队列（我们知道主队列是安全的）。
        let serialRootQueue = (rootQueue === DispatchQueue.main) ? rootQueue : DispatchQueue(label: rootQueue.label,target: rootQueue)
        
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.underlyingQueue = serialRootQueue
        delegateQueue.name = "\(serialRootQueue.label).sessionDelegate"
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)

        self.init(session: session,
                  delegate: delegate,
                  rootQueue: serialRootQueue,
                  requestSetup: requestSetup,
                  requestQueue: requestQueue,
                  serializationQueue: serializationQueue,
                  interceptor: interceptor,
                  eventMonitors: eventMonitors)
    }
    
    init(session: URLSession,
         delegate: GGSessionDelegate,
        rootQueue: DispatchQueue = DispatchQueue(label: "org.GGsession.rootQueue"),
        startRequestsImmediately: Bool = true,
        requestSetup: GGRequestSetup = .lazy,
        requestQueue: DispatchQueue? = nil,
        serializationQueue: DispatchQueue? = nil,
        interceptor: (any GGRequestInterceptor)? = nil,
        eventMonitors: [any GGEventMonitor] = [GGAlamofireNotifications()]) {
        
        precondition(session.configuration.identifier == nil,
                     "Alamofire does not support background URLSessionConfigurations.")
        precondition(session.delegateQueue.underlyingQueue === rootQueue,
                     "Session(session:) initializer must be passed the DispatchQueue used as the delegateQueue's underlyingQueue as rootQueue.")

        self.rootQueue = rootQueue
        self.requestQueue = requestQueue ?? DispatchQueue(label: "\(rootQueue.label).requestQueue",target: rootQueue)
        self.serializationQueue = serializationQueue ?? DispatchQueue(label: "\(rootQueue.label).serializationQueue",target: rootQueue)
        self.eventMonitor = GGCompositeEventMonitor(queue: rootQueue, monitors: eventMonitors)
        self.requestSetup = requestSetup
        self.interceptor = interceptor
        self.session = session
        self.delegate = delegate
        self.startRequestsImmediately = startRequestsImmediately
    }
    
//    let session:URLSession
//    
//    let rootQueue: DispatchQueue
//
//    let startRequestsImmediately: Bool
    
    //一句话：它是一个「闭包」，用来在单个请求发出去之前，就地修改底层的 URLRequest。
    typealias GGRequestModifier = @Sendable(inout URLRequest) throws -> Void
    
    struct GGRequestConvertible:GGURLRequestConvertible {
        let url :any GGURLConvertible
        let method: GGHTTPMethod
        let parameters: GGParameters?
        let encoding: any GGParameterEncoding
        let headers: GGHTTPHeaders?
        let requestModifier: GGRequestModifier?

        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, method: method,headers: headers)
            try requestModifier?(&request)
            return try encoding.encode(request, with: parameters)
        }
    }
    
    //interceptor 一句话：控制 Alamofire 在网络恢复时 **，是否自动重试刚才失败的请求。**
    func request(_ convertible:any GGURLConvertible,
                 method:GGHTTPMethod = .get,
                 parameters: GGParameters? = nil,
                 encoding: any GGParameterEncoding = GGURLEncoding.default,
                 headers:GGHTTPHeaders? = nil,
                 interceptor: (any GGRequestInterceptor)? = nil,
                 shouldAutomaticallyResume: Bool? = nil,
                 requestModifier: GGRequestModifier? = nil
    ) -> GGDataRequest{
        
        let convertible = GGRequestConvertible(url: convertible,
                                             method: method,
                                             parameters: parameters,
                                             encoding: encoding,
                                             headers: headers,
                                             requestModifier: requestModifier)
        return self.request(convertible,interceptor: interceptor,shouldAutomaticallyResume: shouldAutomaticallyResume)
    }
    
    func request(_ convertible: any GGURLRequestConvertible,
                 interceptor: (any GGRequestInterceptor)? = nil,
                 shouldAutomaticallyResume: Bool? = nil,
    ) -> GGDataRequest {
        let request = GGDataRequest(convertible: convertible,
                                  underlyingQueue: rootQueue,
                                  serializationQueue: serializationQueue,
                                  eventMonitor: eventMonitor,
                                  interceptor: interceptor,
                                  shouldAutomaticallyResume: shouldAutomaticallyResume,
                                  delegate: self)
        
        performEagerlyIfNEcessary(request)
        return request
    }
    
    func performEagerlyIfNEcessary(_ request:GGRequest) {
        guard requestSetup == .eager else { return }
        perform(request)
    }
 
    func perform(_ request: GGRequest, forRetry isRetrying: Bool = false) {
        rootQueue.async {
            self.mutableState.write { mutableState in
                guard !request.isCancelled else { return }
                guard mutableState.activeRequests.insert(request).inserted || isRetrying else { return }
                self.requestQueue.async {
                    switch request {
                    case let r as GGDataRequest:
                        self.performDataRequest(r)
                    default:
                        fatalError("Attempted to perform unsupported Request subclass: \(type(of: request))")
                    }
                }
                
            }
        }
    }
    func performDataRequest(_ request: GGDataRequest) {
        /*
         作用：调试保护，确保代码一定跑在正确的队列
         这是GCD 调度断言
         作用："这段代码必须在 requestQueue 上执行，否则直接崩溃"
         只在DEBUG 模式生效
         防止线程错误、队列错误
         大型框架必备的安全检查
         */
        dispatchPrecondition(condition: .onQueue(requestQueue))
        performSetupOperations(for: request, convertible: request.convertible)
    }
    
    // 这是真正的请求准备 + 发送逻辑
    func performSetupOperations(for request: GGRequest,
                                convertible: any GGURLRequestConvertible,
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
    
    func adapter(for request: GGRequest) -> (any GGRequestAdapter)? {
        if let requestInterceptor = request.interceptor, let sessionInterceptor = interceptor {
            GGInterceptor(adapters: [sessionInterceptor, requestInterceptor])
        }else{
            request.interceptor ?? interceptor
        }
    }
    
    func didCreateURLRequest(_ urlRequest: URLRequest, for request: GGRequest) {
        dispatchPrecondition(condition: .onQueue(rootQueue))
        request.didCreateURLRequest(urlRequest)
        
        guard !request.isCancelled else { return }

        let task = request.task(for: urlRequest, using: session)
        mutableState.write { $0.requestTaskMap[request] = task }
        request.didCreateTask(task)
    }
}

extension GGSession: GGRequestDelegate {
    var startImmediately: Bool {
        startRequestsImmediately
    }
    
    func readyToPerform(request: GGRequest) {
        perform(request)
    }
}
