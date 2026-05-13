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

        
        let observable = GGObservable.just(1)
        
//        let a = GGObservable.create { observer in
//            observer.on(.next(0))
//            observer.on(.completed)
//            return GGNoDisposable()
//        }
//

        GGObservableProblemTests.testProblem1_IncompleteEventForwarding()

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
