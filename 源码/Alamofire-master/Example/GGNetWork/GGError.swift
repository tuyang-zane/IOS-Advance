//
//  GGError.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/18.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

enum GGError: Error, Sendable {
    case invalidURL(url: any URLConvertible)
}
