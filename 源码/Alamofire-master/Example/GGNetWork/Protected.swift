//
//  Protected.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/20.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import Foundation

final class GGProtected<Value> {

    private let lock = GGUnfairLock()

    private nonisolated(unsafe) var value: Value

    init(_ value: Value) {
        self.value = value
    }
    
    func read<U>(_ closure: (Value) throws -> U) rethrows -> U {
        try lock.around { try closure(self.value) }
    }

    func write<U>(_ closure: (inout Value) throws -> U) rethrows -> U {
        try lock.around { try closure(&self.value) }
    }
}

protocol GGLock:Sendable{
    func lock()
    func unlock()
}

extension GGLock {
    
    func around<T>(_ closure: () throws -> T) rethrows -> T {
        lock(); defer{unlock()}
        return try closure()
    }
}

final class GGUnfairLock: GGLock, @unchecked Sendable {
 
    private let unfairLock: os_unfair_lock_t
    
    init() {
        //分配内存
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
