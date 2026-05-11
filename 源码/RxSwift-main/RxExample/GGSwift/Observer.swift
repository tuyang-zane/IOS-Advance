//
//  Observer.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

/// 能接收事件、能处理事件的标准接口
protocol GGObserverType {
    associatedtype Element
    func on(_ event:GGEvent<Element>)
}
