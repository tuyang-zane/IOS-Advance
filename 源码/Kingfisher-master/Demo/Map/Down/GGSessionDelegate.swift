//
//  GGSessionDelegate.swift
//  Kingfisher
//
//  Created by admin on 2026/4/30.
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

///表示下载程序会话的委托对象。
///
///它也像一个任务管理器下载
class GGSessionDelegate: NSObject, @unchecked Sendable {

    private var tasks: [URL: GGSessionDataTask] = [:]
    private let lock = NSLock()
    
    
    func add(
        _ dataTask: URLSessionDataTask,
        url: URL,
        callback: GGSessionDataTask.TaskCallback) -> GGDownloadTask
    {
        lock.lock()
        defer{lock.unlock()}
        
        // Create a new task if necessary.
        let task = GGSessionDataTask(task: dataTask)
//        task.onCallbackCancelled.delegate(on: self) { [weak task] (self, value) in
//            guard let task = task else { return }
//
//            let (token, callback) = value
//
//            let error = KingfisherError.requestError(reason: .taskCancelled(task: task, token: token))
//            task.onTaskDone.call((.failure(error), [callback]))
//            // No other callbacks waiting, we can clear the task now.
//            if !task.containsCallbacks {
//                let dataTask = task.task
//
//                self.cancelTask(dataTask)
//                self.remove(task)
//            }
//        }
        let token = task.addCallback(callback)
        tasks[url] = task
        return GGDownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func task(for url:URL) -> GGSessionDataTask? {
        lock.lock()
        defer{lock.unlock()}
        return tasks[url]
    }
    
    func append(
        _ task: GGSessionDataTask,
        callback: GGSessionDataTask.TaskCallback
    ) -> GGDownloadTask {
        let token = task.addCallback(callback)
        return GGDownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func cancel(url:URL) {
        lock.lock()
        let task = tasks[url]
        lock.unlock()
        task?.forceCancel()
    }
    
}

extension GGSessionDelegate:URLSessionDelegate{
    
}
