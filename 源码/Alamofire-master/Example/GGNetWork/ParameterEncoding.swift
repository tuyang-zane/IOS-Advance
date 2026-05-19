//
//  ParameterEncoding.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

///一个用于‘ URLRequest ’的参数字典 ParameterEncoding = 网络请求参数的「编码格式协议」
typealias Parameters = [String:any Any & Sendable]

///用于定义如何将一组参数应用于‘ URLRequest ’的类型。
public protocol ParameterEncoding: Sendable {
    func encode(_ urlRequest: any URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
}

//一句话：把 Swift 字典参数，变成浏览器 / 服务器能识别的 URL 格式字符串。
struct URLEncoding:ParameterEncoding {
    public static var `default`: URLEncoding { URLEncoding() }
}
