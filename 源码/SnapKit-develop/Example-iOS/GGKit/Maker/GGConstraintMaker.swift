//
//  GGConstraintMaker.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

class GGConstraintMaker {

    public let item: GGLayoutConstraintItem

    private var descriptions = [GGConstraintDescription]()

    internal init(item: GGLayoutConstraintItem) {
        self.item = item
//        self.item.prepare()
    }

//    var left: GGConstraintMakerExtendable {
//        
//    }
    
    static func makeConstraints(item:GGLayoutConstraintItem, closure: ((_ make:GGConstraintMaker) -> Void)) {
        let constraints = prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: false)
        }
    }
    
    static func prepareConstraints(item:GGLayoutConstraintItem, closure: ((_ make:GGConstraintMaker) -> Void)) -> [GGConstraint] {
        let maker = GGConstraintMaker(item: item)
        closure(maker)
        var constraints:[GGConstraint] = []
        for description in maker.descriptions {
            
        }
        return constraints
    }
}
