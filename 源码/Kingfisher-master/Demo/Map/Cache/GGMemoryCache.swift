//
//  GGMemoryCache.swift
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

public enum GGMemoryStorage{
    
    final class Backend<T:CacheCostCalculable>: @unchecked Sendable where T:Sendable {
        
        let storage = NSCache<NSString,StorageObject<T>>()
        
        var keys = Set<String>()
        
        private var cleanTimer: Timer? = nil
        private let lock = NSLock()

        public var config: Config {
            didSet {
                storage.totalCostLimit = config.totalCostLimit
                storage.countLimit = config.countLimit
                cleanTimer?.invalidate()
                cleanTimer = .scheduledTimer(withTimeInterval: config.cleanInterval, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.removeExpired()
                }
            }
        }
        
        public func removeExpired() {
            lock.lock()
            defer { lock.unlock() }
            for key in keys {
                let nsKey = key as NSString
                guard let object = storage.object(forKey: nsKey) else {
                    // This could happen if the object is moved by cache `totalCostLimit` or `countLimit` rule.
                    // We didn't remove the key yet until now, since we do not want to introduce additional lock.
                    // See https://github.com/onevcat/Kingfisher/issues/1233
                    keys.remove(key)
                    continue
                }
                if object.isExpired {
                    storage.removeObject(forKey: nsKey)
                    keys.remove(key)
                }
            }
        }


        public init(config: Config) {
            self.config = config
            storage.totalCostLimit = config.totalCostLimit
            storage.countLimit = config.countLimit

            cleanTimer = .scheduledTimer(withTimeInterval: config.cleanInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.removeExpired()
            }
        }

        
        func storeNoThrow(
            value:T,
            forKey key: String,
            expiration: GGStorageExpiration? = nil)
        {
            lock.lock()
            defer {lock.unlock()}
            let expiration = GGStorageExpiration.seconds(300)
            
            guard !expiration.isExpired else { return }
            
            let object:StorageObject<T> = StorageObject(value: value, expiration: expiration)
            storage.setObject(object, forKey: key as NSString, cost: value.cacheCost)
            keys.insert(key)
        }
    }
    
    class StorageObject<T> {
        var value: T?
        var expiration:GGStorageExpiration
        private(set) var estimatedExpiration: Date
        init(value: T? = nil, expiration: GGStorageExpiration) {
            self.value = value
            self.expiration = expiration
            self.estimatedExpiration = expiration.estimatedExpirationSinceNow
        }
        
        var isExpired: Bool {
            return estimatedExpiration.isPast
        }

    }
}

extension GGMemoryStorage {
    /// Represents the configuration used in a ``MemoryStorage/Backend``.
    public struct Config {

        /// The total cost limit of the storage.
        ///
        /// This counts up the value of ``CacheCostCalculable/cacheCost``. If adding this object to the cache causes
        /// the cache’s total cost to rise above totalCostLimit, the cache may automatically evict objects until its
        /// total cost falls below this value.
        public var totalCostLimit: Int

        /// The item count limit of the memory storage.
        ///
        /// The default value is `Int.max`, which means no hard limitation of the item count.
        public var countLimit: Int = .max

        /// The ``StorageExpiration`` used in this memory storage.
        ///
        /// The default is `.seconds(300)`, which means that the memory cache will expire in 5 minutes if not accessed.
        public var expiration: GGStorageExpiration = .seconds(300)

        /// The time interval between the storage performing cleaning work for sweeping expired items.
        public var cleanInterval: TimeInterval
        
        /// Determine whether newly added items to memory cache should be purged when the app goes to the background.
        ///
        /// By default, cached items in memory will be purged as soon as the app goes to the background to ensure a
        /// minimal memory footprint. Enabling this prevents this behavior and keeps the items alive in the cache even
        /// when your app is not in the foreground.
        ///
        /// The default value is `false`. After setting it to `true`, only newly added cache objects are affected.
        /// Existing objects that were already in the cache while this value was `false` will still be purged when the
        /// app enters the background.
        public var keepWhenEnteringBackground: Bool = false

        /// Creates a configuration from a given ``MemoryStorage/Config/totalCostLimit`` value and a
        ///  ``MemoryStorage/Config/cleanInterval``.
        ///
        /// - Parameters:
        ///   - totalCostLimit: The total cost limit of the storage in bytes.
        ///   - cleanInterval: The time interval between the storage performing cleaning work for sweeping expired items.
        ///   The default is 120, which means auto eviction happens once every two minutes.
        ///
        /// > Other properties of the ``MemoryStorage/Config`` will use their default values when created.
        public init(totalCostLimit: Int, cleanInterval: TimeInterval = 120) {
            self.totalCostLimit = totalCostLimit
            self.cleanInterval = cleanInterval
        }
    }
}


protocol CacheCostCalculable{
    var cacheCost:Int { get }
}

public enum GGStorageExpiration:Sendable {
    /// The item never expires.
    case never

    /// The item expires after a duration of the provided number of seconds from now.
    case seconds(TimeInterval)

    /// The item expires after a duration of the provided number of days from now.
    case days(Int)

    /// The item expires after a specified date.
    case date(Date)

    /// Use this to bypass the cache.
    case expired

    var estimatedExpirationSinceNow: Date {
        estimatedExpirationSince(Date())
    }

    func estimatedExpirationSince(_ date: Date) -> Date {
        switch self {
        case .never:
            return .distantFuture
        case .seconds(let seconds):
            return date.addingTimeInterval(seconds)
        case .days(let days):
            let duration: TimeInterval = TimeInterval(TimeConstants.secondsInOneDay * days)
            return date.addingTimeInterval(duration)
        case .date(let ref):
            return ref
        case .expired:
            return .distantPast
        }
    }

    var isExpired: Bool {
        timeInterval <= 0
    }

    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let seconds): return seconds
        case .days(let days): return TimeInterval(TimeConstants.secondsInOneDay * days)
        case .date(let ref): return ref.timeIntervalSinceNow
        case .expired: return -(.infinity)
        }
    }

}


/// Constants for certain time intervals.
struct TimeConstants {
    // Seconds in a day, a.k.a 86,400s, roughly.
    static let secondsInOneDay = 86_400
}


extension Date {
    var isPast: Bool {
        return isPast(referenceDate: Date())
    }

    func isPast(referenceDate: Date) -> Bool {
        return timeIntervalSince(referenceDate) <= 0
    }

    // `Date` in memory is a wrap for `TimeInterval`. But in file attribute it can only accept `Int` number.
    // By default the system will `round` it. But it is not friendly for testing purpose.
    // So we always `ceil` the value when used for file attributes.
    var fileAttributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}
