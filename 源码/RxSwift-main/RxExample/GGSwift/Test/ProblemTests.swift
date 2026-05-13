//
//  ProblemTests.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// 问题暴露测试
/// 这些测试演示了为什么 GGObservable 需要 Producer
class GGObservableProblemTests {
    
    // MARK: - 问题 1：CurrentThreadScheduler 死锁
    
    static func testProblem1_CurrentThreadSchedulerDeadlock() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 1：CurrentThreadScheduler 死锁                        ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        let scheduler = GGCurrentThreadScheduler.instance
        var completed = false
        let semaphore = DispatchSemaphore(value: 0)
        
        print("场景：在 CurrentThreadScheduler 中订阅 Observable")
        print("预期：应该正常完成")
        print("实际测试...")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            scheduler.schedule(()) { _ in
                let observable = GGObservable<Int>.create { observer in
                    print("  → 执行 subscribeHandler")
                    observer.on(.next(1))
                    observer.on(.completed)
                    return GGDisposables.create()
                }
                
                print("  → 开始订阅")
                observable.subscribe(onNext: { value in
                    print("  ✅ 收到值: \(value)")
                }, onCompleted: {
                    print("  ✅ 完成")
                    completed = true
                    semaphore.signal()
                }).disposed(by: GGDisposeBag())
                
                return GGDisposables.create()
            }
        }
        
        let result = semaphore.wait(timeout: .now() + .seconds(2))
        
        if result == .timedOut {
            print("❌ 死锁！CurrentThreadScheduler 中的订阅导致死锁")
            print("   原因：没有 Producer 检查 isScheduleRequired")
        } else if completed {
            print("✅ 没有死锁，正常完成")
            print("   原因：Producer 检查了 isScheduleRequired，重新调度")
        }
    }
    
    // MARK: - 问题 2：事件转发不完整
    
    static func testProblem2_IncompleteEventForwarding() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 2：事件转发不完整                                      ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        var receivedEvents: [String] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        print("场景：Observable 发送 completed 后继续发送事件")
        print("预期：completed 后的事件应该被忽略")
        print("实际测试...")
        
        let observable = GGObservable<Int>.create { observer in
            print("  → 发送 next(1)")
            observer.on(.next(1))
            print("  → 发送 next(2)")
            observer.on(.next(2))
            print("  → 发送 completed")
            observer.on(.completed)
            print("  → 发送 next(3) - 不应该被接收！")
            observer.on(.next(3))
            print("  → 发送 completed - 重复的完成事件！")
            observer.on(.completed)
            return GGDisposables.create()
        }
        
        observable.subscribe(onNext: { value in
            receivedEvents.append("next(\(value))")
            print("  ✓ 收到 next(\(value))")
        }, onCompleted: {
            receivedEvents.append("completed")
            print("  ✓ 收到 completed")
            semaphore.signal()
        }).disposed(by: GGDisposeBag())
        
        semaphore.wait()
        
        print("\n收到的事件：\(receivedEvents)")
        
        if receivedEvents.contains("next(3)") {
            print("❌ 问题：收到了不应该的事件 next(3)")
            print("   原因：没有 Sink 在 completed 后立即 dispose")
        } else if receivedEvents.filter({ $0 == "completed" }).count > 1 {
            print("❌ 问题：收到了重复的 completed 事件")
            print("   原因：没有 Sink 防止重复的终止事件")
        } else {
            print("✅ 事件完整且正确")
            print("   原因：Sink 在 completed 后立即 dispose")
        }
    }
    
    // MARK: - 问题 3：资源泄漏（并发场景）
    
    static func testProblem3_ResourceLeakConcurrent() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 3：资源泄漏（并发场景）                                ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        let initialCount = RxSwift.Resources.total
        print("初始资源数: \(initialCount)")
        print("场景：并发创建 100 个订阅，然后立即 dispose")
        print("预期：资源应该被正确释放")
        print("实际测试...")
        
        let semaphore = DispatchSemaphore(value: 0)
        var disposables: [GGDisposable] = []
        let lock = NSLock()
        
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            let observable = GGObservable<Int>.create { observer in
                observer.on(.next(i))
                observer.on(.completed)
                return GGDisposables.create()
            }
            
            let disposable = observable.subscribe(onNext: { _ in })
            lock.lock()
            disposables.append(disposable)
            lock.unlock()
        }
        
        print("  → 创建了 100 个订阅")
        
        // 立即 dispose
        for disposable in disposables {
            disposable.dispose()
        }
        
        print("  → 立即 dispose 所有订阅")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let finalCount = RxSwift.Resources.total
            print("最终资源数: \(finalCount)")
            
            let leaked = finalCount - initialCount
            if leaked > 0 {
                print("❌ 资源泄漏！泄漏了 \(leaked) 个资源")
                print("   原因：没有 SinkDisposer 处理并发竞态条件")
            } else {
                print("✅ 资源正确释放")
                print("   原因：SinkDisposer 处理了并发竞态条件")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    // MARK: - 问题 4：错误处理不完整
    
    static func testProblem4_IncompleteErrorHandling() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 4：错误处理不完整                                      ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        var receivedEvents: [String] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        print("场景：Observable 发送错误后继续发送事件")
        print("预期：错误后的事件应该被忽略")
        print("实际测试...")
        
        let observable = GGObservable<Int>.create { observer in
            print("  → 发送 next(1)")
            observer.on(.next(1))
            print("  → 发送 error")
            observer.on(.error(NSError(domain: "test", code: 1)))
            print("  → 发送 next(2) - 不应该被接收！")
            observer.on(.next(2))
            return GGDisposables.create()
        }
        
        observable.subscribe(
            onNext: { value in
                receivedEvents.append("next(\(value))")
                print("  ✓ 收到 next(\(value))")
            },
            onError: { error in
                receivedEvents.append("error")
                print("  ✓ 收到 error")
                semaphore.signal()
            }
        ).disposed(by: GGDisposeBag())
        
        semaphore.wait()
        
        print("\n收到的事件：\(receivedEvents)")
        
        if receivedEvents.contains("next(2)") {
            print("❌ 问题：收到了不应该的事件 next(2)")
            print("   原因：没有 Sink 在 error 后立即 dispose")
        } else {
            print("✅ 错误处理完整")
            print("   原因：Sink 在 error 后立即 dispose")
        }
    }
    
    // MARK: - 问题 5：多次订阅的一致性
    
    static func testProblem5_MultipleSubscriptionsConsistency() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 5：多次订阅的一致性                                    ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        var callCount = 0
        var results: [Int] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        print("场景：同一个 Observable 多次订阅")
        print("预期：每次订阅都应该独立执行 subscribeHandler")
        print("实际测试...")
        
        let observable = GGObservable<Int>.create { observer in
            callCount += 1
            print("  → subscribeHandler 被调用（第 \(callCount) 次）")
            observer.on(.next(callCount))
            observer.on(.completed)
            return GGDisposables.create()
        }
        
        print("  → 第一次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅1 收到: \(value)")
        }).disposed(by: GGDisposeBag())
        
        print("  → 第二次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅2 收到: \(value)")
        }).disposed(by: GGDisposeBag())
        
        print("  → 第三次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅3 收到: \(value)")
            semaphore.signal()
        }).disposed(by: GGDisposeBag())
        
        semaphore.wait()
        
        print("\n收到的值：\(results)")
        print("subscribeHandler 被调用了 \(callCount) 次")
        
        if results == [1, 2, 3] && callCount == 3 {
            print("✅ 多次订阅一致性正确")
            print("   原因：每次订阅都独立执行 subscribeHandler")
        } else {
            print("❌ 多次订阅一致性有问题")
            print("   原因：subscribeHandler 没有被正确调用")
        }
    }
    
    // MARK: - 问题 6：高并发场景下的事件丢失
    
    static func testProblem6_EventLossHighConcurrency() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 6：高并发场景下的事件丢失                              ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        let expectedCount = 1000
        var receivedCount = 0
        let lock = NSLock()
        let semaphore = DispatchSemaphore(value: 0)
        
        print("场景：高并发场景下发送 \(expectedCount) 个事件")
        print("预期：应该收到所有 \(expectedCount) 个事件")
        print("实际测试...")
        
        let observable = GGObservable<Int>.create { observer in
            DispatchQueue.concurrentPerform(iterations: expectedCount) { i in
                observer.on(.next(i))
            }
            observer.on(.completed)
            return GGDisposables.create()
        }
        
        observable.subscribe(onNext: { _ in
            lock.lock()
            receivedCount += 1
            lock.unlock()
        }, onCompleted: {
            semaphore.signal()
        }).disposed(by: GGDisposeBag())
        
        semaphore.wait()
        
        print("收到 \(receivedCount) 个事件（期望 \(expectedCount) 个）")
        
        if receivedCount == expectedCount {
            print("✅ 没有事件丢失")
            print("   原因：Sink 确保了事件的完整性")
        } else {
            print("❌ 事件丢失！丢失了 \(expectedCount - receivedCount) 个事件")
            print("   原因：没有 Sink 确保事件的同步和完整性")
        }
    }
    
    // MARK: - 运行所有测试
    
    static func runAllTests() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║         GGObservable 问题暴露测试                          ║
        ║      为什么需要 Producer？看看这些问题就知道了              ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        testProblem1_CurrentThreadSchedulerDeadlock()
        testProblem2_IncompleteEventForwarding()
        testProblem3_ResourceLeakConcurrent()
        testProblem4_IncompleteErrorHandling()
        testProblem5_MultipleSubscriptionsConsistency()
        testProblem6_EventLossHighConcurrency()
        
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║                    测试完成                                ║
        ╚════════════════════════════════════════════════════════════╝
        
        总结：
        ✅ 问题 1：CurrentThreadScheduler 死锁
           → 需要 Producer 检查 isScheduleRequired
        
        ✅ 问题 2：事件转发不完整
           → 需要 Sink 在 completed 后立即 dispose
        
        ✅ 问题 3：资源泄漏
           → 需要 SinkDisposer 处理并发竞态条件
        
        ✅ 问题 4：错误处理不完整
           → 需要 Sink 在 error 后立即 dispose
        
        ✅ 问题 5：多次订阅一致性
           → 需要 Producer 确保一致的行为
        
        ✅ 问题 6：高并发事件丢失
           → 需要 Sink 确保事件的同步和完整性
        
        现在你明白为什么需要 Producer 了吧？
        """)
    }
}
