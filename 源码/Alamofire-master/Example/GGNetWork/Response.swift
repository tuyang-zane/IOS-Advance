//
//  Response.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/22.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

typealias GGDataResponse<Success> = InDataResponse<Success, GGError>

/// 用于存储与 `DataRequest` 或 `UploadRequest` 序列化响应相关联的所有值的类型。
struct InDataResponse<Success, Failure: Error>: Sendable where Success: Sendable, Failure: Sendable {
    
    let request: URLRequest?

    let response: HTTPURLResponse?

    let data: Data?

    let metrics: URLSessionTaskMetrics?

    /// The time taken to serialize the response.
    let serializationDuration: TimeInterval

    /// The result of response serialization.
    let result: Result<Success, Failure>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    var value: Success? { result.success }

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    var error: Failure? { result.failure }

    init(request: URLRequest?,
                response: HTTPURLResponse?,
                data: Data?,
                metrics: URLSessionTaskMetrics?,
                serializationDuration: TimeInterval,
                result: Result<Success, Failure>) {
        self.request = request
        self.response = response
        self.data = data
        self.metrics = metrics
        self.serializationDuration = serializationDuration
        self.result = result
        
    }
}

extension Result {
    var success: Success? {
        guard case let .success(success) = self else {
            return nil
        }
        return success
    }
    
    var failure: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}
