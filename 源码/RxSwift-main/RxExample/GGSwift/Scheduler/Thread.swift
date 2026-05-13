//
//  Thread.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

class GGRxMutableBox<T>: CustomDebugStringConvertible {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}

extension GGRxMutableBox {
    /// - returns: Box description.
    var debugDescription: String {
        "MutatingBox(\(value))"
    }
}
