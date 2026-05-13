//
//  ProblemTests.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/// 问题暴露测试
/// 这些测试演示了为什么 GGObservable 需要 Sink
public class GGObservableProblemTests {
    
    // MARK: - 问题 1：事件转发不完整
    
    public static func testProblem1_IncompleteEventForwarding() {
        
        // 场景：操作符链中，subscribe 触发了另一个 schedule
        // 比如 observeOn、subscribeOn、delay 等操作符

        let source = GGObservable<Int>.create { observer in
            observer.on(.next(1))
            observer.on(.completed)
            return GGDisposables.create()
        }

        // 假设有一个操作符在 schedule 内部又触发了 schedule
        GGCurrentThreadScheduler.instance.schedule(()) { _ in
            // 第一层 schedule
            source.subscribe(onNext: { value in
                // 如果这里又触发了 schedule（比如 observeOn 的实现）
                GGCurrentThreadScheduler.instance.schedule(()) { _ in
                    // 没有 trampoline 机制，这里会死锁或栈溢出
                    // 有了 trampoline，这个任务会被入队，等外层完成后执行
                    return GGDisposables.create()
                }
            })
            return GGDisposables.create()
        }

    }


    
    // MARK: - 问题 2：错误处理不完整
    
    public static func testProblem2_IncompleteErrorHandling() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 2：错误处理不完整                                      ║
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
        
        let disposeBag = DisposeBag()
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
        )
        
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
    
    // MARK: - 问题 3：多次订阅的一致性
    
    public static func testProblem3_MultipleSubscriptionsConsistency() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 3：多次订阅的一致性                                    ║
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
        
        let disposeBag = DisposeBag()
        
        print("  → 第一次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅1 收到: \(value)")
        })
        
        print("  → 第二次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅2 收到: \(value)")
        })
        
        print("  → 第三次订阅")
        observable.subscribe(onNext: { value in
            results.append(value)
            print("    ✓ 订阅3 收到: \(value)")
            semaphore.signal()
        })
        
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
    
    // MARK: - 问题 4：高并发场景下的事件丢失
    
    public static func testProblem4_EventLossHighConcurrency() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║ 问题 4：高并发场景下的事件丢失                              ║
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
        
        let disposeBag = DisposeBag()
        observable.subscribe(onNext: { _ in
            lock.lock()
            receivedCount += 1
            lock.unlock()
        }, onCompleted: {
            semaphore.signal()
        })
        
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
    
    public static func runAllTests() {
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║         GGObservable 问题暴露测试                          ║
        ║      为什么需要 Sink？看看这些问题就知道了                  ║
        ╚════════════════════════════════════════════════════════════╝
        """)
        
        testProblem1_IncompleteEventForwarding()
        testProblem2_IncompleteErrorHandling()
        testProblem3_MultipleSubscriptionsConsistency()
        testProblem4_EventLossHighConcurrency()
        
        print("""
        
        ╔════════════════════════════════════════════════════════════╗
        ║                    测试完成                                ║
        ╚════════════════════════════════════════════════════════════╝
        
        总结：
        ✅ 问题 1：事件转发不完整
           → 需要 Sink 在 completed 后立即 dispose
        
        ✅ 问题 2：错误处理不完整
           → 需要 Sink 在 error 后立即 dispose
        
        ✅ 问题 3：多次订阅一致性
           → 每次订阅都独立执行 subscribeHandler（已正确）
        
        ✅ 问题 4：高并发事件丢失
           → 需要 Sink 确保事件的同步和完整性
        
        现在你明白为什么需要 Sink 了吧？
        """)
    }
}
