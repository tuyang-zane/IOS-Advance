//
//  Chapter2.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/15.
//

import Cocoa

/*
 集合类型协议
 Array，Dictionary 和 Set，它们并非空中楼阁，而是建立在一系列由 Swift 标准库提供的用来处理元素序列的抽象之上的。这一章我们将讨论 Sequence 和 Collection协议，它们构成了这套集合类型模型的基石。我们会研究这些协议是如何工作的，它们为什么要以这样的方式工作，以及你如何写出自己的序列和集合类型。
 
 2.1序列
 Sequence 协议是集合类型结构中的基础。一个序列 (sequence) 代表的是一系列具有相同类型的值，你可以对这些值进行迭代。遍历一个序列最简单的方式是使用 for 循环”
 
 迭代器
 满足 Sequence 协议的要求十分简单，你需要做的所有事情就是提供一个返回迭代器 (iterator)，序列通过创建一个迭代器来提供对元素的访问。迭代器每次产生一个序列的值，并且当遍历序列时对遍历状态进行管理。在 IteratorProtocol 协议中唯一的一个方法是 next()，这个方法需要在每次被调用时返回序列中的下一个值。当序列被耗尽时，next() 应该返回 nil

 for 循环其实是下面这段代码的一种简写形式
 var iterator = someSequence.makeIterator()
 while let element = iterator.next() {
 doSomething(with: element)
 
 AnyIterator 是一个对别的迭代器进行封装的迭代器，它可以用来将原来的迭代器的具体类型“抹消”掉。比如你在创建公有 API 时想要将一个很复杂的迭代器的具体类型隐藏起来，而不暴露它的具体实现的时候，就可以使用这种迭代器。AnyIterator 进行封装的做法是将另外的迭代器包装到一个内部的对象中，而这个对象是引用类型。
 
 无限序列
 “对于序列和集合来说，它们之间的一个重要区别就是序列可以是无限的，而集合则不行。”
 “序列并不只限于像是数组或者列表这样的传统集合数据类型。像是网络流，磁盘上的文件，UI 事件的流，以及其他很多类型的数据都可以使用序列来进行建模。”
 “但只有 Collection 协议能保证多次进行迭代是安全的，Sequence 中对此并没有进行保证。”
 
 子序列
 prefix 和 suffix — 获取开头或结尾 n 个元素
 prefix(while:) - 从开头开始当满足条件时，
 dropFirst 和 dropLast — 返回移除掉前 n 个或后 n 个元素的子序列
 drop(while:) - 移除元素，直到条件不再为真，然后返回剩余元素
 split — 将一个序列在指定的分隔元素时截断，返回子序列的的数组”
 
 链表
 “作为自定义序列的例子，让我们来用间接枚举实现一个最基础的数据类型：单向链表。一个链表的节点有两种可能：要么它是一个节点，其中包含了值及对下一个节点的引用，要么它代表链表的结束。”
 
 */

enum List<Element> {
    case end
    //“在这里使用 indirect 关键字可以告诉编译器这个枚举值 node 应该被看做引用”“这是递归的，用间接引用存储，别直接嵌套！”“这意味着一个枚举将直接在变量中持有它的值，而不是持有一个指向值位置的引用。”
    indirect case node(Element,next:List<Element>)
}

class Chapter2: NSObject {
    
    class func List() -> Void {
        
    }
    
    class func MoreSequence() -> Void {
        let standardIn = AnySequence {
            return AnyIterator {
                readLine()
            }
        }
        let numberedStdIn = standardIn.enumerated()
        for (i,line) in numberedStdIn {
            print("\(i+1): \(line)")
        }
    }
    
    class func Sequence() -> Void {
        var iter = FibsIterator()
        while let x = iter.next() {
            print("FibsIterator=======  \(x)")
        }
    }
    
    class func PrefixIterator() -> Void {
        for prex in PrefixSequence(string: "hellow").map({$0.uppercased()}) {
            print("PrefixIterator=======  \(prex)")
        }
        
        for prex in FibsSequence() {
            print("FibsSequence=======  \(prex)")
        }
    }
    
    class func stride() -> Void {
        let seq = Swift.stride(from: 0, to: 10, by: 1)
        var i1 = seq.makeIterator()
        print("stride=======  \(i1.next()) \(i1.next())")
        
        var i2 = i1
        print("stride=======  \(i1.next())")
        print("stride=======  \(i2.next())")
        
        var i3 = AnyIterator(i1)
        var i4 = i3
        print("stride=======  \(i3.next())")
        print("stride=======  \(i4.next())")
    }
    
    func fibsIterator() -> AnyIterator<Int> {
        var state = (0,1)
        return AnyIterator {
            let number = state.0
            state = (state.1,state.0 + state.1)
            return number
        }
    }
    
}

struct PrefixIterator: IteratorProtocol {
    typealias Element = String
    
    let string: String
    var offset: String.Index

    init(string: String) {
        self.string = string
        self.offset = string.startIndex
    }

    mutating func next() -> String? {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        return String(string.prefix(upTo: offset))
    }
}

struct PrefixSequence: Sequence {
    func makeIterator() -> PrefixIterator {
        return PrefixIterator(string: string)
    }
    
    let string: String
}


struct ConstantSequence: Sequence {
    func makeIterator() -> ConstantIterator {
        return ConstantIterator()
    }
}

struct ConstantIterator:IteratorProtocol {
    //“显示地使用 typealias 指定 Element 的类型其实并不是必须的 (不过通常可以用为文档的目的帮助理解代码，特别是在更大的协议中这点尤为明显)”
    typealias Element = Int
    mutating func next() -> Int? {
        return 1
    }
}

struct FibsSequence: Sequence {
    func makeIterator() -> FibsIterator {
        return FibsIterator()
    }
}

struct FibsIterator:IteratorProtocol {
    var state = (0,1)
    mutating func next() -> Int? {
        let upcomingNumber = state.0
        state = (state.1, state.0 + state.1)
        return upcomingNumber
        
    }
}

//extension Sequence where Element: Equatable, SubSequence: Sequence,SubSequence.Element == Element
//{
//    func headMirrorsTail(_ n: Int) -> Bool {
//        let head = prefix(n)
//        let tail = suffix(n).reversed()
//        return head.elementsEqual(tail)
//    }
//}
//
//extension Collection where Element: Equatable {
//    func headMirrorsTail(_ n: Int) -> Bool {
//        let head = prefix(n)
//        let tail = suffix(n).reversed()
//        return head.elementsEqual(tail)
//    }
//}

//protocol IteratorProtocol {
//    //“关联类型 Element 指定了迭代器产生的值的类型。”
//    associatedtype Element
//    mutating func next() -> Element?
//}
