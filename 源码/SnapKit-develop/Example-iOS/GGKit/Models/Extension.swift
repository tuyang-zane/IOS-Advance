//
//  Extension.swift
//  Example-iOS
//
//  Created by tuyang on 2026/5/27.
//

import UIKit

public protocol GGConstraintMultiplierTarget {
    var constraintMultiplierTargetValue: CGFloat { get }
}

extension Int: GGConstraintMultiplierTarget {
    
    public var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
    
}

extension UInt: GGConstraintMultiplierTarget {
    
    public var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
    
}

extension Float: GGConstraintMultiplierTarget {
    
    public var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
    
}

extension Double: GGConstraintMultiplierTarget {
    
    public var constraintMultiplierTargetValue: CGFloat {
        return CGFloat(self)
    }
    
}

extension CGFloat: GGConstraintMultiplierTarget {
    
    public var constraintMultiplierTargetValue: CGFloat {
        return self
    }
    
}

public protocol GGConstraintPriorityTarget {
    
    var constraintPriorityTargetValue: Float { get }
    
}

extension Int: GGConstraintPriorityTarget {
    
    public var constraintPriorityTargetValue: Float {
        return Float(self)
    }
    
}

extension UInt: GGConstraintPriorityTarget {
    
    public var constraintPriorityTargetValue: Float {
        return Float(self)
    }
    
}

extension Float: GGConstraintPriorityTarget {
    
    public var constraintPriorityTargetValue: Float {
        return self
    }
    
}

extension Double: GGConstraintPriorityTarget {
    
    public var constraintPriorityTargetValue: Float {
        return Float(self)
    }
    
}

extension CGFloat: GGConstraintPriorityTarget {
    
    public var constraintPriorityTargetValue: Float {
        return Float(self)
    }
    
}
