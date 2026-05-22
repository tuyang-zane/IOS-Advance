//
//  HTTPHeader.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

public struct GGHTTPHeaders : Equatable, Hashable, Sendable {
    private var headers: [GGHTTPHeader] = []
    public init() {}
    public init(_ headers: [GGHTTPHeader]) {
        headers.forEach { update($0) }
    }
    
    public mutating func update(name: String, value: String) {
        update(GGHTTPHeader(name: name, value: value))
    }
    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter header: The `HTTPHeader` to update or append.
    public mutating func update(_ header: GGHTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        headers.replaceSubrange(index...index, with: [header])
    }
    
    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.value ,$0.value)}
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

extension [GGHTTPHeader] {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

public struct GGHTTPHeader: Equatable, Hashable, Sendable {
    /// Name of the header.
    public let name: String

    /// Value of the header.
    public let value: String

    /// Creates an instance from the given `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
