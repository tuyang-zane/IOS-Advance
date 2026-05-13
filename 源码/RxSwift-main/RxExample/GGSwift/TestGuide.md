# Producer 问题演示 - 测试指南

## 如何运行测试

### 方法 1：在 AppDelegate 中运行（推荐）

1. 打开 `/RxExample/RxExample/iOS/AppDelegate.swift`
2. 运行 iOS 应用
3. 应用启动后 1 秒，会自动运行三个测试
4. 查看 Xcode 的 Console 输出

### 方法 2：手动运行

在 AppDelegate 中添加：
```swift
DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
    self.testProducerNecessity()
}
```

---

## 三个测试详解

### 测试 1：CurrentThreadScheduler 死锁

**代码**：
```swift
func testCurrentThreadSchedulerDeadlock() {
    let scheduler = CurrentThreadScheduler.instance
    var completed = false
    let semaphore = DispatchSemaphore(value: 0)
    
    scheduler.schedule(()) { _ in
        // 在 CurrentThreadScheduler 中订阅
        let observable = Observable<Int>.create { observer in
            observer.on(.next(1))
            observer.on(.completed)
            return Disposables.create()
        }
        
        observable.subscribe(onNext: { value in
            print("✅ 收到值: \(value)")
        }, onCompleted: {
            print("✅ 完成")
            completed = true
            semaphore.signal()
        }).disposed(by: DisposeBag())
        
        return Disposables.create()
    }
    
    // 等待结果（3 秒超时）
    let result = semaphore.wait(timeout: .now() + .seconds(3))
    if result == .timedOut {
        print("❌ 死锁！")
    } else if completed {
        print("✅ 没有死锁")
    }
}
```

**预期结果**：
- ✅ 使用 RxSwift 的 Observable：正常完成，没有死锁
- ✅ 使用 GGAnonymousObservable（有 Producer）：正常完成，没有死锁
- ❌ 使用 SimpleAnonymousObservable（无 Producer）：死锁！

**为什么会死锁**：
1. `scheduler.schedule()` 设置 `isScheduleRequired = false`
2. 在闭包中调用 `observable.subscribe()`
3. SimpleAnonymousObservable 直接调用 `subscribeHandler`
4. 但 CurrentThreadScheduler 已经在执行中，无法处理新的任务
5. 导致死锁

**Producer 如何解决**：
```swift
override func subscribe<Observer>(_ observer: Observer) -> Disposable {
    if !CurrentThreadScheduler.isScheduleRequired {
        // 已经在调度中，重新调度
        return CurrentThreadScheduler.instance.schedule(()) { _ in
            return self.executeSubscription(observer)
        }
    } else {
        // 不在调度中，直接执行
        return executeSubscription(observer)
    }
}
```

---

### 测试 2：事件丢失

**代码**：
```swift
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
        print("✅ 收到 \(receivedCount) 个事件")
    } else {
        print("❌ 只收到 \(receivedCount) 个，丢失了 \(expectedCount - receivedCount) 个")
    }
}
```

**预期结果**：
- ✅ 使用 RxSwift 的 Observable：收到所有 100 个事件
- ✅ 使用 GGAnonymousObservable（有 Sink）：收到所有 100 个事件
- ⚠️ 使用 SimpleAnonymousObservable：通常也能收到所有事件（但没有保证）

**为什么可能丢失**：
1. 没有 Sink 的情况下，事件直接转发给 observer
2. 如果 observer 在处理事件时抛出异常，后续事件可能丢失
3. 没有 `.error` 或 `.completed` 后的 dispose，可能导致资源泄漏

**Sink 如何保证**：
```swift
final class Sink<Observer>: Disposable {
    final func forwardOn(_ event: Event<Observer.Element>) {
        if isFlagSet(disposed, 1) {
            return  // ✅ 已经 disposed，不转发
        }
        observer.on(event)
    }
}

final class AnonymousObservableSink<Observer>: Sink<Observer> {
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            forwardOn(event)
        case .error, .completed:
            forwardOn(event)
            dispose()  // ✅ 立即 dispose，防止重复事件
        }
    }
}
```

---

### 测试 3：资源泄漏

**代码**：
```swift
func testResourceLeak() {
    let initialCount = RxSwift.Resources.total
    print("初始资源数: \(initialCount)")
    
    let semaphore = DispatchSemaphore(value: 0)
    var disposeBag: DisposeBag? = DisposeBag()
    
    DispatchQueue.concurrentPerform(iterations: 100) { _ in
        let observable = Observable<Int>.create { observer in
            observer.on(.next(1))
            observer.on(.completed)
            return Disposables.create()
        }
        
        observable.subscribe(onNext: { _ in
            // 处理事件
        }).disposed(by: disposeBag!)
    }
    
    disposeBag = nil
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
        let finalCount = RxSwift.Resources.total
        print("最终资源数: \(finalCount)")
        
        if finalCount == initialCount {
            print("✅ 资源正确释放")
        } else {
            print("❌ 资源泄漏！泄漏了 \(finalCount - initialCount) 个资源")
        }
        
        semaphore.signal()
    }
    
    semaphore.wait()
}
```

**预期结果**：
- ✅ 使用 RxSwift 的 Observable：资源正确释放
- ✅ 使用 GGAnonymousObservable（有 SinkDisposer）：资源正确释放
- ❌ 使用 SimpleAnonymousObservable：可能泄漏资源

**为什么会泄漏**：
1. 并发的 subscribe/dispose 操作
2. 如果 dispose 在 Sink 设置之前调用，Sink 可能无法被释放
3. 如果 Sink 设置在 dispose 之后调用，Subscription 可能无法被释放

**SinkDisposer 如何解决**：
```swift
final class SinkDisposer: Cancelable {
    private enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        let previousState = fetchOr(state, DisposeState.sinkAndSubscriptionSet.rawValue)
        
        // 如果在设置之前就已经被 dispose 了，立即清理
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            sink.dispose()
            subscription.dispose()
        }
    }
    
    func dispose() {
        let previousState = fetchOr(state, DisposeState.disposed.rawValue)
        
        // 如果 Sink 和 Subscription 已经设置了，执行清理
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            sink?.dispose()
            subscription?.dispose()
        }
    }
}
```

---

## 如何自己验证

### 步骤 1：使用 SimpleAnonymousObservable 测试

修改 AppDelegate 中的测试代码：
```swift
let observable = SimpleAnonymousObservable<Int> { observer in
    observer.on(.next(1))
    observer.on(.completed)
    return GGDisposables.create()
}
```

### 步骤 2：使用 GGAnonymousObservable 测试

修改 AppDelegate 中的测试代码：
```swift
let observable = GGAnonymousObservable<Int> { observer in
    observer.on(.next(1))
    observer.on(.completed)
    return GGDisposables.create()
}
```

### 步骤 3：对比结果

- 哪个版本通过了所有测试？
- 哪个版本失败了？
- 为什么会失败？

---

## 深入理解

### 问题 1：为什么 CurrentThreadScheduler 会死锁？

**关键概念**：CurrentThreadScheduler 使用"蹦床"模式

```
初始状态：isScheduleRequired = true

scheduler.schedule(block1) {
    isScheduleRequired = false  // 标记开始调度
    
    // 在这里调用 subscribe
    observable.subscribe(observer)
    
    // 如果 subscribe 直接执行（没有 Producer 检查）
    // 就会尝试在已经在调度中的线程上执行
    // 导致死锁
    
    isScheduleRequired = true   // 标记调度结束
}
```

**Producer 的解决方案**：
```
if !CurrentThreadScheduler.isScheduleRequired {
    // 已经在调度中，重新调度
    return CurrentThreadScheduler.instance.schedule(()) { _ in
        // 这会被加入队列，等待当前任务完成后执行
        return self.executeSubscription(observer)
    }
}
```

### 问题 2：为什么需要 Sink？

**关键概念**：事件的完整性和顺序性

```
没有 Sink：
observer.on(.next(1))
observer.on(.next(2))
observer.on(.completed)
observer.on(.next(3))  // ❌ 不应该发送！

有 Sink：
observer.on(.next(1))
observer.on(.next(2))
observer.on(.completed)
dispose()  // ✅ 立即 dispose
observer.on(.next(3))  // ✅ 被忽略，因为已经 disposed
```

### 问题 3：为什么需要 SinkDisposer？

**关键概念**：竞态条件的处理

```
场景 1：dispose 在 setSinkAndSubscription 之前
disposable.dispose()  // 设置 disposed = true
setSinkAndSubscription(sink, subscription)  // 检查到 disposed，立即清理

场景 2：dispose 在 setSinkAndSubscription 之后
setSinkAndSubscription(sink, subscription)  // 保存引用
disposable.dispose()  // 清理 sink 和 subscription

两种情况都能正确处理！
```

---

## 总结

| 问题 | 原因 | 解决方案 | 位置 |
|------|------|--------|------|
| 死锁 | CurrentThreadScheduler 中的递归调用 | 检查 isScheduleRequired，重新调度 | Producer.subscribe() |
| 事件丢失 | 没有事件管理 | Sink 防止重复事件 | AnonymousObservableSink.on() |
| 资源泄漏 | 并发竞态条件 | SinkDisposer 处理竞态 | SinkDisposer.dispose() |

---

## 下一步

1. ✅ 理解 Producer 的三个职责
2. ✅ 运行测试，看到问题
3. ⏳ 修改测试代码，对比 SimpleAnonymousObservable 和 GGAnonymousObservable
4. ⏳ 阅读 RxSwift 源码，理解真实实现
5. ⏳ 开始实现操作符（map, filter, flatMap 等）

加油！🚀
