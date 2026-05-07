//
//  GGImageProcessor.swift
//  Kingfisher
//
//  Created by admin on 2026/5/7.
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

public struct GGDefaultImageProcessor: GGImageProcessor {
    public let identifier: String = ""
    public static let `default` = GGDefaultImageProcessor()
    public func process(item: GGImageProcessItem) -> NSImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return NSImage(data: data)
        }
    }
}

public protocol GGImageProcessor: Sendable {
    var identifier: String { get }
    func process(item: GGImageProcessItem) -> NSImage?
}

public enum GGImageProcessItem: Sendable {
    
    /// Input image. The processor should provide a method to apply
    /// processing to this `image` and return the resulting image.
    case image(NSImage)
    
    /// Input data. The processor should provide a method to apply
    /// processing to this `data` and return the resulting image.
    case data(Data)
}
