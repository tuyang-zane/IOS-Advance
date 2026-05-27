//
//  GGLayoutConstraint.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

class GGLayoutConstraint: NSLayoutConstraint {

    var label: String? {
        get {
            return self.identifier
        }
        set {
            self.identifier = newValue
        }
    }
    
    weak var constraint:GGConstraint? = nil
}
