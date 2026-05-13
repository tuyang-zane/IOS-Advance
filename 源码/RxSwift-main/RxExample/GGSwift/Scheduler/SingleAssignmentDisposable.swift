//
//  SingleAssignmentDisposable.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

public final class SingleAssignmentDisposable:  GGCancelable {
    private struct DisposeState: OptionSet {
        let rawValue: Int32

        static let disposed = DisposeState(rawValue: 1 << 0)
        static let disposableSet = DisposeState(rawValue: 1 << 1)
    }

    // state
    private let state = GGAtomicInt(0)
    private var disposable = nil as GGDisposable?

    /// - returns: A value that indicates whether the object is disposed.
    public var isDisposed: Bool {
        isFlagSet(state, DisposeState.disposed.rawValue)
    }

    /// Gets or sets the underlying disposable. After disposal, the result of getting this property is undefined.
    ///
    /// **Throws exception if the `SingleAssignmentDisposable` has already been assigned to.**
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

    /// Disposes the underlying disposable.
    public func dispose() {
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

