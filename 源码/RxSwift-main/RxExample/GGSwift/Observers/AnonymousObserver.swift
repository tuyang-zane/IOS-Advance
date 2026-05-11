//
//  AnonymousObserver.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

/*
 **Observable = 事件的生产者（发出事件）
 Observer = 事件的消费者（接收事件）**
 */

final class GGAnonymousObserver<Element>: GGObserverBase<Element> {
    typealias EventHandler = (GGEvent<Element>) -> Void

    private let eventHandler: EventHandler

    init(eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }
    
    override func onCore(_ event: GGEvent<Element>) {
        eventHandler(event)
    }
}
