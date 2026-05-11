//
//  AnyObserver.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

struct GGAnyObserver<Element>:GGObserverType {
    typealias EventHandler = (GGEvent<Element>) -> Void
    
    let observer:EventHandler
    
    init(observer: @escaping EventHandler) {
        self.observer = observer
    }
    
    public init<Observer: GGObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    func on(_ event: GGEvent<Element>) {
        observer(event)
    }
    public func asObserver() -> GGAnyObserver<Element> {
        self
    }
}
