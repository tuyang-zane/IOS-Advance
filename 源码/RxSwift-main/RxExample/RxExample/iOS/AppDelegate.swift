//
//  AppDelegate.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if UIApplication.isInUITest {
            UIView.setAnimationsEnabled(false)
        }

        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }

        #if DEBUG
        // 运行 GGObservable 问题暴露测试
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            GGObservableProblemTests.runAllTests()
        }
        
        _ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("Resource count \(RxSwift.Resources.total)")
            })
        #endif

        testCurrentThreadSchedulerDeadlock()
        
        return true
    }
    
    func testCurrentThreadSchedulerDeadlock() {
        let scheduler = GGSerialDispatchQueueScheduler(queue: DispatchQueue.main)
        let subscription = Observable<Int>.interval(.milliseconds(300), scheduler: scheduler)
            .subscribe { event in
                print(event)
            }
        Thread.sleep(forTimeInterval: 2.0)
        subscription.dispose()
    }

    
    func testProducerNecessity() {
        print("""
        ╔══════════════════════════════════════════════════════════╗
        ║         测试 Producer 的三个核心问题                      ║
        ╚══════════════════════════════════════════════════════════╝
        """)
        
        // 问题1: CurrentThreadScheduler 死锁
        print("\n【问题1】CurrentThreadScheduler 死锁")
        print("场景：在 CurrentThreadScheduler 中订阅一个 Observable")
        print("预期：应该正常工作，不应该死锁")
        print("实际测试...")
        testCurrentThreadSchedulerDeadlock()
        
        // 问题2: 事件丢失（没有 Sink 管理）
        print("\n【问题2】事件丢失（没有 Sink 管理）")
        print("场景：快速订阅和取消订阅，事件可能丢失")
        print("预期：所有事件应该被正确转发")
        print("实际测试...")
        testCurrentThreadSchedulerDeadlock()
        
        // 问题3: 资源泄漏（没有 SinkDisposer）
        print("\n【问题3】资源泄漏（没有 SinkDisposer）")
        print("场景：并发订阅和取消订阅")
        print("预期：资源应该被正确释放")
        print("实际测试...")
    }
    
    // 问题2: 事件丢失
    func testEventLoss() {
        var receivedCount = 0
        let expectedCount = 100
        let semaphore = DispatchSemaphore(value: 0)
        
        let observable = Observable<Int>.create { observer in
            for i in 0..<expectedCount {
                observer.on(.next(i))
            }
            observer.on(.completed)
            return Disposables.create()
        }
        
        observable.subscribe(onNext: { _ in
            receivedCount += 1
        }, onCompleted: {
            semaphore.signal()
        }).disposed(by: DisposeBag())
        
        semaphore.wait()
        
        if receivedCount == expectedCount {
            print("✅ 收到 \(receivedCount) 个事件（期望 \(expectedCount) 个）")
        } else {
            print("❌ 只收到 \(receivedCount) 个事件，丢失了 \(expectedCount - receivedCount) 个")
        }
    }
    
    // 问题3: 资源泄漏
//    func testResourceLeak() {
//        let initialCount = RxSwift.Resources.total
//        print("初始资源数: \(initialCount)")
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        var disposeBag: DisposeBag? = DisposeBag()
//        
//        DispatchQueue.concurrentPerform(iterations: 100) { _ in
//            let observable = Observable<Int>.create { observer in
//                observer.on(.next(1))
//                observer.on(.completed)
//                return Disposables.create()
//            }
//            
//            observable.subscribe(onNext: { _ in
//                // 处理事件
//            }).disposed(by: disposeBag!)
//        }
//        
//        disposeBag = nil
//        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
//            let finalCount = RxSwift.Resources.total
//            print("最终资源数: \(finalCount)")
//            
//            if finalCount == initialCount {
//                print("✅ 资源正确释放")
//            } else {
//                print("❌ 资源泄漏！泄漏了 \(finalCount - initialCount) 个资源")
//            }
//            
//            semaphore.signal()
//        }
//        
//        semaphore.wait()
//    }
}
