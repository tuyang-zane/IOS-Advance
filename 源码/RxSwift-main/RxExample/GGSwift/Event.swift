//
//  Event.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

/*
   序列事件
   frozen:告诉编译器永远不会增加,核心是事件流。想象一下你在做一个列表滚动，榨干每一滴性能，让编译器进行极致的优化
 */
@frozen enum GGEvent<Element> {
     
    case next(Element)
    
    case error(Error)
    
    case completed
}
