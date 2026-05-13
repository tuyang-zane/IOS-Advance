# RxSwift 学习计划 - 第二阶段

## 当前进度

✅ **第一阶段完成**：基础协议和简单实现
- Event, Observer, Observable, Disposable, AnyObserver
- SimpleAnonymousObservable（最简版）
- GGAnonymousObservable + Producer + Sink（完整版）

---

## 第二阶段：操作符和调度器

### 目标
理解 RxSwift 的操作符系统和调度器机制，学习如何构建可组合的异步操作。

### 核心概念

#### 1. 操作符基础
- **什么是操作符**：转换 Observable 的函数
- **操作符的分类**：
  - 创建操作符：`create`, `just`, `from`, `range`
  - 转换操作符：`map`, `flatMap`, `filter`
  - 组合操作符：`merge`, `zip`, `combineLatest`
  - 时间操作符：`delay`, `debounce`, `throttle`

#### 2. 操作符的实现模式
```swift
// 所有操作符都遵循这个模式：
// 1. 创建一个新的 Observable
// 2. 在 subscribe 时，订阅源 Observable
// 3. 通过 Sink 转发和转换事件
```

#### 3. 调度器（Scheduler）
- **CurrentThreadScheduler**：当前线程（已实现）
- **MainScheduler**：主线程
- **BackgroundScheduler**：后台线程
- **SerialDispatchQueueScheduler**：串行队列
- **ConcurrentDispatchQueueScheduler**：并发队列

---

## 第二阶段的学习路径

### 阶段 2.1：实现基础操作符（1-2 天）

**目标**：实现 5 个基础操作符

1. **map** - 最简单的转换操作符
   ```swift
   observable.map { $0 * 2 }
   ```
   - 学习点：如何转换事件值
   - 难度：⭐

2. **filter** - 条件过滤
   ```swift
   observable.filter { $0 > 5 }
   ```
   - 学习点：如何选择性转发事件
   - 难度：⭐

3. **flatMap** - 最重要的操作符
   ```swift
   observable.flatMap { value in
       Observable.just(value * 2)
   }
   ```
   - 学习点：如何处理嵌套 Observable
   - 难度：⭐⭐⭐

4. **merge** - 合并多个 Observable
   ```swift
   Observable.merge([obs1, obs2, obs3])
   ```
   - 学习点：如何管理多个订阅
   - 难度：⭐⭐

5. **zip** - 配对合并
   ```swift
   Observable.zip(obs1, obs2) { a, b in (a, b) }
   ```
   - 学习点：如何同步多个 Observable
   - 难度：⭐⭐⭐

### 阶段 2.2：实现调度器（1-2 天）

**目标**：实现 3 个调度器

1. **MainScheduler** - 主线程调度
   - 学习点：DispatchQueue.main
   - 难度：⭐

2. **BackgroundScheduler** - 后台线程调度
   - 学习点：DispatchQueue.global()
   - 难度：⭐

3. **SerialDispatchQueueScheduler** - 串行队列调度
   - 学习点：自定义 DispatchQueue
   - 难度：⭐⭐

### 阶段 2.3：操作符与调度器的结合（1-2 天）

**目标**：理解 `observeOn` 和 `subscribeOn`

```swift
observable
    .subscribeOn(BackgroundScheduler())  // 在后台线程订阅
    .map { /* 在后台线程执行 */ }
    .observeOn(MainScheduler())          // 切换到主线程
    .subscribe(onNext: { /* 在主线程执行 */ })
```

---

## 第三阶段：高级特性（预计 2-3 天）

### 目标
理解 RxSwift 的高级特性和最佳实践

1. **Subject** - 既是 Observable 又是 Observer
   - PublishSubject
   - ReplaySubject
   - BehaviorSubject

2. **错误处理**
   - `catchError`
   - `retry`
   - `retryWhen`

3. **资源管理**
   - `using`
   - `refCount`
   - DisposeBag 的最佳实践

4. **性能优化**
   - 背压处理
   - 内存泄漏防止
   - 调度器选择

---

## 学习方法

### 对每个操作符/调度器：

1. **理解概念**
   - 读 RxSwift 文档
   - 看 RxSwift 源码实现
   - 理解设计意图

2. **自己实现**
   - 从零开始写代码
   - 不要复制粘贴
   - 遇到问题时查看源码

3. **写测试**
   - 测试正常情况
   - 测试边界情况
   - 测试错误情况

4. **对比学习**
   - 对比自己的实现和 RxSwift 的实现
   - 理解差异的原因
   - 学习最佳实践

---

## 代码组织

```
GGSwift/
├── Observables/
│   ├── Create.swift          ✅ 已完成
│   ├── Producer.swift        ✅ 已完成
│   ├── Sink.swift            ✅ 已完成
│   ├── Map.swift             ⏳ 待实现
│   ├── Filter.swift          ⏳ 待实现
│   ├── FlatMap.swift         ⏳ 待实现
│   ├── Merge.swift           ⏳ 待实现
│   └── Zip.swift             ⏳ 待实现
├── Schedulers/
│   ├── CurrentThreadScheduler.swift  ✅ 已完成
│   ├── MainScheduler.swift           ⏳ 待实现
│   ├── BackgroundScheduler.swift     ⏳ 待实现
│   └── SerialDispatchQueueScheduler.swift  ⏳ 待实现
├── Subjects/
│   ├── PublishSubject.swift  ⏳ 待实现
│   ├── ReplaySubject.swift   ⏳ 待实现
│   └── BehaviorSubject.swift ⏳ 待实现
└── Tests/
    ├── MapTests.swift        ⏳ 待实现
    ├── FilterTests.swift     ⏳ 待实现
    └── ...
```

---

## 下一步行动

### 立即开始（今天）

1. **阅读本文档**，理解学习路径
2. **阅读 ProducerPattern.md**，深入理解 Producer 的三个职责
3. **运行 AppDelegate 中的测试**，看看 Producer 解决的问题

### 明天开始

1. **实现 map 操作符**
   - 参考：`/RxSwift/Operators/Map.swift`
   - 难度：最简单，适合入门

2. **写测试验证**
   - 测试基本功能
   - 测试错误处理
   - 测试资源释放

3. **对比学习**
   - 对比自己的实现和 RxSwift 的实现
   - 理解差异

---

## 学习资源

### 官方文档
- [RxSwift GitHub](https://github.com/ReactiveX/RxSwift)
- [RxSwift Documentation](https://github.com/ReactiveX/RxSwift/tree/main/Documentation)

### 推荐阅读
- `Documentation/DesignRationale.md` - 设计理念
- `Documentation/Traits.md` - 特殊类型
- `Documentation/Schedulers.md` - 调度器详解

### 源码位置
- 操作符：`/RxSwift/Operators/`
- 调度器：`/RxSwift/Schedulers/`
- 核心：`/RxSwift/Observables/`

---

## 预期收获

完成第二阶段后，你将：

✅ 理解 RxSwift 的操作符系统
✅ 能够实现自己的操作符
✅ 理解调度器的工作原理
✅ 能够处理复杂的异步操作
✅ 理解 RxSwift 的设计哲学

---

## 常见问题

**Q: 为什么要自己实现操作符？**
A: 通过实现，你会深入理解 RxSwift 的设计。直接使用 RxSwift 的操作符很容易，但理解它们的工作原理才是真正的学习。

**Q: 实现的操作符会不会有 bug？**
A: 很可能会有。这正是学习的机会。通过测试和调试，你会理解 RxSwift 为什么要这样设计。

**Q: 需要多长时间完成第二阶段？**
A: 如果每天投入 2-3 小时，预计 1-2 周。关键是理解，而不是速度。

**Q: 可以跳过某些操作符吗？**
A: 可以，但建议按顺序学习。每个操作符都会教你新的概念。

---

## 成功标志

当你能够：

1. ✅ 解释 Producer 的三个职责
2. ✅ 实现一个完整的操作符（包括错误处理）
3. ✅ 理解调度器的工作原理
4. ✅ 写出没有内存泄漏的代码
5. ✅ 对比自己的实现和 RxSwift 的实现，理解差异

那么你就已经掌握了 RxSwift 的核心概念，可以进入第三阶段了。

---

**记住**：学习 RxSwift 不是为了快速完成，而是为了深入理解。每一行代码都有意义，每一个设计决策都有原因。

加油！🚀
