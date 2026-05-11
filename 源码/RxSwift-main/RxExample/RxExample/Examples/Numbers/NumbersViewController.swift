//
//  NumbersViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class NumbersViewController: ViewController {
    @IBOutlet var number1: UITextField!
    @IBOutlet var number2: UITextField!
    @IBOutlet var number3: UITextField!

    @IBOutlet var result: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.combineLatest(number1.rx.text.orEmpty, number2.rx.text.orEmpty, number3.rx.text.orEmpty) { textValue1, textValue2, textValue3 -> Int in
            return (Int(textValue1) ?? 0) + (Int(textValue2) ?? 0) + (Int(textValue3) ?? 0)
        }
        .map(\.description)
        .bind(to: result.rx.text)
        .disposed(by: disposeBag)
        
//        let scheduler = SerialDispatchQueueScheduler(qos: .default)
//        let subscription = Observable<Int>.interval(.milliseconds(300), scheduler: scheduler)
//            .subscribe { event in
//                print(event)
//            }

        var observer:GGAnyObserver<Int>!
        let a = GGObservable.create { o in
            observer = o
            return GGNoDisposable()
        }
        
        // 2. 订阅：这里创建 消费者
        a.subscribe { e in
            print("发送数据流======   \(e)")
        } onError: { e in
            print("发送数据error======   \(e)")
        } onCompleted: {
            print("发送数据完成")
        } onDisposed: {
            print("发送数据销毁")
        }
        
        // 给生产者发事件
        observer.on(.next(0))
        
        observer.on(.next(1))

        observer.on(.completed)

        observer.on(.next(2))

    }
    
    func myFrom<E>(_ sequence: [E]) -> Observable<E> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }

            observer.on(.completed)
            return Disposables.create()
        }
    }
}
