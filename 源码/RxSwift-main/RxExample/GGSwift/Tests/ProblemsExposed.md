# GGObservable 的问题暴露 - 为什么需要 Sink

## 问题概述

你的 GGObservable 实现很简洁：
```swift
static func create(_ subscribe: @escaping (GGAnyObserver<Element>) -> GGDisposable) -> GGObservable<Element> {
    SimpleAnonymousObservable(subscribeHandler: subscribe)
}
```

但这个实现在以下场景会出现问题：

---

## 问题 1：事件转发不完整

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

## 问题 2：错误处理不完整

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

## 问题 3：多次订阅的一致性

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

这个问题不是 GGObservable 的问题，而是设计特性。每次订阅都独立执行 subscribeHandler。

---

## 问题 4：高并发场景下的事件丢失

### 场景描述
在高并发场景下，没有 Sink 管理会导致事件丢失。

### 问题代码
```swift
let expectedCount = 1000
var receivedCount = 0

let observable = GGObservable<Int>.create { observer in
    DispatchQueue.concurrentPerform(iterations: expectedCount) { i in
        observer.on(.next(i))
    }
    observer.on(.completed)
    return GGDisposables.create()
}

observable.subscribe(onNext: { _ in
    receivedCount += 1
}).disposed(by: DisposeBag())

print("收到 \(receivedCount) 个值（期望 \(expectedCount) 个）")
// ❌ 可能只收到部分值
```

### 为什么会丢失？

1. 没有 Sink 确保事件的同步
2. 在高并发场景下，事件可能被丢弃

### 解决方案
Sink 确保事件按顺序、完整地转发。

---

## 总结：为什么需要 Sink？

| 问题 | 原因 | 解决方案 |
|------|------|--------|
| 事件不完整 | 没有事件管理 | Sink 防止重复事件 |
| 错误处理不完整 | 没有在错误后 dispose | Sink 在错误后立即 dispose |
| 多次订阅一致性 | 每次订阅独立执行 | 已正确（无需修改） |
| 事件丢失 | 没有同步机制 | Sink 确保事件完整性 |

---

## 下一步

1. **运行测试** - 看到这些问题的实际表现
2. **理解问题** - 为什么会出现这些问题
3. **添加 Sink** - 逐步添加 Sink 来解决这些问题
4. **验证解决** - 确认问题已解决

---

## 关键认识

**Sink 的作用**：

1. ✅ 管理事件完整性（防止重复事件）
2. ✅ 在 completed 后立即 dispose
3. ✅ 在 error 后立即 dispose
4. ✅ 确保事件的同步和完整性

这些都是 **Observable 基础设施** 的问题，不是用户代码的问题。

**Producer 的作用**（后续学习）：

1. ✅ 防止死锁（CurrentThreadScheduler 检查）
2. ✅ 处理并发竞态（SinkDisposer 管理）
3. ✅ 确保一致性（每次订阅都独立执行）

现在先专注于理解 Sink 的必要性。
