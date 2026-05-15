//
//  Funcs.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/12.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

extension GGObservableType{
    static func just(_ element: Element) -> GGObservable<Element> {
       Just(element: element)
    }
    
    static func empty() -> GGObservable<Element> {
       return GGObservable.create { observer in
            observer.on(.completed)
            return GGNoDisposable()
        }
    }
    
    func map<Result>(_ transform: @escaping (Element) throws -> Result)
        -> GGObservable<Result>
    {
        GGMap(source: asObservable(), transform: transform)
    }
}

private final class GGMap<SourceType, ResultType>: GGProducer<ResultType> {
    
    typealias Transform = (SourceType) throws -> ResultType
    private let source: GGObservable<SourceType>
    private let transform: Transform

    init(source: GGObservable<SourceType>, transform: @escaping Transform) {
        self.source = source
        self.transform = transform
    }
    
    override func run<Observer: GGObserverType>(_ observer: Observer, cancel: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) where Observer.Element == ResultType {
        let sink = GGMapSink(transform: transform, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

private final class GGMapSink<SourceType, Observer: GGObserverType>: GGSink<Observer>, GGObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = Observer.Element

    private let transform: Transform

    init(transform: @escaping Transform, observer: Observer, cancel: GGCancelable) {
        self.transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: GGEvent<SourceType>) {
        switch event {
        case let .next(element):
            do {
                let mappedElement = try transform(element)
                forwardOn(.next(mappedElement))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}



class Just<Element>: GGProducer<Element> {
    
    private let element: Element

    init(element: Element) {
        self.element = element
    }

    override func subscribe<Observer>(_ observer: Observer) -> any GGDisposable where Element == Observer.Element, Observer : GGObserverType {
        observer.on(.next(element))
        observer.on(.completed)
        return GGDisposables.create()
    }
}
