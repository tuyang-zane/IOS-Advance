//
//  GGDelegate.swift
//  Kingfisher
//
//  Created by admin on 2026/5/6.
//
//  Copyright (c) 2026 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Cocoa

public class GGDelegate<Input, Output>: @unchecked Sendable {
    public init() {}
    private let propertyQueue = DispatchQueue(label: "com.GGImage.GGDelegate.DelegateQueue")
    private var _block: ((Input) -> Output?)?
    private var block: ((Input) -> Output?)? {
        get { propertyQueue.sync { _block } }
        set { propertyQueue.sync { _block = newValue } }
    }

    private var _asyncBlock: ((Input) async -> Output?)?
    private var asyncBlock: ((Input) async -> Output?)? {
        get { propertyQueue.sync { _asyncBlock } }
        set { propertyQueue.sync { _asyncBlock = newValue } }
    }

    public func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }
    
    public func delegate<T: AnyObject>(on target: T, block: ((T, Input) async -> Output)?) {
        self.asyncBlock = { [weak target] input in
            guard let target = target else { return nil }
            return await block?(target, input)
        }
    }

    public func call(_ input: Input) -> Output? {
        return block?(input)
    }

    public func callAsync(_ input: Input) async -> Output? {
        return await asyncBlock?(input)
    }

}
