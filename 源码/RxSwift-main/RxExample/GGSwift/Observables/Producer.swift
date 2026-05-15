//
//  Producer.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

// 生产者 - 核心职责：
// 1. 检查 CurrentThreadScheduler 上下文，防止死锁
// 2. 管理 Sink 和 Subscription 的生命周期
// 3. 通过 SinkDisposer 确保资源正确释放

class GGProducer<Element>: GGObservable<Element> {
    override init() {
        super.init()
    }
    
    override func subscribe<Observer: GGObserverType>(_ observer: Observer) -> GGDisposable where Observer.Element == Element {
        
        if !GGCurrentThreadScheduler.isScheduleRequired {
            // 已经在调度中 → 直接执行（不需要再走 schedule）
            let disposer = GGSinkDisposer()
            let sinkAndSubscription = run(observer, cancel: disposer)
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
            return disposer
        } else {
            // 不在调度中 → 走 schedule 流程
            return GGCurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = GGSinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
                return disposer
            }
        }
    }
    
    private func executeSubscription<Observer: GGObserverType>(_ observer: Observer) -> GGDisposable where Observer.Element == Element {
        // 创建一个 SinkDisposer 用于管理 sink 和 subscription 的生命周期
        let disposer = GGSinkDisposer()
        let sinkAndSubscription = self.run(observer, cancel: disposer)
        disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
        return disposer
    }
    
    func run<Observer: GGObserverType>(_: Observer, cancel _: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) where Observer.Element == Element {
        GGrxAbstractMethod()
    }
}

/// 管理 Sink 和 Subscription 的生命周期
/// 当 dispose 时，同时销毁 sink（事件转发器）和 subscription（用户闭包返回的 disposable）
final class GGSinkDisposer: GGCancelable {
    private let state = GGAtomicInt(0)
    private var sink: GGDisposable?
    private var subscription: GGDisposable?
    
    // state 用位标记：bit0 = disposed, bit1 = sink已设置
    private enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    var isDisposed: Bool {
        isFlagSet(state, DisposeState.disposed.rawValue)
    }
    
    func setSinkAndSubscription(sink: GGDisposable, subscription: GGDisposable) {
        self.sink = sink
        self.subscription = subscription
        
        let previousState = fetchOr(state, DisposeState.sinkAndSubscriptionSet.rawValue)
        // 如果在设置之前就已经被 dispose 了，立即清理
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            sink.dispose()
            subscription.dispose()
            self.sink = nil
            self.subscription = nil
        }
    }
    
    func dispose() {
        let previousState = fetchOr(state, DisposeState.disposed.rawValue)
        // 已经 dispose 过了，不重复执行
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }
        // 如果 sink 和 subscription 已经设置了，执行清理
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            sink?.dispose()
            subscription?.dispose()
            sink = nil
            subscription = nil
        }
    }
}
