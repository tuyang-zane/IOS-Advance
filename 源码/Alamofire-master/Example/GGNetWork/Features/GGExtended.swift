//
//  GGExtended.swift
//  iOS Example
//
//  Created by tuyang on 2026/6/1.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

public struct GGExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    public init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `af` extension points for Alamofire extended types.
public protocol GGExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static Alamofire extension point.
    static var gg: GGExtension<ExtendedType>.Type { get set }
    /// Instance Alamofire extension point.
    var gg: GGExtension<ExtendedType> { get set }
}

extension GGExtended {
    /// Static Alamofire extension point.
    public static var gg: GGExtension<Self>.Type {
        get { GGExtension<Self>.self }
        set {}
    }

    /// Instance Alamofire extension point.
    public var gg: GGExtension<Self> {
        get { GGExtension(self) }
        set {}
    }
}


extension URLSessionConfiguration: GGExtended {}
extension GGExtension where ExtendedType: URLSessionConfiguration {
    /// Alamofire's default configuration. Same as `URLSessionConfiguration.default` but adds Alamofire default
    /// `Accept-Language`, `Accept-Encoding`, and `User-Agent` headers.
    public static var `default`: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return configuration
    }

    /// `.ephemeral` configuration with Alamofire's default `Accept-Language`, `Accept-Encoding`, and `User-Agent`
    /// headers.
    public static var ephemeral: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.headers = .default
        return configuration
    }
}
