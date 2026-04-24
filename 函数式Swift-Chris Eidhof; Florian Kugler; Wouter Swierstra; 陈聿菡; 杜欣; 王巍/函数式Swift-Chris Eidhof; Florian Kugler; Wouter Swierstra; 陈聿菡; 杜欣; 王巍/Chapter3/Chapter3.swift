//
//  Chapter3.swift
//  函数式Swift-Chris Eidhof; Florian Kugler; Wouter Swierstra; 陈聿菡; 杜欣; 王巍
//
//  Created by tuyang on 2026/4/23.
//

import Cocoa

/*
 不可变性的价值
 
 值类型与引用类型
 在了解一款软件的时候，耦合度通常被用来描述代码各个独立部分之间彼此依赖的程度。耦合度是衡量软件构建好坏的重要因素之一。最坏的情况下，所有类和方法都错综复杂相互关联，共享大量可变变量，甚至连具体的实现细节都存在依赖关系。这样的代码难以维护和更新：你无法理解或修改一小段独立的代码片段，而是需要一直站在整体的角度来考虑整个系统。”
 总而言之，Swift 提供了几种专门控制程序中使用可变状态的语法特征。虽然完全避开可选状态几乎不可能，但是仍有很多程序过度且不必要地使用可变性。学会在可能的时候避免使用可变状态和对象，将有助于降低耦合度，从而改善你的代码结构。”

*/



/*
 枚举
 
 关联值(枚举支持）
 
 纯函数式数据结构
 
 二叉搜索树
 “想要提高性能，这里有一些可行的方式。例如，我们可以确保数组是经过排序的，然后使用二分查找来定位特定元素。或者再彻底一些，索性定义一个二叉搜索树 (Binary Search Trees) 来表示无序集合。我们可以用传统的 C 语言风格打造一个树形结构，在每个节点持有指向子树的指针。当然，也可以利用 Swift 中的 indirect 关键字，直接将二叉树结构定义为一个枚举：”
 
 indirect 是 Swift 专门给 递归枚举（Recursive Enumeration） 用的关键字。
 “这个定义规定了每一棵树，要么是：
 一个没有关联值的叶子 leaf，要么是
 一个带有三个关联值的节点 node，关联值分别是左子树，储存在该节点的值和右子树。”
 
 */


indirect enum BinarySearchTree<Element:Comparable> {
    case leaf
    case node(BinarySearchTree<Element>,Element,BinarySearchTree<Element>)
}

extension BinarySearchTree{
    init() {
        self = .leaf
    }
    init(_ value:Element) {
        self = .node(.leaf, value, .leaf)
    }
    
    
    //    “在枚举值为基本值 .leaf 时，可以直接返回 0。而在值为 .node 时就比较有意思：我们递归地计算了两个子树储存的元素个数，然后加 1 ，也就是当前节点存值的个数，再将它们的总和返回。”
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return left.count + 1 + right.count
        }
    }
    
    var elements: [Element] {
        switch self {
        case .leaf:
            return []
        case let .node(left, x, right):
            return left.elements + [x] + right.elements
        }
    }
    
    var elementsR: [Element] {
        return reduce(leaf: []) {$0 + [$1] + $2}
    }

    var countR: Int {
        return reduce(leaf: 0) {1 + $0 + $2}
    }

    func reduce<A>(leaf leafF:A,node nodeF:(A,Element,A) -> A) -> A {
        switch self {
        case .leaf:
            return leafF
            case let .node(left, x, right):
            return nodeF(left.reduce(leaf: leafF, node: nodeF),x,right.reduce(leaf: leafF, node: nodeF))
        }
    }
    
    var isEmpty: Bool {
        if case .leaf = self {
            return true
        }
        return false
    }
    
    
    
}


class Chapter3: NSObject {

   func main() -> Void {
       
       let leaf:BinarySearchTree<Int> = .leaf
       let five:BinarySearchTree<Int> = .node(leaf, 5, leaf)
       
       
       let exampleSuccess:PopulationResult = .success(100)
       do{
//            populationOfCapital(country: "asd")
       }catch{
           
       }
   }
   
//    func populationOfCapital(country: String) -> PopulationResult {
//        guard let capital = capitals[country] else {
//            return .error(.capitalNotFound)
//        }
//        guard let population = cities[capital] else {
//            return .error(.populationNotFound)
//        }
//        return .success(population)
//    }
   
//    func populationOfCapital(country: String) throws -> Int {
//        guard let capital = capitals[country] else {
//            throw LookupError.capitalNotFound
//        }
//        guard let population = cities[capital] else {
//            throw LookupError.populationNotFound
//        }
//        return population
//    }
}


enum MayorResult {
    case success(String)
    case error(Error)
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum LookupError: Error {
    case capitalNotFound
    case populationNotFound
}

enum PopulationResult {
    case success(Int)
    case error(LookupError)
}

enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}

extension Encoding{
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ascii: return String.Encoding.ascii
        case .nextstep: return String.Encoding.nextstep
        case .japaneseEUC: return String.Encoding.japaneseEUC
        case .utf8: return String.Encoding.utf8
        }
    }
    
    init?(encoding: String.Encoding) {
        switch encoding {
        case String.Encoding.ascii: self = .ascii
        case String.Encoding.nextstep: self = .nextstep
        case String.Encoding.japaneseEUC: self = .japaneseEUC
        case String.Encoding.utf8: self = .utf8
        default: return nil
        }
    }
    
    var localizedName: String {
        return String.localizedName(of: nsStringEncoding)
    }
}

