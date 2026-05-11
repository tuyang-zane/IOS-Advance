
一、创建消费者GGAnyObserver

二、创建生产者GGObservable
create(闭包) → AnonymousObservable
                    ↓ subscribe(observer)
              Producer.subscribe()
                    ↓
              SinkDisposer + run()
                    ↓
              AnonymousObservableSink.run(parent)
                    ↓
              parent.subscribeHandler(AnyObserver(self))
                    ↓ 用户闭包里调 observer.on(.next)
              AnyObserver.on → Sink.forwardOn → ObserverBase.on → AnonymousObserver.onCore → 你的 onNext 闭包

1、GGObservable是抽象基类（只定义规则，不实现具体功能）
2、GGAnonymousObservable 就是它的匿名具体子类，专门负责实现 create 方法的订阅逻辑，专门存你闭包的容器
3、Producer 父类，作用：统一订阅入口，做通用校验
4、SinkDisposer 生命周期、内存安全、防止崩溃，这一层是「安全锁」。
5、AnonymousObservableSink  事件管道 + 中间层转发
6、parent.subscribeHandler  执行你自己写的 create 闭包
7、observer.on (.next) 事件流转
 
