//
//  Scheduler.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//
import Dispatch
import Foundation

protocol GGImmediateSchedulerType {
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> GGDisposable) -> GGDisposable
}

private class CurrentThreadSchedulerQueueKey: NSObject, NSCopying {
    static let instance = CurrentThreadSchedulerQueueKey()
    override private init() {
        super.init()
    }

    override var hash: Int {
        0
    }

    func copy(with _: NSZone? = nil) -> Any {
        self
    }
}

public class GGCurrentThreadScheduler: GGImmediateSchedulerType {
    
    typealias ScheduleQueue = GGRxMutableBox<Queue<ScheduledItemType>>

    static var queue: ScheduleQueue? {
        get {
            Thread.getThreadLocalStorageValueForKey(CurrentThreadSchedulerQueueKey.instance)
        }
        set {
            Thread.setThreadLocalStorageValue(newValue, forKey: CurrentThreadSchedulerQueueKey.instance)
        }
    }

    public static let instance = GGCurrentThreadScheduler()

    
    /*
     它利用了 线程局部存储（Thread Local Storage, TLS） 技术，在当前线程上打了一个“隐形标记”，用来判断当前是否已经处于一个调度任务中。
     
     pthread_getspecific 与 pthread_setspecific
     这两个是 POSIX 线程库（pthread）提供的底层 C 语言 API，专门用于操作线程局部存储（TLS）。
     TLS 是什么？ 你可以把它理解为一个全局的字典，但它的 Key 是全局的，而 Value 是跟着当前线程走的。线程 A 设置的值，线程 B 绝对看不到。

     */
    private(set) static var isScheduleRequired: Bool {
        get {
            // 尝试从当前线程的 TLS 中获取标记
            // 如果获取到的结果是 nil（等于 nil），说明当前线程没有正在进行的调度任务
            // 因此 isScheduleRequired 返回 true（是的，需要调度！）
            pthread_getspecific(GGCurrentThreadScheduler.isScheduleRequiredKey) == nil
        }
        set(isScheduleRequired) {
            
            // pthread_setspecific 会把 valueToSet 绑定到当前线程的 Key 上
            // 如果返回值不是 0，说明底层系统调用失败了（比如内存不足），直接抛出致命错误
            if pthread_setspecific(GGCurrentThreadScheduler.isScheduleRequiredKey, isScheduleRequired ? nil : scheduleInProgressSentinel) != 0 {
                rxFatalError("pthread_setspecific failed")
            }
        }
    }
    
    private static var scheduleInProgressSentinel: UnsafeRawPointer = { () -> UnsafeRawPointer in
        return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
    }()

    
    private static var isScheduleRequiredKey: pthread_key_t = { () -> pthread_key_t in
        let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
        defer { key.deallocate() }

        guard pthread_key_create(key, nil) == 0 else {
            rxFatalError("isScheduleRequired key creation failed")
        }

        return key.pointee
    }()

    
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> any GGDisposable) -> any GGDisposable {
        if GGCurrentThreadScheduler.isScheduleRequired {
            
            // 1. 关门：把标记设为 false，告诉后续可能发生的递归调用“别进来，去排队”
            GGCurrentThreadScheduler.isScheduleRequired = false
            
            // 2. 执行真正的任务（比如执行你的订阅闭包）
            let disposable = action(state)
            
            // 3. defer 延迟执行：保证这段代码在函数返回前的最后一刻才执行
            defer {
                GGCurrentThreadScheduler.isScheduleRequired = true // 恢复标记，开门
                GGCurrentThreadScheduler.queue = nil               // 清空队列
            }
            
            
            // 4. 检查有没有人在排队（处理递归调用留下的任务）
            guard let queue = GGCurrentThreadScheduler.queue else {
                return disposable // 没人排队，直接返回
            }

            // 5. 依次处理队列里的所有任务
            while let latest = queue.value.dequeue() {
                if latest.isDisposed { continue }
                latest.invoke() // 执行排队的任务
            }

            return disposable

        }
        
        // 1. 拿到当前的队列（如果没有，就新建一个）
        let existingQueue = GGCurrentThreadScheduler.queue
        let queue: GGRxMutableBox<Queue<ScheduledItemType>>
        if let existingQueue {
            queue = existingQueue
        } else {
            queue = GGRxMutableBox(Queue<ScheduledItemType>(capacity: 1))
            GGCurrentThreadScheduler.queue = queue // 把队列挂到 TLS 上，让上面的 defer 能找到
        }
        // 2. 把当前的任务包装成 ScheduledItem，扔进队列里
        let scheduledItem = ScheduledItem(action: action, state: state)
        queue.value.enqueue(scheduledItem)

        // 3. 返回这个任务（此时任务并没有被执行，只是被存起来了）
        return scheduledItem
    }

}


extension Thread {
    static func setThreadLocalStorageValue(_ value: (some AnyObject)?, forKey key: NSCopying) {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary

        if let newValue = value {
            threadDictionary[key] = newValue
        } else {
            threadDictionary[key] = nil
        }
    }

    static func getThreadLocalStorageValueForKey<T>(_ key: NSCopying) -> T? {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary

        return threadDictionary[key] as? T
    }
}

protocol ScheduledItemType:
    GGCancelable,
    InvocableType
{
    func invoke()
}

protocol InvocableType {
    func invoke()
}

protocol InvocableWithValueType {
    associatedtype Value

    func invoke(_ value: Value)
}


struct ScheduledItem<T>:
    ScheduledItemType,
    InvocableType
{
    typealias Action = (T) -> GGDisposable

    private let action: Action
    private let state: T

    private let disposable = SingleAssignmentDisposable()

    var isDisposed: Bool {
        disposable.isDisposed
    }

    init(action: @escaping Action, state: T) {
        self.action = action
        self.state = state
    }

    func invoke() {
        disposable.setDisposable(action(state))
    }

    func dispose() {
        disposable.dispose()
    }
}
