//
//  Chapter8.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/21.
//

import Cocoa

/*
 泛型
 
 重载
 “拥有同样名字，但是参数或返回类型不同的多个方法互相称为重载方法，方法的重载并不意味着泛型。不过和泛型类似，我们可以将多种类型使用在同一个接口上。”

 “自由函数的重载”
 “我们可以定义一个名字为 raise(_:to:) 的函数，它可以通过针对 Double 和 Float 参数的不同重载来分别执行幂运算操作：”
 “Swift有一系列的复杂规则来确定到底使用哪个重载函数，这套规则基于函数是否是泛型，以及传入的参数是怎样的类型来确定使用优先级。整套规则十分复杂，不过它们可以被总结为一句话，那就是“选择最具体的一个”。也就是说，非通用的函数会优先于通用函数被使用。”
 “要特别注意，重载的使用是在编译期间静态决定的。也就是说，编译器会依据变量的静态类型来决定要调用哪一个重载，而不是在运行时根据值的动态类型来决定。我们如果将上面的 label 和 button 都放到一个 UIView 数组中，并对它们迭代并调用 log 的话，使用的都是泛型重载的版本：”

 “运算符的重载”

 
 */

precedencegroup ExponentiationPrecedence {
    associativity: left // 结合方向：左结合
    higherThan: MultiplicationPrecedence  // 优先级：比 乘法 更高
}

infix operator **: ExponentiationPrecedence

func **(lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}
func **(lhs: Float, rhs: Float) -> Float {
    return powf(lhs, rhs)
}

func **<I: BinaryInteger>(lhs: I, rhs: I) -> I {
    // 转换为 Int64，使用 Double 的重载计算结果
    let result = Double(Int64(lhs)) ** Double(Int64(rhs))
    return I(result)
}

//struct Set<Element: Hashable>:
//SetAlgebra, Hashable, Collection, ExpressibleByArrayLiteral
//{
///// 通过一个有限序列创建新的集合。
//init<Source: Sequence>(_ sequence: Source)
//where Source.Element == Element
//}

// 更通用更泛型
extension Sequence{
    func isSubset<S:Sequence>(of other:S,by areEquivalent:(Element,S.Element) -> Bool) -> Bool {
        for element in self {
            guard other.contains(where: {areEquivalent(element,$0)}) else {
                return false
            }
        }
        return true
    }
}

// 性能 O(n)
extension Sequence where Element : Hashable{
    func isSubset(of other:[Element]) -> Bool {
        let otherSet = Set(other)
        for element in self {
            guard otherSet.contains(element) else {
                return false
            }
        }
        return true
    }
}

// 性能 O(nm)
extension Sequence where Element : Equatable{
    
    func isSubset(of other:[Element]) -> Bool {
        for element in self {
            guard other.contains(element) else {
                return false
            }
        }
        return true
    }
    
}

class Chapter8: NSObject {
    
    func main() -> Void {
        let x = self.raise(2.0, to: 4.0)
        print("main======= \(x)")
        
        let y = 2.0**4.0
        print("main======= \(y)")
        
        
        let z:Int = 2**4
        print("main======= \(z)")
        
        let bool = [[1,2]].isSubset(of: [[1,2] as [Int], [3,4]]) { $0 == $1 } // true
        print("main======= \(bool)")
    }
    
    func raise(_ base: Double, to exponent: Double) -> Double {
        return pow(base, exponent)
    }
    
    func raise(_ base: Float, to exponent: Float) -> Float {
        return powf(base, exponent)
    }
    
}

/*
 “泛型的工作方式”
 编译器不知道 (包括参数和返回值在内的) 类型为 T 的变量的大小
 编译器不知道需要调用的 < 函数是否有重载，因此也不知道需要调用的函数的地址。
 
 Swift通过为泛型代码引入一层间接的中间层来解决这些问题。当编译器遇到一个泛型类型的值时，它会将其包装到一个容器中。这个容器有固定的大小，并存储这个泛型值。如果这个值超过容器的尺寸，Swift 将在堆上申请内存，并将指向堆上该值的引用存储到容器中去。”
 对于每个泛型类型的参数，编译器还维护了一系列一个或者多个所谓的目击表 (witness table)：其中包含一个值目击表，以及类型上每个协议约束一个的协议目击表。这些目击表 (也被叫做 vtable) 将被用来将运行时的函数调用动态派发到正确的实现去。
 “对于任意的泛型类型，总会存在值目击表，它包含了指向内存申请，复制和释放这些类型的基本操作的指针。这些操作对于像是 Int 这样的原始值类型来说，可能不需要额外操作，或者只是简单的内存复制，不过对于引用类型来说，这里也会包含引用计数的逻辑。值目击表同时还记录了类型的大小和对齐方式。”
 “我们这个例子中的泛型类型 T 将会包含一个协议目击表，因为 T 有 Comparable 这一个约束。对于这个协议声明的每个方法或者属性，协议目击表中都会含有一个指针，指向该满足协议的类型中的对应实现。在泛型函数中对这些方法的每次调用，都会在运行时通过目击表准换为方法派发。在我们的例子中，y < x 这个表达式就是以这种方式进行派发的。”
 
 泛型特化
 “相应地，因为需要经过的代码不是那么直接，所以这种做法的缺点是运行时性能会较低。对于单个的函数调用来说这点开销是可以忽略的，但是因为泛型在 Swift 中非常普及，所以它这种性能开销很容易堆叠起来，造成性能问题。标准库到处都是泛型，包括比较值的大小在内的很多常用操作必须尽可能快速。因为这类操作十分频繁，所以尽管泛型代码只是比非泛型代码慢一点点，开发者可能也会选择不去使用泛型版本。
 不过 Swift 可以通过泛型特化 (generic specialization) 的方式来避免这个额外开销。泛型特化是指，编译器按照具体的参数参数类型 (比如 Int)，将 min<T> 这样的泛型类型或者函数进行复制。特化后的函数可以将针对 Int 进行特殊优化，移除所有的非直接因素。所以 min<T> 针对 Int 的特化版本是这样的：”
 func min(_ x: Int, _ y: Int) -> Int {
     return y < x ? y : x
 }
 min 函数，而只调用了一次 Float 的版本，那很有可能只有 Int 的版本会被特化处理。你应该在编译的时候确保开启优化 (使用命令行的话，是 swiftc -O)，这样你可以用到所有可能的启发式算法来进行优化。”
 
 全模块优化
 
 */

extension Chapter8{
    
    func main1() -> Void {
        
    }
    
    func min<T:Comparable>(_ x:T,_ y:T) -> T {
        return y < x ? y : x
    }
    
    /*
     “总结一下，对于 min 函数，编译器生成的伪代码看上去会是这样的：
     func min<T: Comparable>(_ x: Box_T, _ y: Box_T,
     valueWTable_T: VTable, comparableWTable_T: VTable)
     -> Box_T
     {
         let xCopy = valueWTable_T.copy(x)
         let yCopy = valueWTable_T.copy(y)
         let result = comparableWTable_T.lessThan(yCopy, xCopy) ? y : x
         valueWTable_T.release(xCopy)
         valueWTable_T.release(yCopy)
     }
     */
}
