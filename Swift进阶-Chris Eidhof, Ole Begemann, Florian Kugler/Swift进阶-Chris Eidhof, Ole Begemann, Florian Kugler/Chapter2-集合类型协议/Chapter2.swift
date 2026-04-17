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

enum MyList<Element> {
    case end
    //“在这里使用 indirect 关键字可以告诉编译器这个枚举值 node 应该被看做引用”“这是递归的，用间接引用存储，别直接嵌套！”“这意味着一个枚举将直接在变量中持有它的值，而不是持有一个指向值位置的引用。”值类型不能直接嵌套自己（内存无限大）indirect 让递归成员用引用存储，解决内存大小问题。
    indirect case node(Element,next:MyList<Element>)
}

extension MyList{
    // “我们通过创建一个新的节点，并将 next 值设为当前节点的方式来在链表头部添加一个节点：”
    func cons(_ x:Element) -> MyList {
        return .node(x, next: self)
    }
}

//ExpressibleByArrayLiteral = 让你自定义的类型，可以直接用 [] 来创建。
extension MyList: ExpressibleByArrayLiteral{
    init(arrayLiteral elements: Element...) {
        self = elements.reversed().reduce(.end) { partialList, element in
            partialList.cons(element)
        }
    }
    typealias ArrayLiteralElement = Element
}

extension MyList{
    mutating func push(_ x:Element) {
        self = self.cons(x)
    }
    
    mutating func pop() -> Element? {
        switch self {
        case .end:
            return nil
        case let .node(x, next: tail):
            self = tail
            return x
        }
    }
}

extension MyList:IteratorProtocol,Sequence{
    mutating func next() -> Element? {
        return pop()
    }
}

class Chapter2: NSObject {
    
    class func ListFunc() -> Void {
        let emptyList = MyList<Int>.end
        let oneList = MyList<Int>.node(1, next: emptyList)
        print("List=======  \(oneList)")
        
        // 一个拥有 3 个元素的链表 (3 2 1)”
        let list = MyList<Int>.end.cons(1).cons(2).cons(3)
        
//        let newList = MyList<Int>.init(arrayLiteral: 3,2,1);
        let newList:MyList = [3,2,1];
        print("List=======  \(newList)")
        
        for x in newList {
            print("List=======  \(x)")
        }

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


/*
 2.2 集合类型
 “集合类型 (Collection) 指的是那些稳定的序列，它们能够被多次遍历且保持一致。除了线性遍历以外，集合中的元素也可以通过下标索引的方式被获取到。下标索引通常是整数，至少在数组中是这样。不过我们马上回看到，索引也可以是一些不透明值 (比如在字典或者字符串中)，这有时候让使用起来不那么直观。集合的索引值可以构成一个有限的范围，它具有定义好了的开始和结束索引。也就是说，和序列不同，集合类型不能是无限的。”
 “集合类型在标准库中运用广泛。除了 Array，Dictionary，Set，String 和它的各种方式以外，另外还有 CountableRange 和 UnsafeBufferPointer 也是集合类型。更进一步，我们可以看到标准库外的一些类型也遵守了 Collection 协议。有两个我们熟知的类型通过这种方法获得了很多新的能力，它们是 Data 和 IndexSet，它们都来自 Foundation 框架。”
 
 “… 要使你的类型满足 Collection，你至少需要声明以下要求的内容：
 startIndex 和 endIndex 属性
 至少能够读取你的类型中的元素的下标方法
 用来在集合索引之间进行步进的 index(after:) 方法。”
 
 ExpressibleByArrayLiteral
 “当实现一个类似队列这样的集合类型时，最好也去实现一下 ExpressibleByArrayLiteral。这可以让用户能够以他们所熟知的 [value1, value2, etc] 语法创建一个队列。”
 */


/// 一个能够将元素入队和出队的类型”
protocol Queue {
   /// 在 `self` 中所持有的元素的类型”
    associatedtype Element
    /// 将 `newElement` 入队到 `self`”
    mutating func enqueue(_ newElement:Element)
    /// 从 `self` 出队一个元素
    mutating func deQnqueue() -> Element?
}

// 先出先进队列
struct FIFO<Element>:Queue {
    
    private var left: [Element] = []
    private var right: [Element] = []
    
    /// 将元素添加到队列最后
    /// - 复杂度: O(1)”
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }
    
    /// 从队列前端移除一个元素
    /// 当队列为空时，返回 nil
    /// - 复杂度: 平摊 O(1)”
    mutating func deQnqueue() -> Element? {
        if left.isEmpty{
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}

//precondition：这段代码要想正确运行，必须满足某个条件，否则直接崩溃并提示错误。
extension FIFO:Collection{
    var startIndex: Int{return 0}
    var endIndex: Int{return left.count + right.count}
    
    func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }
    
    subscript(position: Int) -> Element {
       precondition((0..<endIndex).contains(position), "Index out of bounds")
        if position < left.endIndex {
            return left[left.count - position - 1]
        }
        else {
            return right[position - left.count]
        }
    }
}

extension FIFO:ExpressibleByArrayLiteral{
    init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}


class Chapter2_1: NSObject {
    
    class func Chapter2_1() -> Void {
        var str = "Still I see monsters"
        print("split=======    \(str.split(separator: " "))")
    }
    
//    func Slince() -> Void {
//        let words: Words = Words("one two three")
//        let onePastStart = words.index(after: words.startIndex)
//        let firstDropped = words[onePastStart..<words.endIndex]
//        Array(firstDropped) // ["two", "three"]”
//    }
}

extension Substring{
    var nextWordRange: Range<Index> {
        let start = drop(while: {$0 == " "})
        let end = start.firstIndex(where: {$0 == " "}) ?? endIndex
        return start.startIndex..<end
    }
}

//struct WordsIndex: Comparable {
//    fileprivate let range: Range<Substring.Index>
//    fileprivate init(_ value: Range<Substring.Index>) {
//       self.range = value
//    }
//    static func <(lhs: Words.Index, rhs: Words.Index) -> Bool {
//        return lhs.range.lowerBound < rhs.range.lowerBound
//    }
//}

//struct Words: Collection {
//    let string: Substring
//    let startIndex: WordsIndex
//    init(_ s: String) {
//    self.init(s[...])
//    }
//    private init(_ s: Substring) {
//    self.string = s
//    self.startIndex = WordsIndex(string.nextWordRange)
//    }
//    var endIndex: WordsIndex {
//    let e = string.endIndex
//    return WordsIndex(e..<e)
//    }
//}
