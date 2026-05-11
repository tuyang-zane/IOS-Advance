
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

