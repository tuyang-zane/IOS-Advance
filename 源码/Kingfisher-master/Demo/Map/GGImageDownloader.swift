//
//  GGImageDownloader.swift
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

import AppKit

final class GGDownloadTask:@unchecked Sendable{
    private let propertyQueue = DispatchQueue(label: "com.GG.GGImage.DownloadTaskPropertyQueue")

    init() { }
}

struct GGImageLoadingResult {
    let image:NSImage
    let url:URL?
    let originalData: Data
    init(image: NSImage, url: URL?, originalData: Data) {
        self.image = image
        self.url = url
        self.originalData = originalData
    }
}

public enum GGImageError:Error{
    case urlError
}

open class GGImageDownloader:@unchecked Sendable{
    
    private var _downloadTimeout:TimeInterval = 15.0
    
    private let propertyQueue = DispatchQueue(label: "com.GG.GGImage.ImageDownloaderPropertyQueue")

    open var downloadTimeout: TimeInterval {
        get {
            propertyQueue.sync {_downloadTimeout}
        }
        set {
            propertyQueue.sync {
                _downloadTimeout = newValue
            }
        }
    }
    
    open var requestsUsePipelining = false

    private let lock = NSLock()

    private var session: URLSession
    
    var sessionDelegate: GGSessionDelegate {
        didSet{
            session.invalidateAndCancel()
            session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        }
    }
    
    // .ephemeral：相当于浏览器的“无痕模式”。它不会把任何缓存、Cookie 或认证信息写入磁盘，所有数据只存在于内存中，会话结束后就全部丢弃。
    open var sessionConfiguration = URLSessionConfiguration.ephemeral {
        didSet {
            session.invalidateAndCancel()
            session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        }
    }

    
    // @Sendable。它的使用场景非常特定，核心判断标准就一条：这个闭包是否会被“跨线程”或“跨并发域”传递和执行。
   open func downloadImage(
        with url: URL,
        completionHandler:(@Sendable(Result<GGImageLoadingResult,GGImageError>) -> Void? = nil)) -> Void {
            createDownloadContext(with: url) { result in
                switch result {
                case .success(let context):
                    startDownloadTask(context: context)
//                    createTaskCallback(completionHandler)
                case .failure(let error):
                    completionHandler?(.failure(error))
                }
            }
    }
    
    // 开始下载任务
    private func startDownloadTask(
        context:DownloadingContext,
        callback: SessionDataTask.TaskCallback,
    ) -> GGDownloadTask {
        let downloadTask = addDownloadTask(context: context, callback: callback)
        
        
    }
    
    // 增加下载任务
    private func addDownloadTask(
        context: DownloadingContext,
        callback: SessionDataTask.TaskCallback
    ) -> GGDownloadTask
    {
        lock.lock()
        defer{lock.unlock()}
        
        let downloadTask: GGDownloadTask
        
        // 是否已经存在
        if let extingTask = sessionDelegate.task(for: context.url) {
            downloadTask = sessionDelegate
        }
        
        return downloadTask
    }
    
    
    private func createTaskCallback(
        _ completionHandler: ((DownloadResult) -> Void)?,
    ) -> Void {
        
    }
    
    private func createDownloadContext(
        with url: URL,
        done: @escaping (@Sendable (Result<DownloadingContext, GGImageError>) -> Void)
    ){
        // 前置检测url
        func checkRequestAndDone(r: URLRequest){
            guard let url = r.url,!url.absoluteString.isEmpty else {
                done(.failure(.urlError))
                return
            }
            done(.success(DownloadingContext(url: url, request: r)))
        }
        
        // Creates default request.
        var request = URLRequest(url: url,cachePolicy: .reloadIgnoringLocalCacheData,timeoutInterval: downloadTimeout)
        
        // htttp管线化
        request.httpShouldHandleCookies = requestsUsePipelining
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *){
            // 禁止下载高清图片
            request.allowsConstrainedNetworkAccess = false
        }
        checkRequestAndDone(r: request)

    }
    
    private func startDownloadTask(
        context: DownloadingContext,
        
    )
}

typealias DownloadResult = Result<GGImageLoadingResult,GGImageError>

extension GGImageDownloader{
    struct DownloadingContext {
        let url: URL
        let request: URLRequest
    }
}
 
// 任务管理器
public class GGSessionDataTask: @unchecked Sendable {
    let task:URLSessionTask
    let lock = NSLock()
    public let originalURL: URL?
    
    public typealias CancelToken = Int

    struct TaskCallback {
        
    }

    private var callbacksStore = [CancelToken: TaskCallback]()

    private var currentToken = 0

    func addCallback(_ callback: TaskCallback) -> CancelToken {
        lock.lock()
        defer { lock.unlock() }
        callbacksStore[currentToken] = callback
        defer { currentToken += 1 }
        return currentToken
    }

    func forceCancel(){
        for token in callbacksStore.keys {
            cancel(token: token)
        }
    }
    
    func cancel(token: CancelToken) {
        guard let callback = removeCallback(token) else {
            return
        }
    }
    
    func removeCallback(_ token: CancelToken) -> TaskCallback? {
        lock.lock()
        defer { lock.unlock() }
        if let callback = callbacksStore[token] {
            callbacksStore[token] = nil
            return callback
        }
        return nil
    }
}
