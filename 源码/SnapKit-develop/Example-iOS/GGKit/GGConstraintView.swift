//
//  GGConstraintView.swift
//  Example-iOS
//
//  Created by 小涂和小周的mac on 2026/5/25.
//

import UIKit

/*
 ConstraintDSL 顶层协议（基础能力：target、label）
 ↑ 继承
 ConstraintBasicAttributesDSL   基础属性（top、left、width、centerX...）
 ↑ 继承
 ConstraintAttributesDSL        高级/组合属性（edges、size、margins、insets...）
 */
public typealias GGConstraintView = UIView

extension GGConstraintView {
    var gg: GGConstraintViewDSL {
        return GGConstraintViewDSL(view: self)
    }
}
