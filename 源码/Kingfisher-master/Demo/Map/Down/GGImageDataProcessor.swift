//
//  GGImageDataProcessor.swift
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

private let sharedProcessingQueue: CallbackQueue =
    .dispatch(DispatchQueue(label: "com.onevcat.Kingfisher.ImageDownloader.Process"))

//在自己的进程队列上处理图像处理工作。
final class GGImageDataProcessor: Sendable {
    let data: Data
    let callbacks: [GGSessionDataTask.TaskCallback]
    
    let queue: CallbackQueue
    
    //注意：我们有一个优化选择，通过检查回调来减少队列调度
    //每个选项的队列设置…
    let onImageProcessed = GGDelegate<(Result<NSImage, GGImageError>, GGSessionDataTask.TaskCallback), Void>()

    init(data: Data, callbacks: [GGSessionDataTask.TaskCallback], processingQueue: CallbackQueue?) {
        self.data = data
        self.callbacks = callbacks
        self.queue = processingQueue ?? sharedProcessingQueue
    }
    
    func process() {
        queue.execute {
            self.doProcess()
        }
    }

    private func doProcess() {
        var processedImages = [String: NSImage]()
        for callback in callbacks {
            let processor = GGDefaultImageProcessor.default
            var image = processedImages[processor.identifier]
            if image == nil {
                image = processor.process(item: .data(data))
                processedImages[processor.identifier] = image
            }

            let result: Result<NSImage, GGImageError>
            if let image = image {
                let finalImage = image
                result = .success(finalImage)
            } else {
                let error = GGImageError.processorError(reason: "123123")
                result = .failure(error)
            }
            onImageProcessed.call((result, callback))
        }
    }

}

///表示发送闭包时回调队列选择的行为。
public enum CallbackQueue: Sendable {
    case mainAsync
    case mainCurrentOrAsync
    case dispatch(DispatchQueue)
    case untouch

    public func execute(_ block: @Sendable @escaping () -> Void) {
        switch self {
        case .mainAsync:
            CallbackQueueMain.async { block() }
        case .mainCurrentOrAsync:
            CallbackQueueMain.currentOrAsync { block() }
        case .untouch:
            block()
        case .dispatch(let queue):
            queue.async { block() }
        }
    }

    
}


enum CallbackQueueMain {
    static func currentOrAsync(_ block: @MainActor @Sendable @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.runUnsafely { block() }
        } else {
            DispatchQueue.main.async { block() }
        }
    }
    
    static func async(_ block: @MainActor @Sendable @escaping () -> Void) {
        DispatchQueue.main.async { block() }
    }
}

extension MainActor{
    static func runUnsafely<T: Sendable>(_ body: @MainActor () throws -> T) rethrows -> T {
        return try MainActor.assumeIsolated(body)
    }
}
