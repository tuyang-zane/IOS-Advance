# 如何使用问题暴露测试

## 目标

通过运行测试，**看到 GGObservable 的真实问题**，然后理解为什么需要 Producer。

---

## 快速开始

### 步骤 1：运行 iOS 应用

1. 打开 Xcode
2. 选择 RxExample-iOS scheme
3. 运行应用
4. 应用启动后 1 秒，会自动运行问题暴露测试
5. 查看 Xcode 的 Console 输出

### 步骤 2：查看测试结果

Console 会输出 6 个问题的测试结果：

```
╔════════════════════════════════════════════════════════════╗
║ 问题 1：CurrentThreadScheduler 死锁                        ║
╚════════════════════════════════════════════════════════════╝

❌ 死锁！CurrentThreadScheduler 中的订阅导致死锁
   原因：没有 Producer 检查 isScheduleRequired

╔════════════════════════════════════════════════════════════╗
║ 问题 2：事件转发不完整                                      ║
╚════════════════════════════════════════════════════════════╝

❌ 问题：收到了不应该的事件 next(3)
   原因：没有 Sink 在 completed 后立即 dispose

... 等等
```

---

## 理解每个问题

### 问题 1：CurrentThreadScheduler 死锁

**代码**：
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

**为什么会死锁？**

1. `scheduler.schedule()` 设置 `isScheduleRequired = false`
2. 在闭包中调用 `observable.subscribe()`
3. SimpleAnonymousObservable 直接调用 `subscribeHandler`
4. 但 CurrentThreadScheduler 已经在执行中，无法处理新的任务
5. 导致死锁

**解决方案**：Producer 检查 `isScheduleRequired`，如果已在调度中，重新调度

---

### 问题 2：事件转发不完整

**代码**：
```swift
let observable = GGObservable<Int>.create { observer in
    observer.on(.next(1))
    observer.on(.next(2))
    observer.on(.completed)
    observer.on(.next(3))  // ❌ 不应该发送！
    observer.on(.completed)  // ❌ 重复的完成事件！
    return GGDisposables.create()
}
```

**为什么会出现问题？**

1. 没有 Sink 管理事件转发
2. 没有检查是否已经 disposed
3. 没有在 `.completed` 后立即 dispose
4. 导致后续事件继续被转发

**解决方案**：Sink 在 `.completed` 后立即 dispose

---

### 问题 3：资源泄漏（并发场景）

**代码**：
```swift
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
```

**为什么会泄漏？**

1. 并发的 subscribe/dispose 操作
2. 如果 dispose 在 Sink 设置之前调用，Sink 可能无法被释放
3. 导致资源泄漏

**解决方案**：SinkDisposer 使用原子操作处理竞态条件

---

### 问题 4：错误处理不完整

**代码**：
```swift
let observable = GGObservable<Int>.create { observer in
    observer.on(.next(1))
    observer.on(.error(NSError(domain: "test", code: 1)))
    observer.on(.next(2))  // ❌ 不应该发送！
    return GGDisposables.create()
}
```

**为什么会出现问题？**

1. 没有 Sink 在错误后立即 dispose
2. 导致后续事件继续被转发

**解决方案**：Sink 在 `.error` 后立即 dispose

---

### 问题 5：多次订阅的一致性

**代码**：
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
```

**预期**：
- 订阅1 收到 1
- 订阅2 收到 2

**为什么需要 Producer？**

Producer 确保了每次订阅都独立执行 subscribeHandler，保证一致的行为。

---

### 问题 6：高并发场景下的事件丢失

**代码**：
```swift
let observable = GGObservable<Int>.create { observer in
    DispatchQueue.concurrentPerform(iterations: 1000) { i in
        observer.on(.next(i))
    }
    observer.on(.completed)
    return GGDisposables.create()
}
```

**为什么会丢失？**

1. 没有 Sink 确保事件的同步
2. 在高并发场景下，事件可能被丢弃

**解决方案**：Sink 确保事件按顺序、完整地转发

---

## 如何修复这些问题

### 步骤 1：添加 Sink

创建 `Sink.swift`：
```swift
class GGSink<Observer: GGObserverType>: GGDisposable {
    fileprivate let observer: Observer
    fileprivate let cancel: GGCancelable
    private let disposed = GGAtomicInt(0)
    
    init(observer: Observer, cancel: GGCancelable) {
        self.observer = observer
        self.cancel = cancel
    }
    
    final func forwardOn(_ event: GGEvent<Observer.Element>) {
        if isFlagSet(disposed, 1) {
            return  // ✅ 已经 disposed，不转发
        }
        observer.on(event)
    }
    
    func dispose() {
        fetchOr(disposed, 1)
        cancel.dispose()
    }
}
```

### 步骤 2：添加 Producer

修改 `Producer.swift`：
```swift
class GGProducer<Element>: GGObservable<Element> {
    override func subscribe<Observer: GGObserverType>(_ observer: Observer) -> GGDisposable {
        // 【关键】检查是否在 CurrentThreadScheduler 中
        if !GGCurrentThreadScheduler.isScheduleRequired {
            return executeSubscription(observer)
        } else {
            return GGCurrentThreadScheduler.instance.schedule(()) { _ in
                return self.executeSubscription(observer)
            }
        }
    }
    
    private func executeSubscription<Observer: GGObserverType>(_ observer: Observer) -> GGDisposable {
        let disposer = GGSinkDisposer()
        let sinkAndSubscription = self.run(observer, cancel: disposer)
        disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
        return disposer
    }
    
    func run<Observer: GGObserverType>(_: Observer, cancel _: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) {
        GGrxAbstractMethod()
    }
}
```

### 步骤 3：修改 GGAnonymousObservable

```swift
final class GGAnonymousObservable<Element>: GGProducer<Element> {
    typealias SubscribeHandler = (GGAnyObserver<Element>) -> GGDisposable
    
    let subscribeHandler: SubscribeHandler
    
    init(subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func run<Observer: GGObserverType>(_ observer: Observer, cancel: GGCancelable) -> (sink: GGDisposable, subscription: GGDisposable) {
        let sink = GGAnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}

final class GGAnonymousObservableSink<Observer: GGObserverType>: GGSink<Observer>, GGObserverType {
    typealias Element = Observer.Element
    typealias Parent = GGAnonymousObservable<Element>
    
    func on(_ event: GGEvent<Observer.Element>) {
        switch event {
        case .next:
            forwardOn(event)
        case .error, .completed:
            forwardOn(event)
            dispose()  // ✅ 立即 dispose
        }
    }
    
    func run(_ parent: Parent) -> GGDisposable {
        parent.subscribeHandler(GGAnyObserver(self))
    }
}
```

---

## 验证修复

修复后，再次运行测试，应该看到：

```
✅ 没有死锁，正常完成
✅ 事件完整且正确
✅ 资源正确释放
✅ 错误处理完整
✅ 多次订阅一致性正确
✅ 没有事件丢失
```

---

## 学习流程

1. **运行测试** - 看到问题
2. **理解问题** - 为什么会出现这些问题
3. **添加 Sink** - 解决事件管理问题
4. **添加 Producer** - 解决死锁和并发问题
5. **验证修复** - 确认问题已解决

---

## 关键认识

**Producer 不是为了"线程安全"，而是为了：**

1. ✅ 防止死锁（CurrentThreadScheduler 检查）
2. ✅ 管理事件完整性（Sink 管理）
3. ✅ 处理并发竞态（SinkDisposer 管理）
4. ✅ 确保错误处理完整（Sink 在错误后 dispose）
5. ✅ 支持操作符链（Sink 确保事件转发）

这些都是 **Observable 基础设施** 的问题，不是用户代码的问题。

---

## 下一步

1. ✅ 运行测试，看到问题
2. ✅ 理解每个问题的原因
3. ⏳ 逐步添加 Sink 和 Producer
4. ⏳ 验证问题已解决
5. ⏳ 开始实现操作符（map, filter, flatMap）

加油！🚀
