//
//  Chapter2.swift
//  函数式Swift-Chris Eidhof; Florian Kugler; Wouter Swierstra; 陈聿菡; 杜欣; 王巍
//
//  Created by tuyang on 2026/4/23.
//

import Cocoa

/*
 Map、Filter 和 Reduce
 
 “顶层函数和扩展
 你可能已经注意到，在本节的函数中我们使用了两种不同的方式来声明函数：顶层函数和类型扩展。在一开始创建 map 函数的过程中，为了简单起见，我们选择了顶层函数的版本作为例子进行展示。不过，最终我们将 map 的泛型版本定义为 Array 的扩展，这与它在 Swift 标准库中的实现方式十分相似。
 在 Swift 标准库最初的版本中，顶层函数仍然是无处不在的，但伴随 Swift 2 的诞生，这种模式被彻底地从标准库中移除了。随着协议扩展 (protocol extensions)，当前第三方开发者有了一个强有力的工具来定义他们自己的扩展 —— 现在我们不仅仅可以在 Array 这样的具体类型上进行定义，还可以在 Sequence 之类的协议上来定义扩展。”
 “我们建议遵循此规则，并把处理确定类型的函数定义为该类型的扩展。这样做的优点是自动补全更完善，有歧义的命名更少，以及 (通常) 代码结构更清晰”

 
 泛型和 Any 类型”
 “除了泛型，Swift 还支持 Any 类型，它能代表任何类型的值。从表面上看，这好像和泛型极其相似。Any 类型和泛型两者都能用于定义接受两个不同类型参数的函数。然而，理解两者之间的区别至关重要：泛型可以用于定义灵活的函数，类型检查仍然由编译器负责；而 Any 类型则可以避开 Swift 的类型系统 (所以应该尽可能避免使用)。”
 
 可选值
 可选链
 let myState = order.person?.address?.state
 
 可选映射
 
 */

extension Array{
    func mapUsingReduce<T>(_ transform:(Element) -> T) -> [T] {
        return reduce([]) { result, x in
            return result + [transform(x)]
        }
    }
    
    func filterUsingReduce(_ includeElement:(Element) -> Bool) -> [Element] {
        return reduce([]) { result, x in
           return includeElement(x) ? result + [x] : result
        }
    }
}

class Chapter2: NSObject {

    
    func main() -> Void {
        let paris = City(name: "Paris", population: 2241)
        let madrid = City(name: "Madrid", population: 3165)
        let amsterdam = City(name: "Amsterdam", population: 827)
        let berlin = City(name: "Berlin", population: 3562)
//        let cities = [paris, madrid, amsterdam, berlin]
        
        // 假设我们现在想筛选出居民数量至少一百万的城市，并打印一份这些城市的名字及总人口数的列表。我们可以定义一个辅助函数来换算居民数量：”
//        cities
//            .filter{$0.population > 1000}
//            .map(<#T##(Self.Element) -> T#>)

        let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
        
        let amount:Int? = cities["Paris"]
        switch amount {
            case 0?:print("No People")
            case (1..<1000)?:print("middle People")
            default:print("Big People")
        }
        print("amountamount========= \(amount)")
    }
    
    func increment(array:[Int]) -> [Int] {
        var result:[Int] = []
        for x in array {
            result.append(x + 1)
        }
        return result
    }
    
    func double(array:[Int]) -> [Int] {
        var result:[Int] = []
        for x in array {
            result.append(x*2)
        }
        return result
    }

}

struct City {
  let name: String
  let population: Int
}

/*
 案例研究：QuickCheck
 
 */

extension Chapter2
{
    func main2() -> Void {
        print("arbitrary========= \(Int.arbitrary())")
    }
}

protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int:Arbitrary{
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
    
    static func arbitrary(in range:CountableRange<Int>) -> Int {
        let diff = range.upperBound - range.lowerBound
        return range.upperBound + (Int.arbitrary()%diff)
    }
}

func plusIsCommutative(x:Int,y:Int) -> Bool {
    return (x + y) == (y + x)
}


