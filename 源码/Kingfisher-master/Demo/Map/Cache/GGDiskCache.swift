//
//  GGDiskCache.swift
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

enum GGDiskStorage{

    final class Backend<T:DataTransformable>: @unchecked Sendable where T:Sendable {
        private let propertyQueue = DispatchQueue(label: "com.GGImage.DiskStorage.Backend.propertyQueue")
        
        private var storageReady: Bool = true

        private var _config: Config
        /// The configuration used for this disk storage.
        ///
        /// It is a value you can set and use to configure the storage as needed.
        public var config: Config {
            get { propertyQueue.sync { _config } }
            set { propertyQueue.sync { _config = newValue } }
        }
        
        public let directoryURL: URL

        init(noThrowConfig config: Config, creatingDirectory: Bool) {
            _config = config
            
            let creation = Creation(config)
            self.directoryURL = creation.directoryURL
            
            if creatingDirectory {
                try? prepareDirectory()
            }
        }
        
        /// 确保缓存目录存在，不存在则创建
        private func prepareDirectory() throws {
            let fileManager = config.fileManager
            let path = directoryURL.path
            
            guard !fileManager.fileExists(atPath: path) else { return }
            
            try fileManager.createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        public func store(
            value: T,
            forKey key: String,
            expiration: GGStorageExpiration? = nil,
            writeOptions: Data.WritingOptions = [],
            forcedExtension: String? = nil
        ) throws
        {
            guard storageReady else {
                throw GGImageError.processorError(reason: "132")
            }

            let expiration = expiration ?? .days(7)
            // The expiration indicates that already expired, no need to store.
            guard !expiration.isExpired else { return }

            let data: Data
            do {
                data = try value.toData()
            } catch {
                throw GGImageError.processorError(reason: "非data类型")
            }

            let fileURL = cacheFileURL(forKey: key, forcedExtension: forcedExtension)
            
            print("磁盘存储位置==========  \(fileURL)")
            
            do{
                try data.write(to: fileURL, options: writeOptions)
            } catch {
                throw GGImageError.processorError(reason: "保存失败")
            }
            
            let now = Date()
            let attributes: [FileAttributeKey : Any] = [
                // The last access date.
                .creationDate: now.fileAttributeDate,
                // The estimated expiration date.
                .modificationDate: expiration.estimatedExpirationSinceNow.fileAttributeDate
            ]

            do {
                try config.fileManager.setAttributes(attributes, ofItemAtPath: fileURL.path)
            } catch {
                try? config.fileManager.removeItem(at: fileURL)
                throw GGImageError.processorError(reason: "保存失败")
            }
        }

        public func cacheFileURL(forKey key: String, forcedExtension: String? = nil) -> URL {
            let fileName = cacheFileName(forKey: key, forcedExtension: forcedExtension)
            return directoryURL.appendingPathComponent(fileName, isDirectory: false)
        }

        func cacheFileName(forKey key: String, forcedExtension: String? = nil) -> String {
            let baseName = key.gg_MD5
            
            if let ext = fileExtension(key: key, forcedExtension: forcedExtension) {
                return "\(baseName).\(ext)"
            }
            return baseName
        }

        func fileExtension(key: String, forcedExtension: String?) -> String? {
            if let ext = forcedExtension ?? config.pathExtension {
                return ext
            }
            return nil
        }

    }
}

extension GGDiskStorage{
    
    
    struct Creation {
        let directoryURL: URL
        let cacheName: String
        init(_ config: Config) {
            let url: URL
            if let directory = config.directory {
                url = directory
            } else {
                url = config.fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            }

            cacheName = "com.onevcat.Kingfisher.ImageCache.\(config.name)"
            directoryURL = config.cachePathBlock(url, cacheName)
        }
    }
    
    public struct Config : @unchecked Sendable{
        public var sizeLimit: UInt
        
        public var expiration: GGStorageExpiration = .days(7)

        let fileManager: FileManager

        let directory: URL?

        public let name: String

        public var pathExtension: String? = nil

        init(
            name: String,
            sizeLimit: UInt,
            fileManager: FileManager = .default,
            directory: URL? = nil)
        {
            self.name = name
            self.fileManager = fileManager
            self.directory = directory
            self.sizeLimit = sizeLimit
        }

        init(sizeLimit: UInt, expiration: GGStorageExpiration, fileManager: FileManager, directory: URL?, name: String) {
            self.sizeLimit = sizeLimit
            self.expiration = expiration
            self.fileManager = fileManager
            self.directory = directory
            self.name = name
        }
        
        public var cachePathBlock: (@Sendable (_ directory: URL, _ cacheName: String) -> URL)! = {
            (directory, cacheName) in
            return directory.appendingPathComponent(cacheName, isDirectory: true)
        }

    }
    
}

public protocol DataTransformable {
    
    /// Converts the current value to a `Data` representation.
    /// - Returns: The data object which can represent the value of the conforming type.
    /// - Throws: If any error happens during the conversion.
    func toData() throws -> Data
    
    /// Convert some data to the value.
    /// - Parameter data: The data object which should represent the conforming value.
    /// - Returns: The converted value of the conforming type.
    /// - Throws: If any error happens during the conversion.
    static func fromData(_ data: Data) throws -> Self
    
    /// An empty object of `Self`.
    ///
    /// > In the cache, when the data is not actually loaded, this value will be returned as a placeholder.
    /// > This variable should be returned quickly without any heavy operation inside.
    static var empty: Self { get }
}


import CommonCrypto

extension String {
    var gg_MD5: String {
        guard let data = self.data(using: .utf8) else { return self }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, UInt32(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
