//
//  Observable.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

public class GGObservable<Element>: GGObservableType {
    
    func subscribe<Observer:GGObserverType>(_ observer: Observer) -> GGDisposable where Observer.Element == Element
    {
     //它相当于在编译期或运行期大声告诉你：“嘿！你调用的这个基类方法是没有实际功能的！你必须去子类（比如 JustObservable）里实现它！”
        GGrxAbstractMethod()
    }
    
    func asObservable() -> GGObservable<Element> { self }
}

// 序列的协议
protocol GGObservableType:GGObservableConvertibleType {
    // 订阅
   func subscribe<Observer:GGObserverType>(_ observer: Observer) -> GGDisposable where Observer.Element == Element
}

extension GGObservableType {
    
    ///将一个元素处理程序、一个错误处理程序、一个完成处理程序和一个已处置处理程序下标到一个可观察序列。
    func subscribe(
        onNext: ((Element) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> GGDisposable {
        
        // 如果传了 onDisposed，包装成一个 disposable，dispose 时会调用它
        let disposable: GGDisposable
        if let onDisposed = onDisposed {
            disposable = GGAnonymousDisposable(disposeAction: onDisposed)
        } else {
            disposable = GGDisposables.create()
        }
        
        let observer = GGAnonymousObserver<Element> { event in
            switch event {
            case let .next(value):
                onNext?(value)
            case let .error(error):
                onError?(error)
                disposable.dispose()
            case .completed:
                onCompleted?()
                disposable.dispose()
            }
        }
        // 组合：subscription 管订阅生命周期，disposable 管 onDisposed 回调
        return GGDisposables.create(
            asObservable().subscribe(observer),
            disposable
        )
    }
}



/*
 解耦设计
 这是一个更高层、更宽泛的协议。它的意思是：“我不关心你内部是怎么实现的，也不要求你必须继承自 Observable，只要你最后能变成一个 Observable 给我用就行。”
 */
protocol GGObservableConvertibleType {
    associatedtype Element
    
    func asObservable() -> GGObservable<Element>
}


extension GGObservable{
    // 从指定订阅方法实现创建可观察序列。
    static func create(_ subscribe: @escaping (GGAnyObserver<Element>) -> GGDisposable) -> GGObservable<Element> {
        GGAnonymousObservable(subscribeHandler: subscribe)
    }
    
}
