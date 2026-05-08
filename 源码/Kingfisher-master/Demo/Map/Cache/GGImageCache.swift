//
//  GGImageCache.swift
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

enum CacheType: Sendable {

    case none
    
    case memory
    
    case disk
    
    var caced: Bool {
        switch self {
        case .memory,.disk:
            return true
        case .none:
            return false
        }
    }
}

class GGImageCache:@unchecked Sendable {
    
    public let memoryStorage: GGMemoryStorage.Backend<NSImage>

    public let diskStorage: GGDiskStorage.Backend<Data>

    private let ioQueue: DispatchQueue

    public typealias DiskCachePathClosure = @Sendable (URL, String) -> URL

    public convenience init(name: String) {
        self.init(noThrowName: name, cacheDirectoryURL: nil, diskCachePathClosure: nil)
    }

    convenience init(
        noThrowName name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure?
    )
    {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the cache. A cache with empty name is not permitted.")
        }

        let memoryStorage = GGImageCache.createMemoryStorage()

        let config = GGImageCache.createConfig(
            name: name, cacheDirectoryURL: cacheDirectoryURL, diskCachePathClosure: diskCachePathClosure
        )
        let diskStorage = GGDiskStorage.Backend<Data>(noThrowConfig: config, creatingDirectory: true)
        self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
    }
    
    private static func createConfig(
        name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure? = nil
    ) -> GGDiskStorage.Config
    {
        var diskConfig = GGDiskStorage.Config(
            name: name,
            sizeLimit: 0,
            directory: cacheDirectoryURL
        )
        if let closure = diskCachePathClosure {
            diskConfig.cachePathBlock = closure
        }
        return diskConfig
    }


    public init(
        memoryStorage: GGMemoryStorage.Backend<NSImage>,
        diskStorage: GGDiskStorage.Backend<Data>)
    {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
        let ioQueueName = "com.GGImage.ImageCache.ioQueue.\(UUID().uuidString)"
        ioQueue = DispatchQueue(label: ioQueueName)
    }
    
    private static func createMemoryStorage() -> GGMemoryStorage.Backend<NSImage> {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = GGMemoryStorage.Backend<NSImage>(config:
            .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))
        return memoryStorage
    }

    
    func store(
        _ image:NSImage,
        original: Data,
        forKey key: String,
        toDisk: Bool = true,
        completionHandler: (@Sendable (GGCacheStoreResult) -> Void)? = nil
    ) {
        // Memory storage should not throw.
        memoryStorage.storeNoThrow(value: image, forKey: key, expiration: nil)
        
        guard toDisk else {
            if let completionHandler = completionHandler {
                let result = GGCacheStoreResult (memoryCacheResult: .success(()), diskCacheResult: .success(()))
                CallbackQueue.mainCurrentOrAsync.execute {
                    completionHandler(result)
                }
            }
            return
        }
        
        ioQueue.async {
            self.syncStoreToDisk(
                original,
                forKey: key,
                forcedExtension: nil,
                callbackQueue: CallbackQueue.mainCurrentOrAsync,
                completionHandler: completionHandler)

        }
        
    }
    
    private func syncStoreToDisk(
        _ data: Data,
        forKey key: String,
        forcedExtension: String?,
        processorIdentifier identifier: String = "",
        callbackQueue: CallbackQueue = .untouch,
        expiration: GGStorageExpiration? = nil,
        writeOptions: Data.WritingOptions = [],
        completionHandler: (@Sendable (GGCacheStoreResult) -> Void)? = nil)
    {
        let result: GGCacheStoreResult
        do{
            try self.diskStorage.store(
                value: data,
                forKey: key,
                expiration: expiration,
                writeOptions: writeOptions,
                forcedExtension: forcedExtension
            )
            result = GGCacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
        }catch{
            result = GGCacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .failure(.processorError(reason: "disk cacheed error")))
        }
        if let completionHandler = completionHandler {
            callbackQueue.execute { completionHandler(result) }
        }
    }
    
}


struct GGCacheStoreResult:Sendable {
    
    public let memoryCacheResult: Result<(),Never>
    
    public let diskCacheResult: Result<(),GGImageError>

}

extension NSImage:CacheCostCalculable{
    var cacheCost:Int { 50 * 1024 * 1024 }
}

extension Data: DataTransformable {
    public func toData() throws -> Data {
        self
    }

    public static func fromData(_ data: Data) throws -> Data {
        data
    }

    public static let empty = Data()
}
