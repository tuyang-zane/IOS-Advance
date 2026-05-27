//
//  GGConstraintViewDSL.swift
//  SnapKit
//
//  Created by 小涂和小周的mac on 2026/5/25.
//

import UIKit

struct GGConstraintViewDSL: GGConstraintAttributesDSL {
    
    var target: AnyObject?{
        return self.view
    }
    internal let view: GGConstraintView

    init(view: GGConstraintView) {
        self.view = view
    }
    
    func makeConstraints(_ closure: (_ make: GGConstraintMaker) -> Void) {
        GGConstraintMaker.makeConstraints(item: self.view, closure: closure)
    }
}
