//
//  ObserverBase.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

class GGObserverBase<Element>: GGDisposable,GGObserverType {
    private let isStopped = GGAtomicInt(0)

    func on(_ event: GGEvent<Element>) {
        switch event {
        case .next:
            if load(isStopped) == 0 {
                onCore(event)
            }
        case .error, .completed:
            if fetchOr(isStopped, 1) == 0 {
                onCore(event)
            }
        }
    }
    
    func onCore(_: GGEvent<Element>) {
        GGrxAbstractMethod()
    }

    func dispose() {
        fetchOr(isStopped, 1)
    }

}


@inline(__always)
func load(_ this: GGAtomicInt) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
func fetchOr(_ this: GGAtomicInt, _ mask: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value |= mask
    this.unlock()
    return oldValue
}
