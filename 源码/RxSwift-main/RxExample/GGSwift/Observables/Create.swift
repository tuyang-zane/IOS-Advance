//
//  Create.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

/*
 AnonymousObservable：存你的订阅闭包
 AnonymousObservableSink：转发事件、保证串行、防止重复结束
 Producer：提供订阅入口、管理生命周期、防止死锁
 */

// 【简单版】直接调闭包，不要 Sink - 用于对比学习
final class SimpleAnonymousObservable<Element>: GGObservable<Element> {
    typealias SubscribeHandler = (GGAnyObserver<Element>) -> GGDisposable
    let subscribeHandler:SubscribeHandler
    
    init(subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func subscribe<Observer>(_ observer: Observer) -> any GGDisposable where Element == Observer.Element, Observer : GGObserverType {

        if !GGCurrentThreadScheduler.isScheduleRequired {
            // 已经在调度中 → 直接执行（不需要再走 schedule）
            let anyObserver = GGAnyObserver(observer)
            return subscribeHandler(anyObserver)
        } else {
            // 不在调度中 → 走 schedule 流程
            return GGCurrentThreadScheduler.instance.schedule(()) { _ in
                let anyObserver = GGAnyObserver(observer)
                return self.subscribeHandler(anyObserver)
            }
        }
    }
}

// 【完整版】使用 Producer + Sink - 生产环境版本
final class GGAnonymousObservable<Element>:GGProducer<Element> {
    typealias SubscribeHandler = (GGAnyObserver<Element>) -> GGDisposable
    
    let subscribeHandler:SubscribeHandler
    
    init(subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func run<Observer: GGObserverType>(_ observer: Observer, cancel: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) where Observer.Element == Element {
        let sink =  GGAnonymousObservableSink(observer: observer, cancel:cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}

final class GGAnonymousObservableSink<Observer:GGObserverType>: GGSink<Observer>,GGObserverType {
    typealias Element = Observer.Element
    typealias Parent = GGAnonymousObservable<Element>
    
    override init(observer: Observer, cancel:GGCancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: GGEvent<Observer.Element>) {
        switch event {
        case .next:
            forwardOn(event)
        case .error, .completed:
            forwardOn(event)
            dispose()
         }
    }
    
    func run(_ parent: Parent) -> GGDisposable {
        parent.subscribeHandler(GGAnyObserver(self))
    }

}
