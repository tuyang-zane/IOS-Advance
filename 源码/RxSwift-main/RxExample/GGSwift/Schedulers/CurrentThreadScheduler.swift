//
//  CurrentThreadScheduler.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// 当前线程调度器 - 用于防止死锁
/// 核心思想：
/// 1. 使用 pthread_key 存储线程本地状态
/// 2. isScheduleRequired 标记是否需要调度
/// 3. 如果已经在调度中，新的任务会被加入队列而不是直接执行
class GGCurrentThreadScheduler {
    static let instance = GGCurrentThreadScheduler()
    
    private static let isScheduleRequiredKey: pthread_key_t = {
        let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
        defer { key.deallocate() }
        
        guard pthread_key_create(key, nil) == 0 else {
            fatalError("isScheduleRequired key creation failed")
        }
        
        return key.pointee
    }()
    
    private static let scheduleInProgressSentinel: UnsafeRawPointer = {
        return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
    }()
    
    /// 获取当前线程的调度队列
    private static var queue: [() -> Void]? {
        get {
            let value = pthread_getspecific(isScheduleRequiredKey)
            if value == nil {
                return nil
            }
            // 从 TLS 中获取队列（简化版本，实际使用 Thread.threadDictionary）
            return Thread.current.threadDictionary["GGScheduleQueue"] as? [() -> Void]
        }
        set {
            Thread.current.threadDictionary["GGScheduleQueue"] = newValue
        }
    }
    
    /// 是否需要调度
    /// - 如果返回 true，说明当前不在调度中，可以直接执行
    /// - 如果返回 false，说明已经在调度中，需要加入队列
    static var isScheduleRequired: Bool {
        get {
            pthread_getspecific(isScheduleRequiredKey) == nil
        }
        set(isScheduleRequired) {
            if pthread_setspecific(isScheduleRequiredKey, isScheduleRequired ? nil : scheduleInProgressSentinel) != 0 {
                fatalError("pthread_setspecific failed")
            }
        }
    }
    
    /// 调度一个任务
    /// - 如果当前不在调度中，直接执行任务
    /// - 如果已经在调度中，将任务加入队列
    func schedule<T>(_ state: T, action: @escaping (T) -> GGDisposable) -> GGDisposable {
        if GGCurrentThreadScheduler.isScheduleRequired {
            // 标记开始调度
            GGCurrentThreadScheduler.isScheduleRequired = false
            
            // 执行任务
            let disposable = action(state)
            
            defer {
                // 标记调度结束
                GGCurrentThreadScheduler.isScheduleRequired = true
                GGCurrentThreadScheduler.queue = nil
            }
            
            // 处理队列中的所有任务（递归调用时被加入的）
            while var queue = GGCurrentThreadScheduler.queue, !queue.isEmpty {
                let task = queue.removeFirst()
                GGCurrentThreadScheduler.queue = queue
                task()
            }
            
            return disposable
        }
        
        // 已经在调度中，将任务加入队列（延迟执行，不是立即执行！）
        var queue = GGCurrentThreadScheduler.queue ?? []
        queue.append {
            _ = action(state)  // ✅ 包在闭包里，延迟执行
        }
        GGCurrentThreadScheduler.queue = queue
        
        return GGDisposables.create()
    }
}
