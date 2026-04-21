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
