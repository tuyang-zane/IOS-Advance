//
//  ResponseSerializer.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/21.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

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

}
