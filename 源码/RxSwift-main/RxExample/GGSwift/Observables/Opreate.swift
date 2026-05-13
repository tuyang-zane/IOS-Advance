//
//  Funcs.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/12.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

extension GGObservableType{
    static func just(_ element: Element) -> GGObservable<Element> {
       return GGObservable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return GGNoDisposable()
        }
    }
    
    static func empty() -> GGObservable<Element> {
       return GGObservable.create { observer in
            observer.on(.completed)
            return GGNoDisposable()
        }
    }

}

