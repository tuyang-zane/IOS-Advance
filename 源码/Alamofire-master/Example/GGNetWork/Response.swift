//
//  Response.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/22.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

typealias GGDataResponse<Success> = GDataResponse<Success, GGError>

struct GDataResponse<Success, Failure: Error>: Sendable where Success: Sendable, Failure: Sendable {
    
}
