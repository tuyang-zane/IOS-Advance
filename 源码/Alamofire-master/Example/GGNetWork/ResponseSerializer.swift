//
//  ResponseSerializer.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/21.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

//作用：在服务器返回的 Data 交给序列化器（JSON/String/Decodable）之前，先做一次自定义修改 / 清洗。
protocol DataPreprocessor:Sendable{
    func preprocess(_ data: Data) throws -> Data
}

public struct PassthroughPreprocessor: DataPreprocessor {
    /// Creates an instance.
    public init() {}
    public func preprocess(_ data: Data) throws -> Data { data }
}

protocol ResponseSerializer:DataResponseSerializerProtocol {
}

extension ResponseSerializer{
    static var defaultEmptyRequestMethods: Set<GGHTTPMethod> { [.head] }
    static var defaultDataPreprocessor: any DataPreprocessor { PassthroughPreprocessor() }
    static var defaultEmptyResponseCodes: Set<Int> { [204, 205] }
}

public protocol DataResponseSerializerProtocol<SerializedObject>: Sendable {
    associatedtype SerializedObject: Sendable
    /// 将响应 `Data`` 序列化为提供的类型。///
    /// - 参数：
    ///   - request：用于执行请求的 `URLRequest`，如果存在的话。
    ///   - response：来自服务器的 `HTTPURLResponse`，如果存在的话。
    ///   - data：来自服务器返回的 `Data`，如果存在的话。
    ///   - error：请求过程中由 Alamofire 或底层 `URLSession` 产生的 `Error`。///
    /// - 返回：    `SerializedObject`。
    /// - - 抛出：       序列化过程中产生的任何 `Error`。
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: (any Error)?) throws -> SerializedObject
}

final class StringResponseSerializer: ResponseSerializer {
    
    typealias SerializedObject = String
    let encoding: String.Encoding?
    let emptyResponseCodes: Set<Int>
    let emptyRequestMethods: Set<GGHTTPMethod>
    public let dataPreprocessor: any DataPreprocessor

    public init(dataPreprocessor: any DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
                encoding: String.Encoding? = nil,
                emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<GGHTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods) {
        self.dataPreprocessor = dataPreprocessor
        self.encoding = encoding
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
    }

    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: (any Error)?) throws -> String {
        guard error == nil else { throw error! }
        
        guard var data, !data.isEmpty else {
            return ""
        }
        
        data = try dataPreprocessor.preprocess(data)
        
        var convertedEncoding = encoding

        if let encodingName = response?.textEncodingName, convertedEncoding == nil {
            convertedEncoding = String.Encoding(ianaCharsetName: encodingName)
        }

        let actualEncoding = convertedEncoding ?? .isoLatin1

        guard let string = String(data: data, encoding: actualEncoding) else { return "" }
        
        return string
    }

}


extension String.Encoding {
    /// Creates an encoding from the IANA charset name.
    ///
    /// - Notes: These mappings match those [provided by CoreFoundation](https://opensource.apple.com/source/CF/CF-476.18/CFStringUtilities.c.auto.html)
    ///
    /// - Parameter name: IANA charset name.
    init?(ianaCharsetName name: String) {
        switch name.lowercased() {
        case "utf-8":
            self = .utf8
        case "iso-8859-1":
            self = .isoLatin1
        case "unicode-1-1", "iso-10646-ucs-2", "utf-16":
            self = .utf16
        case "utf-16be":
            self = .utf16BigEndian
        case "utf-16le":
            self = .utf16LittleEndian
        case "utf-32":
            self = .utf32
        case "utf-32be":
            self = .utf32BigEndian
        case "utf-32le":
            self = .utf32LittleEndian
        default:
            return nil
        }
    }
}
