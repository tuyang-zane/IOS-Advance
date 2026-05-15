//
//  SerialDispatchQueueScheduler.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/15.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//
import Dispatch

class GGSerialDispatchQueueScheduler: GGImmediateSchedulerType {
    
    let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }

    //  调度要立即执行的操作。
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> any GGDisposable) -> any GGDisposable {
        let cancel = GGSingleAssignmentDisposable()
        queue.async {
            if cancel.isDisposed{
                cancel.setDisposable(action(state))
            }
        }
        return cancel
    }
    
}
