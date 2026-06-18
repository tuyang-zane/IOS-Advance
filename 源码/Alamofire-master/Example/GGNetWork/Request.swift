//
//  Request.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

/*
 请求状态管理
 等待、执行、完成、暂停、取消、失败
 公共配置
 超时、优先级、自动恢复 (shouldAutomaticallyResume)
 请求生命周期
 开始、暂停、恢复、取消
 统一回调队列
 响应返回主线程 / 子线程
 */
class GGRequest: @unchecked Sendable {

    public let id: UUID

    public let underlyingQueue: DispatchQueue

    public let serializationQueue: DispatchQueue

    public let shouldAutomaticallyResume: Bool?
    
    private(set) weak var delegate: (any GGRequestDelegate)?

    let mutableState: GGProtected<GGMutableState>

    public var isCancelled: Bool { state == .cancelled }

    public var state: State { mutableState.read(\.state) }

    public var eventMonitor: (any GGEventMonitor)? {
        mutableState.read(\.eventMonitor)
    }

    public var interceptor: (any GGRequestInterceptor)? {
        mutableState.read(\.interceptor)
    }

    public var lastRequest: URLRequest? { requests.last }

    public var request: URLRequest? { lastRequest }

    public var requests: [URLRequest] { mutableState.read(\.requests) }

    public var response: HTTPURLResponse? {
        lastTask?.response as? HTTPURLResponse
    }
    
    public var tasks: [URLSessionTask] { mutableState.read(\.tasks) }
    public var lastTask: URLSessionTask? { tasks.last }
    public var task: URLSessionTask? { lastTask }

    public var metrics: URLSessionTaskMetrics? { lastMetrics }
    public var lastMetrics: URLSessionTaskMetrics? { allMetrics.last }
    public var allMetrics: [URLSessionTaskMetrics] { mutableState.read(\.metrics) }
    
    public internal(set) var error: GGError? {
        get { mutableState.read(\.error) }
        set { mutableState.write { $0.error = newValue } }
    }

    enum State {
        /// `刚创建好 还没发请求 还没调用 resume () 出生状态
        case initialized
        ///  活跃状态
        case resumed
        /// `暂停状态
        case suspended
        /// `彻底取消
        case cancelled
        /// `彻底取消
        case finished
        
        func canTransitionTo(_ state: State) -> Bool {
            switch (self, state) {
            case (.initialized, _):
                true
            case (_, .initialized), (.cancelled, _), (.finished, _):
                false
            case (.resumed, .cancelled), (.suspended, .cancelled), (.resumed, .suspended), (.suspended, .resumed):
                true
            case (.suspended, .suspended), (.resumed, .resumed):
                false
            case (_, .finished):
                true
            }
        }
    }
    
    init(id: UUID = UUID(),
         underlyingQueue: DispatchQueue,
         serializationQueue: DispatchQueue,
         eventMonitor: (any GGEventMonitor)?,
         interceptor: (any GGRequestInterceptor)?,
         shouldAutomaticallyResume: Bool?,
         delegate: any GGRequestDelegate) {
        self.id = id
        self.underlyingQueue = underlyingQueue
        self.serializationQueue = serializationQueue
        mutableState = GGProtected(GGMutableState(eventMonitor: eventMonitor,
                                              interceptor: interceptor))
        self.shouldAutomaticallyResume = shouldAutomaticallyResume
        self.delegate = delegate
    }
    
    struct GGMutableState {
        var state: State = .initialized
        var eventMonitor: (any GGEventMonitor)?
        var interceptor: (any GGRequestInterceptor)?
        var requests: [URLRequest] = []
        var urlRequestHandler: (queue: DispatchQueue, handler: @Sendable (URLRequest) -> Void)?
        var cURLHandler: (queue: DispatchQueue, handler: @Sendable (String) -> Void)?
        var tasks: [URLSessionTask] = []
        var responseSerializers: [@Sendable () -> Void] = []
        var responseSerializerProcessingFinished = false
        var error: GGError?
        var metrics: [URLSessionTaskMetrics] = []
    }

    func didCreateInitialURLRequest(_ request: URLRequest) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        mutableState.write{$0.requests.append(request)}
        eventMonitor?.request(self, didCreateInitialURLRequest: request)
    }
    
    func didCreateURLRequest(_ request: URLRequest) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        mutableState.read { state in
            guard let urlRequestHandler = state.urlRequestHandler else { return }
            urlRequestHandler.queue.async {
                urlRequestHandler.handler(request)
            }
        }
        
        eventMonitor?.request(self, didCreateURLRequest: request)
        
        callCURLHandlerIfNecessary()
    }
    
    func didCreateTask(_ task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        mutableState.write { mutableState in
            mutableState.tasks.append(task)
            
            switch mutableState.state {
            case .initialized, .finished:
                // Do nothing.
                break
            case .resumed:
                task.resume()
                underlyingQueue.async {
                    self.didResumeTask(task)
                }
            case .suspended:
                task.suspend()
                underlyingQueue.async {self.didSuspendTask(task)}
            case .cancelled:
                task.resume()
                task.cancel()
                underlyingQueue.async {self.didCancelTask(task)}
            }

        }
    }
    
    func didSuspendTask(_ task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        eventMonitor?.request(self, didSuspendTask: task)
    }

    func didCancelTask(_ task: URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        eventMonitor?.request(self, didCancelTask: task)
    }

    func didResumeTask(_ task:URLSessionTask) {
        dispatchPrecondition(condition: .onQueue(underlyingQueue))
        eventMonitor?.request(self, didResumeTask: task)
    }
    
    ///异步调用任何存储的' cURLHandler '，然后从' mutableState '中删除它。
    private func callCURLHandlerIfNecessary() {
        mutableState.write { mutableState in
            guard let cURLHandler = mutableState.cURLHandler else { return }

            cURLHandler.queue.async { cURLHandler.handler(self.cURLDescription()) }

            mutableState.cURLHandler = nil
        }
    }

    func task(for request: URLRequest, using session: URLSession) -> URLSessionTask {
        fatalError("Subclasses must override.")
    }

    func appendResponseSerializer(_ closure: @escaping @Sendable () -> Void) {
        mutableState.write { mutableState in
            // 1. 把序列化闭包塞进数组，所有解析逻辑存在这里
            mutableState.responseSerializers.append(closure)
            
            // 场景：请求之前已经跑完 finished，现在又新增回调
            // 把状态切回 resumed，允许再次执行序列化流程
            if mutableState.state == .finished {
                mutableState.state = .resumed
            }

            // 2. 判断：旧的一批序列化器已经全部处理完
            // 此时新加入的闭包不会自动跑，需要手动触发一次解析流程
            if mutableState.responseSerializerProcessingFinished {
//                underlyingQueue.async { self.processNextResponseSerializer() }
            }

            // 3. 状态允许启动 && 自动发起请求开关打开，则自动调用 resume()
            if mutableState.state.canTransitionTo(.resumed) {
                underlyingQueue.async { [self] in
                    if (shouldAutomaticallyResume ?? delegate?.startImmediately) == true {
                        resume()
                    }
                }
            }
        }
    }
    
    @discardableResult
    public func resume() -> Self {
        let needsToPerform = mutableState.write { mutableState in
            guard mutableState.state.canTransitionTo(.resumed) else { return false }
            mutableState.state = .resumed
            // Ensure we have a task, otherwise Session hasn't called perform yet.
            guard let task = mutableState.tasks.last else { return true }
            // We have a task, so we shouldn't need to trigger perform again.
            guard task.state != .completed else { return false }
            task.resume()
            underlyingQueue.async {}
            return false
        }
        if needsToPerform {
            delegate?.readyToPerform(request: self)
        }
        return self
    }

}

extension GGRequest{
    public func cURLDescription() -> String {
        "no have"
    }
}

extension GGRequest:Hashable,Equatable{
    static func == (lhs: GGRequest, rhs: GGRequest) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//这个协议，只能被【类 class】遵守，不能被结构体 struct / 枚举 enum 遵守！
protocol GGRequestDelegate: AnyObject, Sendable {
    var startImmediately: Bool { get }
    func readyToPerform(request: GGRequest)
}


extension GGRequest {
    public enum ResponseDisposition:Sendable {
        case allow
        case cancel
        var sessionDisposition: URLSession.ResponseDisposition {
            switch self {
            case .allow: .allow
            case .cancel: .cancel
            }
        }
    }
}
