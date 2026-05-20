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
class Request: @unchecked Sendable {

    public let id: UUID

    public let underlyingQueue: DispatchQueue

    public let serializationQueue: DispatchQueue

    public let shouldAutomaticallyResume: Bool?
    
    public private(set) weak var delegate: (any RequestDelegate)?

    let mutableState: Protected<MutableState>

    public var isCancelled: Bool { state == .cancelled }

    public var state: State { mutableState.read(\.state) }

    public var eventMonitor: (any EventMonitor)? {
        mutableState.read(\.eventMonitor)
    }

    public var interceptor: (any RequestInterceptor)? {
        mutableState.read(\.interceptor)
    }

    public var lastRequest: URLRequest? { requests.last }

    public var requests: [URLRequest] { mutableState.read(\.requests) }

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

    }
    
    init(id: UUID = UUID(),
         underlyingQueue: DispatchQueue,
         serializationQueue: DispatchQueue,
         eventMonitor: (any EventMonitor)?,
         interceptor: (any RequestInterceptor)?,
         shouldAutomaticallyResume: Bool?,
         delegate: any RequestDelegate) {
        self.id = id
        self.underlyingQueue = underlyingQueue
        self.serializationQueue = serializationQueue
        mutableState = Protected(MutableState(eventMonitor: eventMonitor,
                                              interceptor: interceptor))
        self.shouldAutomaticallyResume = shouldAutomaticallyResume
        self.delegate = delegate
    }
    
    struct MutableState {
        var state: State = .initialized
        var eventMonitor: (any EventMonitor)?
        var interceptor: (any RequestInterceptor)?
        var requests: [URLRequest] = []
        var urlRequestHandler: (queue: DispatchQueue, handler: @Sendable (URLRequest) -> Void)?
        var cURLHandler: (queue: DispatchQueue, handler: @Sendable (String) -> Void)?
        var tasks: [URLSessionTask] = []
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

            default:
                <#code#>
            }

        }
    }
    
    ///异步调用任何存储的‘ cURLHandler ’，然后从‘ mutableState ’中删除它。
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

}

extension Request{
    public func cURLDescription() -> String {
        "no have"
    }
}

extension Request:Hashable,Equatable{
    static func == (lhs: Request, rhs: Request) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//这个协议，只能被【类 class】遵守，不能被结构体 struct / 枚举 enum 遵守！
public protocol RequestDelegate: AnyObject, Sendable {
    
}
