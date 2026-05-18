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

class GGMainScheduler: GGSerialDispatchQueueScheduler {
    
    static let instance = GGMainScheduler()

    init() {
        super.init(queue: DispatchQueue.main)
    }

    //  调度要立即执行的操作。
    override func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> GGDisposable) -> GGDisposable {
        if DispatchQueue.isMain {
            return action(state)
        }
        return super.schedule(state, action: action)
    }
}

extension DispatchQueue {
    private static var token: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    static var isMain: Bool {
        DispatchQueue.getSpecific(key: token) != nil
    }
}

extension GGObservableType{
    func asObservable() -> GGObservable<Element> {
        GGObservable.create{o in self.subscribe(o)}
    }
    
    public func observe(on scheduler: GGImmediateSchedulerType)
    -> GGObservable<Element> {
        return GGObserveOn(scheduler: scheduler, source: self.asObservable())
    }
}

final class GGObserveOn<Element>: GGProducer<Element> {
    let scheduler: GGImmediateSchedulerType
    let source: GGObservable<Element>
    
    init(scheduler: GGImmediateSchedulerType, source: GGObservable<Element>) {
        self.scheduler = scheduler
        self.source = source
    }
    
    override func run<Observer: GGObserverType>(_ observer: Observer, cancel: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) where Observer.Element == Element {
        let sink = GGObserveOnSink(scheduler: scheduler, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
}

enum GGObserveOnState: Int32 {
    // pump is not running
    case stopped = 0
    // pump is running
    case running = 1
}

private final class GGObserveOnSink<Observer: GGObserverType>: GGObserverBase<Observer.Element> {
    let scheduler: GGImmediateSchedulerType
    var lock = GGRecursiveLock()
    let observer: Observer
    
    var state = GGObserveOnState.stopped
    var queue = Queue<GGEvent<Element>>(capacity: 10)
    
    let scheduleDisposable = GGNoDisposable()
    let cancel: GGCancelable

    init(scheduler: GGImmediateSchedulerType, observer: Observer, cancel: GGCancelable) {
        self.scheduler = scheduler
        self.observer = observer
        self.cancel = cancel
    }

    override func onCore(_ event: GGEvent<Observer.Element>) {
        let shouldStart = lock.performLocked {() -> Bool in self.queue.enqueue(event)
            switch self.state {
            case .stopped:
                self.state = .running
                return true
            case .running:
                return false
            }
        }
        if shouldStart {
            scheduleDisposable.disposable = scheduler.scheduleRecursive((), action: run)
        }
    }
    
    func run(_: (), _ recurse: (()) -> Void) {
        
        let (nextEvent, observer) = lock.performLocked { () -> GGEvent<Element>?, Observer) in
            if !self.queue.isEmpty {
                return (self.queue.dequeue(), self.observer)
            } else {
                self.state = .stopped
                return (nil, self.observer)
            }
        }
        
        if let nextEvent, !self.cancel.isDisposed {
            observer.on(nextEvent)
            if nextEvent.isStopEvent {
                dispose()
            }
        } else {
            return
        }

        let shouldContinue = shouldContinue_synchronized()

        if shouldContinue {
            recurse(())
        }

    }
    
    func shouldContinue_synchronized() -> Bool {
        lock.performLocked {
            let isEmpty = self.queue.isEmpty
            if isEmpty { self.state = .stopped }
            return !isEmpty
        }
    }

}

protocol Lock {
    func lock()
    func unlock()
}

extension GGRecursiveLock: Lock {
    @inline(__always)
    final func performLocked<T>(_ action: () -> T) -> T {
        lock(); defer { self.unlock() }
        return action()
    }
}
