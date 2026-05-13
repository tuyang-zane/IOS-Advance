//
//  Queue.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/13.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

/*
 表示队列的数据结构。
 当操作数为时，‘ enqueue ’、‘ dequeue ’的复杂度为O(1)
 平均N次操作。
 peek的复杂度为O(1)。
 */

struct Queue<T>:Sequence {
    /// Type of generator.
    typealias Generator = AnyIterator<T>
    
    //ContiguousArray<T?>：它没有使用普通的 Array，而是用了 ContiguousArray。在 Swift 中，ContiguousArray 保证了元素在内存中是绝对连续存放的（普通 Array 在存值类型时可能会因为桥接 Objective-C 而产生额外的内存开销）。这对于高频读写的队列来说，缓存命中率极高。
    private var storage: ContiguousArray<T?>
    
    // 当前队列里实际有多少个元素。
    private var innerCount = 0

    // 入队指针，指向下一个新元素要存放的位置。
    private var pushNextIndex = 0
    private let initialCapacity: Int

    private let resizeFactor = 2

    // 队列容量
    init(capacity: Int) {
        initialCapacity = capacity
        storage = ContiguousArray<T?>(repeating: nil, count: capacity)
    }
    
    // 出队指针，指向当前队列最前面的元素。它不是独立存储的，而是通过 pushNextIndex - count 动态计算出来的。
    var dequeueIndex: Int {
        let index = pushNextIndex - count
        return index < 0 ? index + storage.count : index
    }
    
    /// - returns: Is queue empty.
    var isEmpty: Bool { count == 0 }

    /// - returns: Number of elements inside queue.
    var count: Int { innerCount }

    func peek() -> T {
        precondition(count > 0)
        return storage[dequeueIndex]!
    }
    
    private mutating func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)

        let count = count

        let dequeueIndex = dequeueIndex
        let spaceToEndOfQueue = storage.count - dequeueIndex

        // first batch is from dequeue index to end of array
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        // second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch

        newStorage[0 ..< countElementsInFirstBatch] = storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = storage[0 ..< numberOfElementsInSecondBatch]

        innerCount = count
        pushNextIndex = count
        storage = newStorage
    }


    mutating func dequeue() -> T? {
        if count == 0 {
            return nil
        }

        defer {
            let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
            if count < downsizeLimit, downsizeLimit >= initialCapacity {
                resizeTo(storage.count / resizeFactor)
            }
        }

        return dequeueElementOnly()
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)

        let index = dequeueIndex

        defer {
            storage[index] = nil
            innerCount -= 1
        }

        return storage[index]!
    }


    func makeIterator() -> AnyIterator<T> {
        var i = dequeueIndex
        var innerCount = count
        return AnyIterator {
            if innerCount == 0 {
                return nil
            }

            defer {
                innerCount -= 1
                i += 1
            }

            if i >= storage.count {
                i -= storage.count
            }

            return storage[i]
        }
    }
    
    /// Enqueues `element`.
    ///
    /// - parameter element: Element to enqueue.
    mutating func enqueue(_ element: T) {
        if count == storage.count {
            resizeTo(Swift.max(storage.count, 1) * resizeFactor)
        }

        storage[pushNextIndex] = element
        pushNextIndex += 1
        innerCount += 1

        if pushNextIndex >= storage.count {
            pushNextIndex -= storage.count
        }
    }

}
