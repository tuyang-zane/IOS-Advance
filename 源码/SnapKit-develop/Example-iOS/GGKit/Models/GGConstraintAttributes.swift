//
//  ConstraintAttributes.swift
//  SnapKit
//
//  Created by 小涂和小周的mac on 2026/5/25.
//

import UIKit

/*
 OptionSet 选项集合
 ExpressibleByIntegerLiteral 允许用整数表示
 */
struct GGConstraintAttributes: OptionSet,ExpressibleByIntegerLiteral {

    typealias IntegerLiteralType = UInt

    internal private(set) var rawValue: UInt

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    internal static let left: GGConstraintAttributes = GGConstraintAttributes(UInt(1) << 0)
    internal static let top: GGConstraintAttributes = GGConstraintAttributes(UInt(1) << 1)
    internal static let right: GGConstraintAttributes = GGConstraintAttributes(UInt(1) << 2)
    internal static let bottom: GGConstraintAttributes = GGConstraintAttributes(UInt(1) << 3)

}
