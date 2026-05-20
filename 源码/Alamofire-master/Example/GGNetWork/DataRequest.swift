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

class DataRequest: Request,@unchecked Sendable {

    public let convertible: any URLRequestConvertible

    init(id: UUID = UUID(),// 唯一ID，用来追踪请求
         convertible: any URLRequestConvertible,// 唯一ID，用来追踪请求
         underlyingQueue: DispatchQueue,// 底层工作队列（网络执行）
         serializationQueue: DispatchQueue,// 序列化队列（解析JSON/数据）
         eventMonitor: (any EventMonitor)?,// 事件监听（日志、埋点）
         interceptor: (any RequestInterceptor)?, // 请求拦截器（Token、重试）
         shouldAutomaticallyResume: Bool?,// 网络恢复后是否自动重试
         delegate: any RequestDelegate  // 代理（执行请求、回调、状态管理）
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
}
