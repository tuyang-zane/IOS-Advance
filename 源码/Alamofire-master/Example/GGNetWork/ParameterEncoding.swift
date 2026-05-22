//
//  ParameterEncoding.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

///一个用于' URLRequest '的参数字典 ParameterEncoding = 网络请求参数的「编码格式协议」
typealias GGParameters = [String:any Any & Sendable]

///用于定义如何将一组参数应用于' URLRequest '的类型。
protocol GGParameterEncoding: Sendable {
    func encode(_ urlRequest: any GGURLRequestConvertible, with parameters: GGParameters?) throws -> URLRequest
}

//一句话：把 Swift 字典参数，变成浏览器 / 服务器能识别的 URL 格式字符串。
struct GGURLEncoding:GGParameterEncoding {
    public static var `default`: GGURLEncoding { GGURLEncoding() }
    
    func encode(_ urlRequest: any GGURLRequestConvertible, with parameters: GGParameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        return urlRequest
    }
    
}
