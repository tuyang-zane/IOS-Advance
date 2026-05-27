//
//  Verification1.swift
//  Moya
//
//  Created by tuyang on 2026/5/27.
//

import UIKit
import Alamofire

enum VerificationAPI {
    case method1(params: [String : Any])
    case method2(params: [String : Any])
}

extension VerificationAPI:GGTargetType {
    ///目标的基础‘ URL ’。
    var baseURL: URL {
      return URL(string: "http://example.com")!
    }
    
    var path: String {
        switch self {
        case .method1:
            return "method1"
        case .method2:
            return "method2"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .method1:
            return .post
        case .method2:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
