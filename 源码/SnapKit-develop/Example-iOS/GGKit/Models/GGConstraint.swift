//
//  GGConstraint.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

final class GGConstraint {
    
    var layoutConstraints: [GGLayoutConstraint]
    private let from: GGConstraintItem
    private let to: GGConstraintItem
    private let relation: GGConstraintRelation
    private let multiplier: GGConstraintMultiplierTarget
    internal let sourceLocation: (String, UInt)
    internal let label: String?
    private var constant: GGConstraintConstantTarget {
        didSet {
            self.updateConstantAndPriorityIfNeeded()
        }
    }
    private var priority: GGConstraintPriorityTarget {
        didSet {
            self.updateConstantAndPriorityIfNeeded()
        }
    }
    
    internal func updateConstantAndPriorityIfNeeded() {
        for layoutConstraint in self.layoutConstraints {
            
        }
    }
    
    init(from: GGConstraintItem,
                  to: GGConstraintItem,
                  relation: GGConstraintRelation,
                  sourceLocation: (String, UInt),
                  label: String?,
                  multiplier: GGConstraintMultiplierTarget,
                  constant: GGConstraintConstantTarget,
                  priority: GGConstraintPriorityTarget) {
        self.from = from
        self.to = to
        self.relation = relation
        self.sourceLocation = sourceLocation
        self.label = label
        self.multiplier = multiplier
        self.constant = constant
        self.priority = priority
        self.layoutConstraints = []
    }
    
    func activateIfNeeded(updatingExisting: Bool = false) {
        
        if updatingExisting {
            
        }else{
            NSLayoutConstraint.activate(layoutConstraints)
        }
    }
    
}
