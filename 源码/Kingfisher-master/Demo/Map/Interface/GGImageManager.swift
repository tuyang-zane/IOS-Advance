//
//  GGImageManager.swift
//  Kingfisher
//
//  Created by admin on 2026/5/8.
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

class GGImageManager: @unchecked Sendable {
    
    public static let shared = GGImageManager()
    let cache = GGImageCache(name: "test")
    
    func getImage(
        _ url: URL,
        completionHandler: (@MainActor @Sendable (Result<NSImage, GGImageError>) -> Void)? = nil
    ) {
        GGImageManager.shared.retrieveImage(url,completionHandler: completionHandler)
    }
    
     func retrieveImage(
        _ url: URL,
        completionHandler: (@MainActor @Sendable (Result<NSImage, GGImageError>) -> Void)? = nil)
    {
        // 缓存命中
        if let img = retrieveImageFromCache(url){
            Task { @MainActor in
                 completionHandler?(.success(img))
            }
        }else{
            // 下载并保存
            let _ = GGImageDownloader.default.downloadImage(with:url) { result in
                if case .success(let data) = result{
                    self.cache.store(data.image, original: data.originalData, forKey: url.absoluteString) { result in
                        Task { @MainActor in
                            completionHandler?(.success(data.image))
                        }
                    }
                }
            }
        }
    }
    
    func retrieveImageFromCache(
        _ url: URL?) -> NSImage?
    {
        let key = url?.absoluteString ?? ""
        // 先从内存中取
        if let img = retrieveImageInMemoryCache(forKey: key) {
            return img
        }
        if let img = retrieveImageInDiskCache(forKey: key) {
            return img
        }
        // 再从磁盘读取，io更慢
        return nil
    }
    
    // 从内存中取
    open func retrieveImageInMemoryCache(
        forKey key: String) -> NSImage?
    {
        return cache.memoryStorage.value(
            for: key
        )
    }
    
    open func retrieveImageInDiskCache(
        forKey key: String) -> NSImage?
    {
        if let data = try? cache.diskStorage.value(forKey: key) {
            return NSImage(data:data)
        }
        return nil
    }

}
