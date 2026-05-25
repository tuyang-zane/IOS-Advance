//
//  File.swift
//  SnapKit
//
//  Created by 小涂和小周的mac on 2026/5/25.
//

import UIKit

final class GGConstraintItem {
    internal weak var target: AnyObject?
    internal let attributes: GGConstraintAttributes
    
    init(target: AnyObject? = nil, attributes: GGConstraintAttributes) {
        self.target = target
        self.attributes = attributes
    }
}

func ==(lhs:GGConstraintItem, rhs:GGConstraintItem) -> Bool {
    guard lhs !== rhs else {
        return true
    }
    guard let target1 = lhs.target,
          let target2 = rhs.target,
          target1 === target2 && lhs.attributes == rhs.attributes else {
            return false
    }
    return true
}
