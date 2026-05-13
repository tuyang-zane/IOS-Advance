# 🛠️ 实现指南 - 从 SimpleAnonymousObservable 到 Sink

## 当前实现

### SimpleAnonymousObservable（简单版）

```swift
final class SimpleAnonymousObservable<Element>: GGObservable<Element> {
    typealias SubscribeHandler = (GGAnyObserver<Element>) -> GGDisposable
    let subscribeHandler: SubscribeHandler
    
    init(subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func subscribe<Observer>(_ observer: Observer) -> GGDisposable {
        let anyObserver = GGAnyObserver(observer)
        return subscribeHandler(anyObserver)  // ❌ 直接调用，没有 Sink 管理
    }
}
```

**问题**：
- ❌ 没有检查是否已经 disposed
- ❌ 没有在 completed/error 后立即 dispose
- ❌ 没有确保事件的完整性

---

## 需要添加的文件

### 1. GGSink.swift（新文件）

**位置**：`/RxExample/GGSwift/GGSink.swift`

**作用**：
- 管理事件转发的完整性
- 在 completed 后立即 dispose
- 在 error 后立即 dispose
- 确保事件的同步和完整性

**实现**：

```swift
//
//  GGSink.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

// Sink 的作用：
// 1. 管理事件转发的完整性
// 2. 在 completed 后立即 dispose
// 3. 在 error 后立即 dispose
// 4. 确保事件的同步和完整性

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
        if fetchOr(disposed, 1) == 0 {
            cancel.dispose()
        }
    }
}
```

### 2. GGCancelable（新类型）

**位置**：`/RxExample/GGSwift/Disposables.swift`（添加到现有文件）

**作用**：
- 提供 `isDisposed` 属性
- 管理 dispose 状态

**实现**：

```swift
// 在 Disposables.swift 中添加

final class GGSimpleCancelable: GGCancelable {
    private let disposed = GGAtomicInt(0)
    
    var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }
    
    func dispose() {
        fetchOr(disposed, 1)
    }
}
```

### 3. 修改 Create.swift

**位置**：`/RxExample/GGSwift/Observables/Create.swift`

**修改内容**：
- 添加 `GGAnonymousObservableSink` 类
- 修改 `GGAnonymousObservable` 使用 Sink

**实现**：

```swift
// 添加 GGAnonymousObservableSink

final class GGAnonymousObservableSink<Observer: GGObserverType>: GGSink<Observer>, GGObserverType {
    typealias Element = Observer.Element
    typealias Parent = GGAnonymousObservable<Element>
    
    override init(observer: Observer, cancel: GGCancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
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

// 修改 GGAnonymousObservable

final class GGAnonymousObservable<Element>: GGObservable<Element> {
    typealias SubscribeHandler = (GGAnyObserver<Element>) -> GGDisposable
    
    let subscribeHandler: SubscribeHandler
    
    init(subscribeHandler: @escaping SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    override func subscribe<Observer: GGObserverType>(_ observer: Observer) -> GGDisposable {
        let sink = GGAnonymousObservableSink(observer: observer, cancel: GGSimpleCancelable())
        let subscription = sink.run(self)
        return subscription
    }
}
```

### 4. 修改 Observable.swift

**位置**：`/RxExample/GGSwift/Observable.swift`

**修改内容**：
- 修改 `GGObservable.create()` 使用 `GGAnonymousObservable`

**实现**：

```swift
extension GGObservable {
    static func create(_ subscribe: @escaping (GGAnyObserver<Element>) -> GGDisposable) -> GGObservable<Element> {
        GGAnonymousObservable(subscribeHandler: subscribe)  // ✅ 使用 GGAnonymousObservable
    }
}
```

---

## 实现步骤

### 第 1 步：创建 GGSink.swift

1. 在 Xcode 中右键点击 `/RxExample/GGSwift/` 文件夹
2. 选择 "New File..."
3. 选择 "Swift File"
4. 命名为 "GGSink.swift"
5. 复制上面的代码

### 第 2 步：修改 Disposables.swift

1. 打开 `/RxExample/GGSwift/Disposables.swift`
2. 在文件末尾添加 `GGSimpleCancelable` 类

### 第 3 步：修改 Create.swift

1. 打开 `/RxExample/GGSwift/Observables/Create.swift`
2. 添加 `GGAnonymousObservableSink` 类
3. 修改 `GGAnonymousObservable` 类

### 第 4 步：修改 Observable.swift

1. 打开 `/RxExample/GGSwift/Observable.swift`
2. 修改 `GGObservable.create()` 方法

---

## 验证实现

### 第 1 步：编译

1. 按 `Cmd + B` 编译项目
2. 确保没有编译错误

### 第 2 步：运行测试

1. 按 `Cmd + R` 运行应用
2. 打开 Console（`Cmd + Shift + C`）
3. 查看测试输出

### 第 3 步：验证结果

你应该看到：

```
✅ 事件完整且正确
   原因：Sink 在 completed 后立即 dispose

✅ 错误处理完整
   原因：Sink 在 error 后立即 dispose

✅ 多次订阅一致性正确
   原因：每次订阅都独立执行 subscribeHandler

✅ 没有事件丢失
   原因：Sink 确保了事件的完整性
```

---

## 关键概念

### Sink 的工作流程

```
1. 创建 Sink
   ↓
2. 调用 subscribeHandler
   ↓
3. subscribeHandler 发送事件
   ↓
4. Sink.on() 接收事件
   ↓
5. 检查是否已 disposed
   ↓
6. 转发事件给 observer
   ↓
7. 如果是 completed/error，立即 dispose
   ↓
8. 后续事件被忽略（因为已 disposed）
```

### 原子操作

```swift
// isFlagSet - 检查标志位是否被设置
if isFlagSet(disposed, 1) {
    return  // 已经 disposed，不转发
}

// fetchOr - 原子操作：读取当前值，然后设置新值
if fetchOr(disposed, 1) == 0 {
    // 第一次调用 dispose
    cancel.dispose()
}
```

---

## 常见错误

### 错误 1：忘记在 completed/error 后 dispose

```swift
// ❌ 错误
func on(_ event: GGEvent<Observer.Element>) {
    switch event {
    case .next:
        forwardOn(event)
    case .error, .completed:
        forwardOn(event)
        // ❌ 忘记 dispose()
    }
}

// ✅ 正确
func on(_ event: GGEvent<Observer.Element>) {
    switch event {
    case .next:
        forwardOn(event)
    case .error, .completed:
        forwardOn(event)
        dispose()  // ✅ 立即 dispose
    }
}
```

### 错误 2：没有检查 disposed 状态

```swift
// ❌ 错误
final func forwardOn(_ event: GGEvent<Observer.Element>) {
    observer.on(event)  // ❌ 没有检查 disposed
}

// ✅ 正确
final func forwardOn(_ event: GGEvent<Observer.Element>) {
    if isFlagSet(disposed, 1) {
        return  // ✅ 已经 disposed，不转发
    }
    observer.on(event)
}
```

### 错误 3：没有使用原子操作

```swift
// ❌ 错误
private var disposed = false

func dispose() {
    disposed = true  // ❌ 不是原子操作，线程不安全
}

// ✅ 正确
private let disposed = GGAtomicInt(0)

func dispose() {
    if fetchOr(disposed, 1) == 0 {  // ✅ 原子操作
        cancel.dispose()
    }
}
```

---

## 下一步

1. ✅ 理解 Sink 的作用
2. ⏳ 创建 GGSink.swift
3. ⏳ 修改 Disposables.swift
4. ⏳ 修改 Create.swift
5. ⏳ 修改 Observable.swift
6. ⏳ 运行测试，验证修复

---

## 参考资源

### RxSwift 源码

- **Sink.swift** - RxSwift 的 Sink 实现
- **AnonymousObservable.swift** - RxSwift 的 AnonymousObservable 实现

### 文档

- **START_HERE.md** - 学习指南
- **ProblemsExposed.md** - 问题详解
- **NEXT_STEPS.md** - 接下来的步骤

---

**现在就开始实现吧！** 🚀
