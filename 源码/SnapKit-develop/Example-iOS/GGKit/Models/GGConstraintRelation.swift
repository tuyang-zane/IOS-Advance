//
//  GGConstraintRelation.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

typealias LayoutRelation = NSLayoutConstraint.Relation

enum GGConstraintRelation: Int {
    case equal = 1
    case lessThanOrEqual
    case greaterThanOrEqual
    
    var layoutRelation: LayoutRelation {
        switch self {
        case .equal:
            return .equal
        case .lessThanOrEqual:
            return .lessThanOrEqual
        case .greaterThanOrEqual:
            return .greaterThanOrEqual
        }
    }
}
