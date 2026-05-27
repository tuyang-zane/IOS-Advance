//
//  Cancellable.swift
//  Basic
//
//  Created by tuyang on 2026/5/27.
//

import UIKit

protocol GGCancellable {
    
    var isCancelled: Bool { get }

    func cancel()
}
