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
open class GGSessionDelegate: NSObject, @unchecked Sendable {

    private var tasks: [URL: GGSessionDataTask] = [:]
    private let lock = NSLock()
    
    let onValidStatusCode = GGDelegate<Int, Bool>()
    let onResponseReceived = GGDelegate<URLResponse, URLSession.ResponseDisposition>()
    let onDownloadingFinished = GGDelegate<(URL, Result<URLResponse, GGImageError>), Void>()
    let onDidDownloadData = GGDelegate<GGSessionDataTask, Data?>()
    let onReceiveSessionChallenge = GGDelegate<SessionChallengeFunc, (URLSession.AuthChallengeDisposition, URLCredential?)>()
    let onReceiveSessionTaskChallenge = GGDelegate<SessionTaskChallengeFunc, (URLSession.AuthChallengeDisposition, URLCredential?)>()

    typealias SessionChallengeFunc = (
        URLSession,
        URLAuthenticationChallenge
    )

    typealias SessionTaskChallengeFunc = (
        URLSession,
        URLSessionTask,
        URLAuthenticationChallenge
    )
    
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
    
    private func task(for task: URLSessionTask) -> GGSessionDataTask? {
        lock.lock()
        defer { lock.unlock() }
        guard let url = task.originalRequest?.url else {
            return nil
        }
        guard let sessionTask = tasks[url] else {
            return nil
        }
        guard sessionTask.task.taskIdentifier == task.taskIdentifier else {
            return nil
        }
        return sessionTask
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
    
    private func remove(_ task: GGSessionDataTask) {
        lock.lock()
        defer { lock.unlock() }

        guard let url = task.originalURL else {
            return
        }
        task.removeAllCallbacks()
        tasks[url] = nil
    }

}

extension GGSessionDelegate:URLSessionDataDelegate{
    
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = GGImageError.processorError(reason: "1234")
            onCompleted(task: dataTask, result: .failure(error))
            return .cancel
        }
        
        let httpStatusCode = httpResponse.statusCode
        let isValid = true
        guard isValid else {
            let error = GGImageError.processorError(reason: "1235")
            onCompleted(task: dataTask, result: .failure(error))
            return .cancel
        }
        
        guard let disposition = await onResponseReceived.callAsync(response) else {
            return .allow
        }
        
        if disposition == .cancel {
            let error = GGImageError.processorError(reason: "1236")
            self.onCompleted(task: dataTask, result: .failure(error))
        }
        
        return disposition
    }

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = self.task(for: dataTask) else {
            return
        }
        
        task.didReceiveData(data)
        
        task.callbacks.forEach { callback in
//            callback.options.onDataReceived?.forEach { sideEffect in
//                sideEffect.onDataReceived(session, task: task, data: data)
//            }
        }
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let sessionTask = self.task(for: task) else { return }

        // 【调试】打印系统真实的错误信息
        if let realError = error {
            print("⚠️ 真实的网络报错是：\(realError.localizedDescription)")
        }

        if let url = sessionTask.originalURL {
            let result: Result<URLResponse, GGImageError>
            if let error = error {
                result = .failure(GGImageError.processorError(reason: "111"))
            } else if let response = task.response {
                result = .success(response)
            } else {
                result = .failure(GGImageError.processorError(reason: "1"))
            }
            onDownloadingFinished.call((url, result))
        }

        let result: Result<(Data, URLResponse?), GGImageError>
        if let error = error {
            result = .failure(GGImageError.processorError(reason: "222"))
        } else {
            if let data = onDidDownloadData.call(sessionTask) {
                result = .success((data, task.response) as! (Data, URLResponse?))
            } else {
                result = .failure(GGImageError.processorError(reason: "333"))
            }
        }
        onCompleted(task: task, result: result)
    }

    open func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        await onReceiveSessionChallenge.callAsync((session, challenge)) ?? (.performDefaultHandling, nil)
    }
    
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        await onReceiveSessionTaskChallenge.callAsync((session, task, challenge)) ?? (.performDefaultHandling, nil)
    }
    
    
//    open func urlSession(
//        _ session: URLSession,
//        task: URLSessionTask,
//        willPerformHTTPRedirection response: HTTPURLResponse,
//        newRequest request: URLRequest
//    ) async -> URLRequest?
//    {
//        guard let sessionDataTask = self.task(for: task),
//              let redirectHandler = Array(sessionDataTask.callbacks).last?.options.redirectHandler else
//        {
//            return request
//        }
//        return await redirectHandler.handleHTTPRedirection(
//            for: sessionDataTask,
//            response: response,
//            newRequest: request
//        )
//    }
    
//    open func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//        guard let sessionTask = self.task(for: task) else { return }
//        
//        // Collect network metrics for the completed task
//        if let networkMetrics = NetworkMetrics(from: metrics) {
//            sessionTask.didCollectMetrics(networkMetrics)
//        }
//    }

    private func onCompleted(task: URLSessionTask, result: Result<(Data, URLResponse?), GGImageError>) {
        guard let sessionTask = self.task(for: task) else {
            return
        }
        let callbacks = sessionTask.removeAllCallbacks()
        sessionTask.onTaskDone.call((result, callbacks))
        remove(sessionTask)
    }

}


protocol DataReceivingSideEffect: AnyObject, Sendable {
    var onShouldApply: () -> Bool { get set }
    func onDataReceived(_ session: URLSession, task: GGSessionDataTask, data: Data)
}
