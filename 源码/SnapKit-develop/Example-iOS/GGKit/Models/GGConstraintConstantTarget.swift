//
//  GGConstraintConstantTarget.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/26.
//

import UIKit

public typealias GGConstraintInsets = UIEdgeInsets

protocol GGConstraintConstantTarget {

}

extension CGPoint:GGConstraintConstantTarget{
    
}

extension CGSize:GGConstraintConstantTarget{
    
}

extension GGConstraintInsets:GGConstraintConstantTarget{
    
}

