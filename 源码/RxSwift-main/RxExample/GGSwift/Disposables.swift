//
//  File.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/11.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//


// 满足销毁，保证内存安全
protocol GGDisposable {
    func dispose()
}

///表示具有状态跟踪的一次性资源。
protocol GGCancelable:GGDisposable {
    var isDisposed: Bool {
        get
    }
}

struct GGNoDisposable:GGDisposable {
    func dispose() {
        
    }
    init() {}
}

/// 匿名 Disposable：dispose 时执行一个闭包，且只执行一次
final class GGAnonymousDisposable: GGDisposable {
    private let disposed = GGAtomicInt(0)
    private var disposeAction: (() -> Void)?
    
    init(disposeAction: @escaping () -> Void) {
        self.disposeAction = disposeAction
    }
    
    func dispose() {
        if fetchOr(disposed, 1) == 0 {
            disposeAction?()
            disposeAction = nil
        }
    }
}

public struct GGDisposables {
    private init() {}
}

extension GGDisposables{
    static func create(_ disposable1: GGDisposable, _ disposable2: GGDisposable) -> GGCancelable {
        GGBinaryDisposable(disposable1, disposable2)
    }
    
    static func create() -> GGDisposable { GGNopDisposable.noOp }
}

private struct GGNopDisposable: GGDisposable {
    fileprivate static let noOp: GGDisposable = GGNopDisposable()

    private init() {}

    /// Does nothing.
    func dispose() {}
}


private final class GGBinaryDisposable:GGCancelable {
    private let disposed = GGAtomicInt(0)
    
    // state
    private var disposable1: GGDisposable?
    private var disposable2: GGDisposable?
    
    /// - returns: Was resource disposed.
    var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }
    
    /// Constructs new binary disposable from two disposables.
    ///
    /// - parameter disposable1: First disposable
    /// - parameter disposable2: Second disposable
    init(_ disposable1: GGDisposable, _ disposable2: GGDisposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
    }
    
    /// Calls the disposal action if and only if the current instance hasn't been disposed yet.
    ///
    /// After invoking disposal action, disposal action will be dereferenced.
    func dispose() {
        if fetchOr(disposed, 1) == 0 {
            disposable1?.dispose()
            disposable2?.dispose()
            disposable1 = nil
            disposable2 = nil
        }
    }
}

@inline(__always)
func isFlagSet(_ this: GGAtomicInt, _ mask: Int32) -> Bool {
    (load(this) & mask) != 0
}


struct GGBagKey {
    fileprivate let rawValue: UInt64
}

//表示一个一次性资源，该资源只允许对其底层一次性资源进行一次分配。
public final class GGSingleAssignmentDisposable: GGCancelable {
    private struct DisposeState: OptionSet {
        let rawValue: Int32

        static let disposed = DisposeState(rawValue: 1 << 0)
        static let disposableSet = DisposeState(rawValue: 1 << 1)
    }

    private let state = GGAtomicInt(0)
    private var disposable = nil as GGDisposable?

    /// - returns: A value that indicates whether the object is disposed.
    public var isDisposed: Bool {
        isFlagSet(state, DisposeState.disposed.rawValue)
    }

    func setDisposable(_ disposable: GGDisposable) {
        self.disposable = disposable

        let previousState = fetchOr(state, DisposeState.disposableSet.rawValue)

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            rxFatalError("oldState.disposable != nil")
        }

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            disposable.dispose()
            self.disposable = nil
        }
    }

    func dispose() {
        let previousState = fetchOr(state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            guard let disposable else {
                rxFatalError("Disposable not set")
            }
            disposable.dispose()
            self.disposable = nil
        }
    }
    
}
