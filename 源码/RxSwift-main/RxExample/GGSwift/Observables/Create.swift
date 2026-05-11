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
 Producer：提供订阅入口、管理生命周期
 */

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


