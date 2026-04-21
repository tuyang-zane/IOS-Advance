//
//  Chapter6.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/20.
//

import Cocoa

/*
 函数
 “要理解 Swift 中的函数和闭包，你需要切实弄明白三件事情，我们把这三件事按照重要程度进行了大致排序：

 1、函数可以像 Int 或者 String 那样被赋值给变量，也可以作为另一个函数的输入参数，或者另一个函数的返回值来使用。
 2、函数能够捕获存在于其局部作用域之外的变量。
 3、有两种方法可以创建函数，一种是使用 func 关键字，另一种是 { }。在 Swift 中，后一种被称为闭包表达式。”
 
 1:
 “在 Swift 和其他很多现代语言中，函数被称为“头等对象”。你可以将函数赋值给变量，稍后，你可以将它作为参数传入给要调用的函数，函数也可以返回一个函数。”


 2:
 “在编程术语里，一个函数和它所捕获的变量环境组合起来被称为闭包。上面 f 和 g 都是闭包的例子，因为它们捕获并使用了一个在它们外部声明的非局部变量”
 
 3:  [1,2,3,4].map{$0 * 2}
 @1:“如果你将闭包作为参数传递，并且你不再用这个闭包做其他事情的话，就没有必要现将它存储到一个局部变量中。可以想象一下比如 5*i 这样的数值表达式，你可以把它直接传递给一个接受 Int 的函数，而不必先将它计算并存储到变量里。”
 [1, 2, 3].map( { (i: Int) -> Int in return i * 2 } )

 @2:“如果编译器可以从上下文中推断出类型的话，你就不需要指明它了。在我们的例子中，从数组元素的”“类型可以推断出传递给 map 的函数接受 Int 作为参数，从闭包的乘法结果的类型可以推断出闭包返回的也是 Int。”
 [1, 2, 3].map( { i in return i * 2 } )
 
 @3:“如果闭包表达式的主体部分只包括一个单一的表达式的话，它将自动返回这个表达式的结果，你可以不写 return。”
 [1, 2, 3].map( { i in i * 2 } )

 @4:“Swift 会自动为函数的参数提供简写形式，$0 代表第一个参数，$1 代表第二个参数，以此类推。”
 [1, 2, 3].map( { $0 * 2 } )
 
 @5:“如果函数的最后一个参数是闭包表达式的话，你可以将这个闭包表达式移到函数调用的圆括号的外部。这样的尾随闭包语法在多行的闭包表达式中表现非常好，因为它看起来更接近于装配了一个普通的函数定义，或者是像 if (expr) { } 这样的执行块的表达形式。”
 [1, 2, 3].map() { $0 * 2 }
  
 @6:“最后，如果一个函数除了闭包表达式外没有别的参数，那么方法名后面的调用时的圆括号也可以一并省略。”
 [1, 2, 3].map { $0 * 2 }
  */


class Chapter6: NSObject {
    
    func counterFunc() -> (Int) -> String {
        var counter = 0
        func innerFunc(i:Int) -> String{
            counter += i
            return "running total: \(counter)"
        }
        return innerFunc
    }
    
    func doubler(i:Int) -> Int {
        return i * 2
    }
    
    func chapter6() -> Void {
        let funVar = printInt
        funVar(2)
        
        self.useFunction(function: funVar)
        self.useFunction(function: printInt)
        
        let reFunc = returnFunc()
        print("chapter6=====  \(reFunc(12))")
        
        let countFunc = counterFunc()
        print("counterFunc=====  \(countFunc(3))")
        print("counterFunc=====  \(countFunc(4))")
        
        print("chapter6=====  \([1,2,3,4].map(doubler))")
        
        let doublerAlt = {(i:Int) -> Int in return 2 * i}
        print("chapter6=====  \([1,2,3,4].map(doublerAlt))")

        print("chapter6=====  \([1,2,3,4].map{$0 * 2})")

        [1,2,3,4].map{i in i*2}
    }

    func useFunction(function:(Int) -> ()) {
        function(3)
    }
    
    func printInt(i:Int) {
        print("printInt=====  \(i)")
    }
    
    func returnFunc() -> (Int) -> String {
        func innerFunc(i:Int) -> String{
            return "you passed: \(i)"
        }
        return innerFunc
    }
}


/*
 函数的灵活性
 “这是运行时编程的一个很酷的用例，排序描述符的数组可以在运行时构建，这一点在实现比如用户点击某一列时按照该列进行排序这种需求时会特别有用。”
 
 “局部函数和变量捕获”
 
 函数作为代理
 “一句话总结：在代理和协议的模式中，并不适合使用结构体。”

 */

//“这定义了一个只针对类的协议”
protocol AlertViewDelegate{
    mutating func buttonTapped(atIndex:Int)
}

struct TapLogger:AlertViewDelegate {
    var taps:[Int] = []
    mutating func buttonTapped(atIndex index: Int) {
        taps.append(index)
    }
}

struct TapLogger1 {
    var taps:[Int] = []
    mutating func buttonTapped(atIndex index: Int) {
        taps.append(index)
    }
}


class AlertView {
    var buttons:[String]
    var delegate: AlertViewDelegate?
    init(buttons: [String] = ["ok","cancel"]) {
        self.buttons = buttons
    }
    func fire() -> Void {
        delegate?.buttonTapped(atIndex: 1)
    }
}

typealias SortDescriptor<Value> = (Value,Value) -> Bool

extension Chapter6{
    func chapter6_2() -> Void {
        let alert = AlertView()
        var logger = TapLogger()
        //“当我们给 alert.delegate 赋值的时候，Swift 将结构体进行了复制。所以 taps 并没有被记录在 logger 中”“而是被添加到了 alert.delegate 里。更糟糕的是，当我们这么赋值后，我们将失去值类型的信息。想要将记录值取回，我们需要一个条件类型转换”
        alert.delegate = logger
        alert.fire()
        
        if let thrLogger = alert.delegate as? TapLogger {
            print("descriptors=====  \(thrLogger.taps)")
        }

        print("descriptors=====  \(logger.taps)")

        let sotrtByYear:SortDescriptor<PersonOther> = {$0.yearOfBirth < $1.yearOfBirth}
        let sotrtByname:SortDescriptor<PersonOther> = {$0.last.localizedStandardCompare($1.last) == .orderedAscending}
    }
    
    //Swift 版本： lexicographicallyPrecedes
    func chapter6_1() -> Void {
        let people = [
            PersonOther(first: "Emily", last: "Young", yearOfBirth: 2002),
            PersonOther(first: "David", last: "Gray", yearOfBirth: 1991),
            PersonOther(first: "Robert", last: "Barnes", yearOfBirth: 1985),
            PersonOther(first: "Ava", last: "Barnes", yearOfBirth: 2000),
            PersonOther(first: "Joanne", last: "Miller", yearOfBirth: 1994),
            PersonOther(first: "Ava", last: "Barnes", yearOfBirth: 1998),
        ]
        
        //lexicographicallyPrecedes
       let people1 = people.sorted { p0, p1 in
            let left = [p0.last,p0.first]
            let right = [p1.last,p1.first]
            return left.lexicographicallyPrecedes(right) {
                $0.localizedStandardCompare($1) == .orderedAscending
            }
        }
        
        print("descriptors=====  \(people1)")

        //NSSortDescriptor
        let lastDescriptor = NSSortDescriptor(key: #keyPath(PersonOther.last), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let firstDescriptor = NSSortDescriptor(key: #keyPath(PersonOther.first),
        ascending: true,
        selector: #selector(NSString.localizedStandardCompare(_:)))
        let yearDescriptor = NSSortDescriptor(key: #keyPath(PersonOther.yearOfBirth),
        ascending: true)
        
        let descriptors = [lastDescriptor, firstDescriptor, yearDescriptor]
        (people as NSArray).sortedArray(using: descriptors)
        
        print("descriptors=====  \(people)")

    }
}


@objcMembers
final class PersonOther:NSObject{
    let first: String
    let last: String
    let yearOfBirth: Int
    init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
    }
}

extension Array where Element:Comparable{
    mutating func merge(lo:Int,mi:Int,hi:Int) {
        var temp:[Element] = []
        var tmp: [Element] = []
        var i = lo, j = mi
        while i != mi && j != hi {
        if self[j] < self[i] {
           tmp.append(self[j])
           j += 1
        } else {
           tmp.append(self[i])
           i += 1
           }
        }
        tmp.append(contentsOf: self[i..<mi])
        tmp.append(contentsOf: self[j..<hi])
        replaceSubrange(lo..<hi, with: tmp)
    }
}
