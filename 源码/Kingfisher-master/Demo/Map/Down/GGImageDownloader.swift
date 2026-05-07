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

///表示图像下载过程中的一个任务。
final class GGDownloadTask:@unchecked Sendable{
    private let propertyQueue = DispatchQueue(label: "com.GG.GGImage.DownloadTaskPropertyQueue")

    private var _linkedTask: GGDownloadTask? = nil

    init() { }
    
    private var _sessionTask: GGSessionDataTask? = nil
    private var _cancelToken: GGSessionDataTask.CancelToken? = nil

    public private(set) var sessionTask: GGSessionDataTask? {
        get { propertyQueue.sync { _sessionTask ?? _linkedTask?.sessionTask } }
        set { propertyQueue.sync { _sessionTask = newValue } }
    }

    init(sessionTask: GGSessionDataTask, cancelToken: GGSessionDataTask.CancelToken) {
        _sessionTask = sessionTask
        _cancelToken = cancelToken
    }

    // 链接到任务
    func linkToTask(_ task: GGDownloadTask) {
        propertyQueue.sync {
            _linkedTask = task
        }
    }
}

// 表示图像下载过程的成功结果
public struct GGImageLoadingResult: Sendable {
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
    case processorError(reason: String)
}

extension GGImageDownloader: GGImageDownloaderDelegate {}
extension GGImageDownloader: AuthenticationChallengeResponsible {}

// 下载管理器，用于从服务器请求带有URL的图像
open class GGImageDownloader:@unchecked Sendable{
    
   public static let `default` = GGImageDownloader(name: "default")

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
    
    private let name: String

    open var trustedHosts: Set<String>?

    open weak var delegate: (any GGImageDownloaderDelegate)?
    open weak var authenticationChallengeResponder: (any AuthenticationChallengeResponsible)?

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
    
    init(name: String) {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the downloader. "
                + "A downloader with empty name is not permitted.")
        }

        self.name = name
        sessionDelegate = GGSessionDelegate()
        session = URLSession(
            configuration: sessionConfiguration,
            delegate: sessionDelegate,
            delegateQueue: nil)
        setupSessionHandler()
    }
    
    deinit { session.invalidateAndCancel() }

    //MARK: 下载回调
    private func setupSessionHandler() {
        
        sessionDelegate.onReceiveSessionChallenge.delegate(on: self) { (self, invoke) in
            await (self.authenticationChallengeResponder ?? self).downloader(self, didReceive: invoke.1)
        }
        sessionDelegate.onReceiveSessionTaskChallenge.delegate(on: self) { (self, invoke) in
            await (self.authenticationChallengeResponder ?? self).downloader(self, task: invoke.1, didReceive: invoke.2)
        }
        sessionDelegate.onValidStatusCode.delegate(on: self) { (self, code) in
            (self.delegate ?? self).isValidStatusCode(code, for: self)
        }
        sessionDelegate.onResponseReceived.delegate(on: self) { (self, response) in
            await (self.delegate ?? self).imageDownloader(self, didReceive: response)
        }
        sessionDelegate.onDownloadingFinished.delegate(on: self) { (self, value) in
            let (url, result) = value
            do {
                let value = try result.get()
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: value, error: nil)
            } catch {
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: nil, error: error)
            }
        }
        sessionDelegate.onDidDownloadData.delegate(on: self) { (self, task) in
            (self.delegate ?? self).imageDownloader(self, didDownload: task.mutableData, with: task)
        }
    }
    
    //  MARK: 1、下载图片 @Sendable。它的使用场景非常特定，核心判断标准就一条：这个闭包是否会被“跨线程”或“跨并发域”传递和执行。
   func downloadImage(
        with url: URL,
        completionHandler:(@Sendable(Result<GGImageLoadingResult,GGImageError>) -> Void)? = nil) -> GGDownloadTask {

            let downloadTask = GGDownloadTask()
            createDownloadContext(with: url) { result in
                switch result {
                case .success(let context):
                    let taskCallback = self.createTaskCallback(completionHandler)
                    let task = self.startDownloadTask(context: context, callback: taskCallback)
                    downloadTask.linkToTask(task)
                case .failure(let error):
                    completionHandler?(.failure(error))
                }
            }
            return downloadTask
    }
    
    
    private func createTaskCallback(
        _ completionHandler: ((DownloadResult) -> Void)?
    ) -> GGSessionDataTask.TaskCallback
    {
        GGSessionDataTask.TaskCallback(
            onCompleted: createCompletionCallBack(completionHandler))
    }

    private func createCompletionCallBack(_ completionHandler: ((DownloadResult) -> Void)?) -> GGDelegate<DownloadResult, Void>? {
        completionHandler.map { block -> GGDelegate<DownloadResult, Void> in
            let delegate =  GGDelegate<Result<GGImageLoadingResult, GGImageError>, Void>()
            delegate.delegate(on: self) { (self, callback) in
                block(callback)
            }
            return delegate
        }
    }
    
    // MARK: 2、处理下载任务前置
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

    // MARK: 3、开始下载
    @discardableResult
    private func startDownloadTask(
        context: DownloadingContext,
        callback: GGSessionDataTask.TaskCallback,
        beforeTaskResume: ((GGDownloadTask) -> Void)? = nil
    ) -> GGDownloadTask{
        let downloadTask = addDownloadTask(context: context, callback: callback)
        guard let sessionTask = downloadTask.sessionTask, !sessionTask.started else {
            beforeTaskResume?(downloadTask)
            return downloadTask
        }
        sessionTask.onTaskDone.delegate(on: self) {[weak sessionTask] (self, done) in
            let (result, callbacks) = done
            switch result {
            case .success(let (data,response)):
                let processor = GGImageDataProcessor(data: data, callbacks: callbacks, processingQueue: nil)
                processor.onImageProcessed.delegate(on: self) { (self, done) in
                    let (result, callback) = done
                    let imageResult = result.map{GGImageLoadingResult(image: $0, url: context.url, originalData: data)}
                    let queue = CallbackQueue.mainCurrentOrAsync
                    queue.execute { callback.onCompleted?.call(imageResult) }
                }
                processor.process()
            case .failure(let error):
                callbacks.forEach { callback in
                    callback.onCompleted?.call(.failure(error))
                }
            }
        }
        sessionTask.resume()
        return downloadTask
    }
    
    // MARK: 4、增加下载任务
    private func addDownloadTask(
        context: DownloadingContext,
        callback: GGSessionDataTask.TaskCallback
    ) -> GGDownloadTask
    {
        lock.lock()
        defer{lock.unlock()}
        
        let downloadTask: GGDownloadTask
        // 是否已经存在
        if let extingTask = sessionDelegate.task(for: context.url) {
            downloadTask = sessionDelegate.append(extingTask, callback: callback)
        }else{
            let sessionDataTask = session.dataTask(with: context.request)
            sessionDataTask.priority = URLSessionTask.defaultPriority
            downloadTask = sessionDelegate.add(sessionDataTask, url: context.url, callback: callback)
        }
        return downloadTask
    }
}

typealias DownloadResult = Result<GGImageLoadingResult,GGImageError>

extension GGImageDownloader{
    struct DownloadingContext {
        let url: URL
        let request: URLRequest
    }
}
 
// 表示‘ ’ ImageDownloader ‘ ’中的会话数据任务
public class GGSessionDataTask: @unchecked Sendable {
    let task:URLSessionTask
    let lock = NSLock()
    public let originalURL: URL?
    
    public typealias CancelToken = Int

    struct TaskCallback {
        let onCompleted: GGDelegate<Result<GGImageLoadingResult, GGImageError>, Void>?
    }
    
    var callbacks: [GGSessionDataTask.TaskCallback] {
        lock.lock()
        defer { lock.unlock() }
        return Array(callbacksStore.values)
    }

    private var callbacksStore = [CancelToken: TaskCallback]()

    private var currentToken = 0

    let onCallbackCancelled = GGDelegate<(CancelToken, TaskCallback), Void>()

    var started = false

    private var _mutableData: Data
    public var mutableData: Data {
        lock.lock()
        defer { lock.unlock() }
        return _mutableData
    }

    let onTaskDone = GGDelegate<(Result<(Data, URLResponse?), GGImageError>, [TaskCallback]), Void>()

    init(task: URLSessionDataTask) {
        self.task = task
        self.originalURL = task.originalRequest?.url
        _mutableData = Data()
    }

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
        onCallbackCancelled.call((token, callback))
    }
    
    @discardableResult
    func removeAllCallbacks() -> [TaskCallback] {
        lock.lock()
        defer { lock.unlock() }
        let callbacks = callbacksStore.values
        callbacksStore.removeAll()
        return Array(callbacks)
    }
    
    func resume() {
        guard !started else { return }
        started = true
        task.resume()
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
    
    func didReceiveData(_ data: Data) {
        lock.lock()
        defer { lock.unlock() }
        _mutableData.append(data)
    }
    
//    func didCollectMetrics(_ metrics: NetworkMetrics) {
//        lock.lock()
//        defer { lock.unlock() }
//        _metrics = metrics
//    }


}


public protocol GGImageDownloaderDelegate: AnyObject {

    /// Called when the ``ImageDownloader`` object is about to start downloading an image from a specified URL.
    ///
    /// - Parameters:
    ///   - downloader: The ``ImageDownloader`` object used for the downloading operation.
    ///   - url: The URL of the starting request.
    ///   - request: The request object for the download process.
    func imageDownloader(_ downloader: GGImageDownloader, willDownloadImageForURL url: URL, with request: URLRequest?)

    /// Called when the ``ImageDownloader`` completes a downloading request with success or failure.
    ///
    /// - Parameters:
    ///   - downloader: The ``ImageDownloader`` object used for the downloading operation.
    ///   - url: The URL of the original request.
    ///   - response: The response object of the downloading process.
    ///   - error: The error in case of failure.
    func imageDownloader(
        _ downloader: GGImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: (any Error)?)
    
    /// Called when the ``ImageDownloader`` object successfully downloads image data with a specified task.
    ///
    /// This is your last chance to verify or modify the downloaded data before Kingfisher attempts to perform
    /// additional processing on the image data.
    ///
    /// - Parameters:
    ///   - downloader: The ``ImageDownloader`` object used for the downloading operation.
    ///   - data: The original downloaded data.
    ///   - task: The data task containing request and response information for the download.
    /// - Returns: The data that Kingfisher should use to create an image. You need to provide valid data that is in
    /// one of the supported image file formats. Kingfisher will process this data and attempt to convert it into an
    /// image object.
    func imageDownloader(_ downloader: GGImageDownloader, didDownload data: Data, with task: GGSessionDataTask) -> Data?
  
    /// Called when the ``ImageDownloader`` object successfully downloads image data from a specified URL.
    ///
    /// This is your last chance to verify or modify the downloaded data before Kingfisher attempts to perform
    /// additional processing on the image data.
    ///
    /// - Parameters:
    ///   - downloader: The ``ImageDownloader`` object used for the downloading operation.
    ///   - data: The original downloaded data.
    ///   - url: The URL of the original request.
    ///
    /// - Returns: The data that Kingfisher should use to create an image. You need to provide valid data that is in
    /// one of the supported image file formats. Kingfisher will process this data and attempt to convert it into an
    /// image object.
    ///
    /// This method can be used to preprocess raw image data before the creation of the `Image` instance (e.g.,
    /// decrypting or verification). If `nil` is returned, the processing is interrupted and a
    /// ``KingfisherError/ResponseErrorReason/dataModifyingFailed(task:)`` error will be raised. You can use this fact
    /// to stop the image processing flow if you find that the data is corrupted or malformed.
    ///
    /// > If the ``SessionDataTask`` version of `imageDownloader(_:didDownload:with:)` is implemented, this method will
    /// > not be called anymore.
    func imageDownloader(_ downloader: GGImageDownloader, didDownload data: Data, for url: URL) -> Data?

    /// Called when the ``ImageDownloader`` object successfully downloads and processes an image from a specified URL.
    ///
    /// - Parameters:
    ///   - downloader: The ``ImageDownloader`` object used for the downloading operation.
    ///   - image: The downloaded and processed image.
    ///   - url: The URL of the original request.
    ///   - response: The original response object of the downloading process.
    func imageDownloader(
        _ downloader: GGImageDownloader,
        didDownload image: NSImage,
        for url: URL,
        with response: URLResponse?)

    /// Checks if a received HTTP status code is valid or not.
    ///
    /// By default, a status code in the range `200..<400` is considered as valid. If an invalid code is received,
    /// the downloader will raise a ``KingfisherError/ResponseErrorReason/invalidHTTPStatusCode(response:)`` error.
    ///
    /// - Parameters:
    ///   - code: The received HTTP status code.
    ///   - downloader: The ``ImageDownloader`` object requesting validation of the status code.
    /// - Returns: A value indicating whether this HTTP status code is valid or not.
    ///
    /// > If the default range of `200..<400` as valid codes does not suit your needs, you can implement this method to
    /// change that behavior.
    func isValidStatusCode(_ code: Int, for downloader: GGImageDownloader) -> Bool

    /// Called when the task has received a valid HTTP response after passing other checks such as the status code.
    /// You can perform additional checks or verifications on the response to determine if the download should be
    /// allowed or cancelled.
    ///
    /// For example, this is useful if you want to verify some header values in the response before actually starting
    /// the download.
    ///
    /// If implemented, you have to return a proper response disposition, such as `.allow` to start the actual
    /// downloading or `.cancel` to cancel the task. If `.cancel` is used as the disposition, the downloader will raise
    /// a ``KingfisherError/ResponseErrorReason/cancelledByDelegate(response:)`` error. If not implemented, any response
    /// that passes other checks will be allowed, and the download will start.
    ///
    /// - Parameters:
    ///   - downloader: The `ImageDownloader` object used for the downloading operation.
    ///   - response: The original response object of the downloading process.
    ///
    /// - Returns: The disposition for the download task. You have to return either `.allow` or `.cancel`.
    func imageDownloader(
        _ downloader: GGImageDownloader,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition
}

// Default implementation for `ImageDownloaderDelegate`.
extension GGImageDownloaderDelegate {
    public func imageDownloader(
        _ downloader: GGImageDownloader,
        willDownloadImageForURL url: URL,
        with request: URLRequest?) {}

    public func imageDownloader(
        _ downloader: GGImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: (any Error)?) {}

    public func imageDownloader(
        _ downloader: GGImageDownloader,
        didDownload image: NSImage,
        for url: URL,
        with response: URLResponse?) {}

    public func isValidStatusCode(_ code: Int, for downloader: GGImageDownloader) -> Bool {
        return (200..<400).contains(code)
    }
  
    public func imageDownloader(_ downloader: GGImageDownloader, didDownload data: Data, with task: GGSessionDataTask) -> Data? {
        guard let url = task.originalURL else {
            return data
        }
        return imageDownloader(downloader, didDownload: data, for: url)
    }
  
    public func imageDownloader(_ downloader: GGImageDownloader, didDownload data: Data, for url: URL) -> Data? {
        return data
    }

    public func imageDownloader(
        _ downloader: GGImageDownloader,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        .allow
    }
}

public typealias AuthenticationChallengeResponsable = AuthenticationChallengeResponsible

/// Protocol indicates that an authentication challenge could be handled.
public protocol AuthenticationChallengeResponsible: AnyObject {

    /// Called when a session level authentication challenge is received.
    ///
    /// This method provides a chance to handle and respond to the authentication challenge before the downloading can
    /// start.
    ///
    /// - Parameters:
    ///   - downloader: The downloader that receives this challenge.
    ///   - challenge: An object that contains the request for authentication.
    /// - Returns: The challenge disposition on how the challenge should be handled, and the credential if the
    /// disposition is `.useCredential`.
    ///
    /// > This method is a forward from `URLSessionDelegate.urlSession(_:didReceive:completionHandler:)`.
    /// > Please refer to the documentation of it in `URLSessionDelegate`.
    func downloader(
        _ downloader: GGImageDownloader,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?)

    /// Called when a task level authentication challenge is received.
    ///
    /// This method provides a chance to handle and respond to the authentication challenge before the downloading can
    /// start.
    ///
    /// - Parameters:
    ///   - downloader: The downloader that receives this challenge.
    ///   - task: The task whose request requires authentication.
    ///   - challenge: An object that contains the request for authentication.
    /// - Returns: The challenge disposition on how the challenge should be handled, and the credential if the
    /// disposition is `.useCredential`.
    ///
    /// > This method is a forward from `URLSessionDataDelegate.urlSession(_:dataTask:didReceive:completionHandler:)`.
    /// > Please refer to the documentation of it in `URLSessionDataDelegate`.
    func downloader(
        _ downloader: GGImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?)
}

extension AuthenticationChallengeResponsible {

    public func downloader(
        _ downloader: GGImageDownloader,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trustedHosts = downloader.trustedHosts, trustedHosts.contains(challenge.protectionSpace.host) {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                return (.useCredential, credential)
            }
        }

        return (.performDefaultHandling, nil)
    }
    
    public func downloader(
        _ downloader: GGImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        (.performDefaultHandling, nil)
    }

}
