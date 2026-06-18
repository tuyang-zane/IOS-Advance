//
//  DataRequest.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

/*
 ① 监听响应
 ② 取消请求（页面销毁时必用）
 ③ 设置超时、自动重试
 ④ 添加请求头（临时）
 ⑤ 监听上传 / 下载进度
 */

class GGDataRequest: GGRequest,@unchecked Sendable {

    public let convertible: any GGURLRequestConvertible

    public var data: Data? { dataMutableState.read(\.data) }

    private struct DataMutableState {
        var data: Data?
        var httpResponseHandler: (queue: DispatchQueue,
                                  handler: @Sendable (_ response: HTTPURLResponse,
                                                      _ completionHandler: @escaping @Sendable (ResponseDisposition) -> Void) -> Void)?
    }

    private let dataMutableState = GGProtected(DataMutableState())

    init(id: UUID = UUID(),// 唯一ID，用来追踪请求
         convertible: any GGURLRequestConvertible,
         underlyingQueue: DispatchQueue,// 底层工作队列（网络执行）
         serializationQueue: DispatchQueue,// 序列化队列（解析JSON/数据）
         eventMonitor: (any GGEventMonitor)?,// 事件监听（日志、埋点）
         interceptor: (any GGRequestInterceptor)?, // 请求拦截器（Token、重试）
         shouldAutomaticallyResume: Bool?,// 网络恢复后是否自动重试
         delegate: any GGRequestDelegate  // 代理（执行请求、回调、状态管理）
    ) {
        self.convertible = convertible
        super.init(id: id,
                   underlyingQueue: underlyingQueue,
                   serializationQueue: serializationQueue,
                   eventMonitor: eventMonitor,
                   interceptor: interceptor,
                   shouldAutomaticallyResume: shouldAutomaticallyResume,
                   delegate: delegate)

    }
    
    override func task(for request:URLRequest,using session:URLSession) -> URLSessionTask {
        let copiedRequest = request
        return session.dataTask(with: copiedRequest)
    }
    
    
    public func responseString(queue: DispatchQueue = .main,
                               dataPreprocessor: any DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
                               encoding: String.Encoding? = nil,
                               emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
                               emptyRequestMethods: Set<GGHTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods,
                               completionHandler: @escaping @Sendable (GGDataResponse<String>) -> Void) -> Self {
        response(queue: queue,
                 responseSerializer: StringResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                              encoding: encoding,
                                                              emptyResponseCodes: emptyResponseCodes,
                                                              emptyRequestMethods: emptyRequestMethods),
                 completionHandler: completionHandler)
    }
    
    @preconcurrency
    func response<Serializer: ResponseSerializer>(queue: DispatchQueue = .main,
                                                         responseSerializer: Serializer,
                                                         completionHandler: @escaping @Sendable (GGDataResponse<Serializer.SerializedObject>) -> Void)
    -> Self {
        _response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)

    }
    
    private func _response<Serializer: DataResponseSerializerProtocol>(queue: DispatchQueue = .main,
                                                                       responseSerializer: Serializer,
                                                                       completionHandler: @escaping @Sendable (GGDataResponse<Serializer.SerializedObject>) -> Void)
    -> Self {
        appendResponseSerializer {
            let start = ProcessInfo.processInfo.systemUptime
            let result:GGResult<Serializer.SerializedObject> = Result{
                try responseSerializer.serialize(request: self.request, response: self.response, data: self.data, error: self.error)
            }.mapError({ error in
                error.asGGError(or: .invalidURL(url: "123"))
            })
            let end = ProcessInfo.processInfo.systemUptime
            
            self.underlyingQueue.async {
                let response = InDataResponse(request: self.request, response: self.response, data: self.data, metrics: self.metrics, serializationDuration: end - start, result: result)
                self.eventMonitor?.request(self, didParseResponse: response)
                completionHandler(response)
            }
        }
        return self
    }
}
