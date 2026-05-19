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

    enum RequestSetup {
        case lazy
        case eager
    }
    
    init(rootQueue: DispatchQueue = DispatchQueue(label: "org.GGsession.rootQueue"),
        requestQueue: DispatchQueue? = nil,
        serializationQueue: DispatchQueue? = nil,
        eventMonitor: CompositeEventMonitor) {
        self.rootQueue = rootQueue
        self.requestQueue = requestQueue
        self.serializationQueue = serializationQueue
        self.eventMonitor = eventMonitor
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

    }
    
}

extension GGSession: RequestDelegate {
    
}
