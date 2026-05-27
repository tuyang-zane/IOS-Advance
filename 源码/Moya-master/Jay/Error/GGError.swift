//
//  Error.swift
//  Basic
//
//  Created by tuyang on 2026/5/27.
//

import UIKit

enum GGError: Swift.Error {
    
    /// Indicates a response failed to map to a JSON structure.
    case jsonMapping(GGResponse)

    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(GGResponse)

}
