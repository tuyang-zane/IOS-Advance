//
//  File.swift
//  SnapKit
//
//  Created by 小涂和小周的mac on 2026/5/25.
//

import UIKit

protocol GGConstraintDSL {
    
    var target: AnyObject? { get }
    
    func setLabel(_ value:String?)
    func label() -> String?
    
}


/*
 ConstraintBasicAttributesDSL = 基础约束属性协议
 它继承自 ConstraintDSL，专门负责：top、left、bottom、right、width、height 等最基础的约束属性
 */
protocol GGConstraintBasicAttributesDSL : GGConstraintDSL{
    
}

extension GGConstraintBasicAttributesDSL {
    // MARK： 基础
    var left: GGConstraintItem {
        return GGConstraintItem(target: self.target, attributes: GGConstraintAttributes.left)
    }
    
    var top: GGConstraintItem {
        return GGConstraintItem(target: self.target, attributes: GGConstraintAttributes.top)
    }

    var right: GGConstraintItem {
        return GGConstraintItem(target: self.target, attributes: GGConstraintAttributes.right)
    }

    var bottom: GGConstraintItem {
        return GGConstraintItem(target: self.target, attributes: GGConstraintAttributes.bottom)
    }
}


public protocol GGConstraintAttributesDSL : GGConstraintBasicAttributesDSL {
}
