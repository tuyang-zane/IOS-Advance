//
//  GGResponse.swift
//  Basic
//
//  Created by tuyang on 2026/5/27.
//

import Foundation

final class GGResponse {

    let statusCode: Int

    let data: Data

    let request: URLRequest?

    let response: HTTPURLResponse?

    init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }

}
