//
//  RequestInterceptor.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

protocol RequestInterceptor: RequestAdapter, RequestRetrier {
    
}

// 一句话：请求拦截器 = 给所有网络请求「统一加功能、统一改内容」的中间件
// 它是 Alamofire 最强大、最常用的协议，专门处理全局统一逻辑。
protocol RequestRetrier: Sendable {
    
}

/*
 RequestAdapter = 请求发送前的 “修改器”
 所有请求在发出去之前，都会先经过它，让你统一修改！
 */
public protocol RequestAdapter: Sendable {
    
}

class Interceptor: @unchecked Sendable, RequestInterceptor {
    
    let adapters: [any RequestAdapter]
    /// All `RequestRetrier`s associated with the instance. These retriers will be run one at a time until one triggers retry.
    let retriers: [any RequestRetrier]

    init(adapters: [any RequestAdapter] = [],
                retriers: [any RequestRetrier] = [],
                interceptors: [any RequestInterceptor] = []) {
        self.adapters = adapters + interceptors
        self.retriers = retriers + interceptors
    }

}
