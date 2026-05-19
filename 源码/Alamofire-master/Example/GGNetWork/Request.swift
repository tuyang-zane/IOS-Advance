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

}

//这个协议，只能被【类 class】遵守，不能被结构体 struct / 枚举 enum 遵守！
public protocol RequestDelegate: AnyObject, Sendable {
    
}
