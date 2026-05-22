//
//  RequestInterceptor.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

// 一句话：请求拦截器 = 给所有网络请求「统一加功能、统一改内容」的中间件
// 它是 Alamofire 最强大、最常用的协议，专门处理全局统一逻辑。
protocol GGRequestRetrier: Sendable {
    /// Whether the request should be retried.
    func request(_ request: GGRequest, didFailWithError error: Error) -> Bool
    
    /// Whether the request should be retried with a modified request.
    func request(_ request: GGRequest, didRetryWith error: Error) -> Bool?
}

/*
 RequestAdapter = 请求发送前的 "修改器"
 所有请求在发出去之前，都会先经过它，让你统一修改！
 */
protocol GGRequestAdapter: Sendable {
    /// Whether the request was adapted.
    func adapt(_ urlRequest: inout URLRequest, for session: URLSession, completion: @escaping (Result<URLRequest, Error>) -> Void)
}

protocol GGRequestInterceptor: GGRequestAdapter, GGRequestRetrier {
}

class GGInterceptor: @unchecked Sendable, GGRequestInterceptor {
    let adapters: [any GGRequestAdapter]
    let retriers: [any GGRequestRetrier]

    init(adapters: [any GGRequestAdapter] = [],
         retriers: [any GGRequestRetrier] = [],
         interceptors: [any GGRequestInterceptor] = []) {
        self.adapters = adapters + interceptors
        self.retriers = retriers + interceptors
    }
    
    // MARK: - GGRequestAdapter
    
    func adapt(_ urlRequest: inout URLRequest, for session: URLSession, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapters.forEach { $0.adapt(&urlRequest, for: session, completion: completion) }
    }
    
    // MARK: - GGRequestRetrier
    
    func request(_ request: GGRequest, didFailWithError error: Error) -> Bool {
        false
    }
    
    func request(_ request: GGRequest, didRetryWith error: Error) -> Bool? {
        false
    }
}
