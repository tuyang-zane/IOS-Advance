//
//  GGTargetType.swift
//  Moya
//
//  Created by tuyang on 2026/5/27.
//

import Foundation
import Alamofire

typealias HTTPMethod = Alamofire.HTTPMethod

/*
 面向协议描述 -> 枚举配置 -> 简易调用
 */
protocol GGTargetType {
    ///目标的基础‘ URL ’。
    var baseURL: URL { get }
    ///添加到‘ baseURL ’以形成完整的‘ URL ’的路径。
    var path: String { get }

    var method: HTTPMethod { get }

    var headers: [String: String]? { get }
}
