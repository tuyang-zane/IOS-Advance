//
//  URLConvertible.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/18.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

protocol GGURLConvertible: Sendable {
    func asURL() throws -> URL
}

extension String:GGURLConvertible{
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw GGError.invalidURL(url: self) }
        return url
    }
}

extension URL: GGURLConvertible {
    /// Returns `self`.
    public func asURL() throws -> URL { self }
}

extension URLComponents: GGURLConvertible{
    public func asURL() throws -> URL {
        guard let url else { throw GGError.invalidURL(url: self) }
        return url
    }
}

protocol GGURLRequestConvertible: Sendable {
    func asURLRequest() throws -> URLRequest
}

extension URLRequest:GGURLRequestConvertible{
    public func asURLRequest() throws -> URLRequest { self }
}

extension URLRequest{
    init(url: any GGURLConvertible,method:GGHTTPMethod,headers: GGHTTPHeaders? = nil) throws{
        let url = try url.asURL()
        self.init(url: url)
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
    
    var method: GGHTTPMethod? {
        get { httpMethod.map(GGHTTPMethod.init)}
        set { httpMethod = newValue?.rawValue }
    }
    
    func validate() throws {
        if method == .get,let bodyData = httpBody{
            throw GGError.urlRequestValidationFailed(reason: .bodyDataInGETRequest(bodyData))
        }
    }
}
