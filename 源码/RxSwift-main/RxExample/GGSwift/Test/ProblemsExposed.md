# GGObservable 的问题暴露 - 为什么需要 Producer

## 问题概述

你的 GGObservable 实现很简洁：
```swift
static func create(_ subscribe: @escaping (GGAnyObserver<Element>) -> GGDisposable) -> GGObservable<Element> {
    SimpleAnonymousObservable(subscribeHandler: subscribe)
}
```

但这个实现在以下场景会出现问题：

---

## 问题 1：CurrentThreadScheduler 死锁

### 场景描述
在 CurrentThreadScheduler 中订阅 Observable，会导致死锁。

### 问题代码
```swift
let scheduler = GGCurrentThreadScheduler.instance

scheduler.schedule(()) { _ in
    let observable = GGObservable<Int>.create { observer in
        observer.on(.next(1))
        observer.on(.completed)
        return GGDisposables.create()
    }
    
    // ❌ 这里会死锁！
    observable.subscribe(onNext: { value in
        print("收到: \(value)")
    }).disposed(by: DisposeBag())
    
    return GGDisposables.create()
}
```

### 为什么会死锁？

1. `scheduler.schedule()` 设置 `isScheduleRequired = false`
2. 在闭包中调用 `observable.subscribe()`
3. SimpleAnonymousObservable 直接调用 `subscribeHandler`
4. `subscribeHandler` 立即调用 `observer.on(.next(1))`
5. 但 CurrentThreadScheduler 已经在执行中，无法处理新的任务
6. 导致死锁

### 解决方案
Producer 检查 `isScheduleRequired`，如果已在调度中，重新调度：
```swift
if !GGCurrentThreadScheduler.isScheduleRequired {
    // 已经在调度中，重新调度
    return GGCurrentThreadScheduler.instance.schedule(()) { _ in
        return self.executeSubscription(observer)
    }
}
```

---

## 问题 2：事件转发不完整

### 场景描述
没有 Sink 的情况下，事件可能不完整或重复。

### 问题代码
```swift
var receivedEvents: [String] = []

let observable = GGObservable<Int>.create { observer in
    observer.on(.next(1))
    observer.on(.next(2))
    observer.on(.completed)
    observer.on(.next(3))  // ❌ 不应该发送！
    observer.on(.completed)  // ❌ 重复的完成事件！
    return GGDisposables.create()
}

observable.subscribe(onNext: { value in
    receivedEvents.append("next(\(value))")
}, onCompleted: {
    receivedEvents.append("completed")
}).disposed(by: DisposeBag())

print(receivedEvents)
// 输出：["next(1)", "next(2)", "completed", "next(3)", "completed"]
// ❌ 问题：收到了不应该的事件！
```

### 为什么会出现问题？

1. 没有 Sink 管理事件转发
2. 没有检查是否已经 disposed
3. 没有在 `.completed` 后立即 dispose
4. 导致后续事件继续被转发

### 解决方案
Sink 在 `.completed` 后立即 dispose，防止后续事件：
```swift
final class Sink<Observer>: Disposable {
    func on(_ event: Event<Element>) {
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
            dispose()  // ✅ 立即 dispose
        }
    }
}
```

---

## 问题 3：资源泄漏（并发场景）

### 场景描述
并发的 subscribe/dispose 操作导致资源泄漏。

### 问题代码
```swift
let initialCount = RxSwift.Resources.total
print("初始资源数: \(initialCount)")

var disposables: [GGDisposable] = []

// 并发创建 100 个订阅
DispatchQueue.concurrentPerform(iterations: 100) { i in
    let observable = GGObservable<Int>.create { observer in
        observer.on(.next(i))
        observer.on(.completed)
        return GGDisposables.create()
    }
    
    let disposable = observable.subscribe(onNext: { _ in })
    disposables.append(disposable)
}

// 立即 dispose
for disposable in disposables {
    disposable.dispose()
}

DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
    let finalCount = RxSwift.Resources.total
    print("最终资源数: \(finalCount)")
    
    if finalCount > initialCount {
        print("❌ 资源泄漏！泄漏了 \(finalCount - initialCount) 个资源")
    }
}
```

### 为什么会泄漏？

1. 没有 SinkDisposer 管理生命周期
2. 并发的 subscribe/dispose 操作
3. 如果 dispose 在 Sink 设置之前调用，Sink 可能无法被释放
4. 导致资源泄漏

### 解决方案
SinkDisposer 使用原子操作处理竞态条件：
```swift
final class SinkDisposer: Cancelable {
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

## 问题 4：操作符链中的事件丢失

### 场景描述
在操作符链中，没有 Sink 管理会导致事件丢失。

### 问题代码
```swift
var receivedValues: [Int] = []

let observable = GGObservable<Int>.create { observer in
    for i in 0..<100 {
        observer.on(.next(i))
    }
    observer.on(.completed)
    return GGDisposables.create()
}

// 如果有 map 操作符（需要 Sink）
observable
    .map { $0 * 2 }  // ❌ 没有 Sink，事件可能丢失
    .subscribe(onNext: { value in
        receivedValues.append(value)
    })
    .disposed(by: DisposeBag())

print("收到 \(receivedValues.count) 个值（期望 100 个）")
// ❌ 可能只收到部分值
```

### 为什么会丢失？

1. 没有 Sink 确保事件完整性
2. 没有事件转发的同步机制
3. 在高并发场景下，事件可能被丢弃

### 解决方案
Sink 确保事件按顺序、完整地转发。

---

## 问题 5：错误处理不完整

### 场景描述
没有 Sink 的情况下，错误处理可能不完整。

### 问题代码
```swift
var errorReceived = false
var nextReceived = false

let observable = GGObservable<Int>.create { observer in
    observer.on(.next(1))
    observer.on(.error(NSError(domain: "test", code: 1)))
    observer.on(.next(2))  // ❌ 不应该发送！
    return GGDisposables.create()
}

observable.subscribe(
    onNext: { value in
        nextReceived = true
        print("收到值: \(value)")
    },
    onError: { error in
        errorReceived = true
        print("收到错误: \(error)")
    }
).disposed(by: DisposeBag())

print("错误: \(errorReceived), 值: \(nextReceived)")
// ❌ 问题：错误后还收到了值！
```

### 为什么会出现问题？

1. 没有 Sink 在错误后立即 dispose
2. 导致后续事件继续被转发

### 解决方案
Sink 在 `.error` 后立即 dispose。

---

## 问题 6：多次订阅的状态管理

### 场景描述
同一个 Observable 多次订阅时，状态管理不当。

### 问题代码
```swift
var callCount = 0

let observable = GGObservable<Int>.create { observer in
    callCount += 1
    observer.on(.next(callCount))
    observer.on(.completed)
    return GGDisposables.create()
}

// 第一次订阅
observable.subscribe(onNext: { value in
    print("订阅1: \(value)")
}).disposed(by: DisposeBag())

// 第二次订阅
observable.subscribe(onNext: { value in
    print("订阅2: \(value)")
}).disposed(by: DisposeBag())

// 输出：
// 订阅1: 1
// 订阅2: 2
// ✅ 这是正确的（cold observable）
```

这个问题不是 GGObservable 的问题，而是设计特性。但 Producer 确保了这个行为的一致性。

---

## 总结：为什么需要 Producer？

| 问题 | 原因 | 解决方案 | 位置 |
|------|------|--------|------|
| 死锁 | CurrentThreadScheduler 中的递归调用 | 检查 isScheduleRequired，重新调度 | Producer.subscribe() |
| 事件不完整 | 没有事件管理 | Sink 防止重复事件 | AnonymousObservableSink.on() |
| 资源泄漏 | 并发竞态条件 | SinkDisposer 处理竞态 | SinkDisposer.dispose() |
| 事件丢失 | 没有同步机制 | Sink 确保事件完整性 | Sink.forwardOn() |
| 错误处理不完整 | 没有在错误后 dispose | Sink 在错误后立即 dispose | AnonymousObservableSink.on() |

---

## 下一步

1. **运行测试** - 看到这些问题的实际表现
2. **理解问题** - 为什么会出现这些问题
3. **添加 Producer** - 逐步添加 Producer 来解决这些问题
4. **验证解决** - 确认问题已解决

---

## 关键认识

**Producer 不是为了"线程安全"，而是为了：**

1. ✅ 防止死锁（CurrentThreadScheduler 检查）
2. ✅ 管理事件完整性（Sink 管理）
3. ✅ 处理并发竞态（SinkDisposer 管理）
4. ✅ 确保错误处理完整（Sink 在错误后 dispose）
5. ✅ 支持操作符链（Sink 确保事件转发）

这些都是 **Observable 基础设施** 的问题，不是用户代码的问题。
