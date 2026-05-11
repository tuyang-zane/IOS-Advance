//
//  Sink.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

import Foundation

// 事件转发的核心基类
class GGSink<Observer:GGObserverType>: GGDisposable {
    let observer:Observer
    let cancel:GGCancelable
    
    // 原子标记：是否已销毁
    private let disposed = GGAtomicInt(value: 0)

    init(observer: Observer, cancel: GGCancelable) {
        self.observer = observer
        self.cancel = cancel
    }
    
    // 安全转发事件
    final func forwardOn(_ event:GGEvent<Observer.Element>) {
        observer.on(event)
    }
    
    func dispose() {
        cancel.dispose()
    }
}


final class GGAtomicInt: NSLock,@unchecked Sendable {
    var value:Int32
    init(value: Int32) {
        self.value = value
    }
    init(_ value: Int32 = 0) {
        self.value = value
    }
}

