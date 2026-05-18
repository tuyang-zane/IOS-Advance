//
//  URLConvertible.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/18.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

protocol URLConvertible: Sendable {
    func asURL() throws -> URL
}

extension String:URLConvertible{
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw GGError.invalidURL(url: self) }
        return url
    }
}

extension URL: URLConvertible {
    /// Returns `self`.
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible{
    public func asURL() throws -> URL {
        guard let url else { throw GGError.invalidURL(url: self) }
        return url
    }
}

protocol URLRequestConvertible: Sendable {
    func asURLRequest() throws -> URLRequest
}

extension URLRequest:URLRequestConvertible{
    public func asURLRequest() throws -> URLRequest { self }
}

extension URLRequest{
    init(url: any URLConvertible,method:HTTPMethod) throws{
        let url = try url.asURL()
        self.init(url: url)
        httpMethod = method.rawValue
//        allHTTPHeaderFields =
    }
}
