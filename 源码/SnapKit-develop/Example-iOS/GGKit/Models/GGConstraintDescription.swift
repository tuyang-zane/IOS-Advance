//
//  GGConstraintDescription.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

class GGConstraintDescription {

    internal let item: GGLayoutConstraintItem
    internal var attributes: GGConstraintAttributes
    internal var relation: GGConstraintRelation? = nil
    var related: GGConstraintItem? = nil
    var label: String? = nil
    var constant:GGConstraintConstantTarget = 0.0
    internal var sourceLocation: (String, UInt)? = nil

    lazy var constraint: GGConstraint? = {
        guard let relation = self.relation,
              let related = self.related,
              let sourceLocation = self.sourceLocation else {
            return nil }
        let from = GGConstraintItem(target: self.item, attributes: self.attributes)
        
        return GGConstraint{
    }()
}
