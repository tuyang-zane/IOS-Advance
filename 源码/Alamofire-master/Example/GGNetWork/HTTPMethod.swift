//
//  HTTPMethod.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/18.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

struct GGHTTPMethod: RawRepresentable, Equatable, Hashable, Sendable {
    /// `CONNECT` method.
    public static let connect = GGHTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    public static let delete = GGHTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    public static let get = GGHTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    public static let head = GGHTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    public static let options = GGHTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    public static let patch = GGHTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    public static let post = GGHTTPMethod(rawValue: "POST")
    /// `PUT` method.
    public static let put = GGHTTPMethod(rawValue: "PUT")
    /// `QUERY` method.
    public static let query = GGHTTPMethod(rawValue: "QUERY")
    /// `TRACE` method.
    public static let trace = GGHTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
