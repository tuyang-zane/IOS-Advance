//
//  Chapter6.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/20.
//

import Cocoa
import CoreLocation
import AppKit
import Dispatch

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
    
    var savedClosure: (() -> Void)?

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
    var buttonTapped:((_ buttonIndex:Int) -> ())?
    init(buttons: [String] = ["ok","cancel"]) {
        self.buttons = buttons
    }
    func fire() -> Void {
        buttonTapped?(1)
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
        
//        alert.buttonTapped = logger.buttonTapped(atIndex:)
        alert.buttonTapped = {logger.buttonTapped(atIndex:$0)}

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

/*
 “inout 参数和可变方法”
 “如果你有一些 C 或者 C++ 背景的话，在 Swift 中 inout 参数前面使用的 & 符号可能会给你一种它是传递引用的印象。但事实并非如此，inout 做的事情是通过值传递，然后复制回来，而并不是传递引用。 引用官方《Swift 编程语言》中的话：
 inout 参数将一个值传递给函数，函数可以改变这个值，然后将原来的值替换掉，并从函数中传出。
 在结构体和类中，我们提到过 inout 参数，并且了解了一些 mutating 方法和接受 inout 参数的方法之间的异同。”
 “为了了解到底什么样的表达式可以被当作 inout 参数传递，我们需要对 lvalue 和 rvalue 进行区分。lvalue 描述的是一个内存地址，它是“左值 (left value)” 的缩写，因为 lvalues 是可以存在于赋值语句左侧的表达式。举例来说，array[0] 是一个 lvalue，它代表的是数组中第一个元素所在的内存位置。而 rvalue 描述的是一个值。2 + 2 是一个 rvalue，它描述的是 4 这个值。你不能把 2 + 2 或者 4 放到赋值语句的左侧。”
 
 计算属性
 “有两种方法和其他普通的方法有所不同，那就是计算属性和下标方法。计算属性看起来和常规的属性很像，但是它并不使用任何内存来存储自己的值。相反，这个属性每次被访问时，返回值都将被实时计算出来。下标的话，就是一个遵守特殊的定义和调用规则的方法。”
 
 “属性观察者必须在声明一个属性的时候就被定义，你无法在扩展里进行追加。所以，这不是一个提供给类型用户的工具，它是专门为类型的设计者而设计的。willSet 和 didSet 本质上是一对属性的简写：一个负责为值提供存储的私有存储属性，以及一个公开的计算属性。这个计算属性的 setter 会在将值存储到存储属性中之前和/或之后，进行额外的工作。这和 Foundation 中的键值观察有本质的不同，键值观察通常是对象的消费者来观察对象内部变化的手段，而与类的设计者是否希望如此无关。
 不过，你可以在子类中重写一个属性，来添加观察者。”

 延迟存储属性
 “延迟初始化一个值在 Swift 中是一种常见的模式，Swift 为此准备了一个特殊的 lazy 关键字来定义一个延迟属性 (lazy property)。需要注意，延迟属性会被自动声明为 var，因为它的初始值在初始化方法完成时是不会被设置的。Swift 对 let 常数有严格的规则，它必须在实例的初始化方法完成之前就拥有值。延迟修饰符是编程记忆化的一种特殊形式。”
 “比如，如果我们有一个 view controller 来显示 GPSTrack，我们可能会想展示一张追踪的预览图像。通过将属性改为延迟加载，我们可以将昂贵的图像生成工作推迟到属性被首次访问”
 
 
 “键路径
 Swift 4 中添加了键路径的概念。键路径是一个指向属性的未调用的引用，它和对某个方法的未使用的引用很类似。键路径也为 Swift 的类型系统补全了缺失的很大一块拼图。在之前，你无法像引用方法 (比如 String.uppercased) 那样持有一个对类型属性 (比如 String.count) 的引用。和 Objective-C 及 Foundation 中的键路径相比，除了拥有共同的名字以外，Swift 中的键路径有很大不同。我们会在稍后再涉及这些区别。
 键路径表达式以一个反斜杠开头，比如 \String.count。反斜杠是为了将键路径和同名的类型属性区分开来 (假如 String 也有一个 static count 属性的话，String.count 返回的就会是这个属性值了)。类型推断对键路径也是有效的，在上下文中如果编译器可以推断出类型[…]”
 
 */

extension Chapter6{
    
    func chapter6_3() -> Void {
        var i = 12
        increment(value: &i)
        print("chapter6_3=====  \(i)")
        
        incrementTenTimes(value: &i)
        print("chapter6_3=====  \(i)")
        
        let fun:() -> Int
        do{
            var array = [0]
            fun = incref(point: &array)
        }
        print("chapter6_3=====  \(fun())")
    }
    
    func increment(value: inout Int){
        value += 1
    }
    
    func incrementTenTimes(value: inout Int){
        func incr(){
            value += 1
        }
        incr()
    }

    func incref(point:UnsafeMutablePointer<Int>) -> () -> Int{
        return {
            point.pointee += 1
            return point.pointee
        }
    }
}

struct GPSTrack {
//  var record:[(CLLocation,Date)] = []
    
//  如果我们想要将 record 属性作为外部只读，内部可读写的话，我们可以使用 private(set) 或者 fileprivate(set) 修饰符：”
    private(set) var record:[(CLLocation,Date)] = []
    
//    lazy var preview: NSImage = {
//        statements
//        return value
//    }()
}

extension GPSTrack{
    var timestamps: [Date] {
        return record.map{$1}
    }
}

struct pointNew {
    var x:Double
    var y:Double
    private(set) lazy var distanceFromOrigin:Double = (x*x + y*y).squareRoot()
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/*
 自动闭包
 “我们都对“逻辑与”，也就是 && 操作符如何对其参数求值很熟悉了。它会先对左边的操作数求值，如果左边的求值为 false 时，则直接返回。只有当左侧值为 true 时，右边的操作数才会被求值。这是因为，一旦左边的结果是 false 的话，整个表达式就不可能是 true 了。这种行为又被叫做短路求值。举个例子，如果我们想要检查数组的第一个元素是否满足某个要求”
 “在 Swift 中有一个很好的特性，能让代码更漂亮。我们也可以使用 @autoclosure 标注来告诉编译器它应该将某个参数用闭包表达式包装起来。通过这种方式构建的 and 的定义和上面几乎一样，除了在 r 参数前加上了 @autoclosure 标注。”
 “现在，and 的使用现在就要简单得多了，因为我们不再需要将第二个参数封装到闭包中了。我们只需要像使用普通的 Bool 值那样来使用它，编译器将“透明地”把参数包装到闭包表达式中：”
 
 @escaping 标注     // 1. 非逃逸闭包（默认，不能存、不能异步）
 “一个被保存在某个地方等待稍后 (比如函数返回以后) 再调用的闭包就叫做逃逸闭包。而传递给 map 的闭包会在 map 中被直接使用。这意味着编译去不需要改变在闭包中被捕获的变量的引用计数。”
 “闭包默认是非逃逸的。如果你想要保存一个闭包稍后再用，你需要将闭包参数标记为 @escaping。编译器将会对此进行验证，如果你没有将闭包标记为 @escaping，编译器将不允许你保存这个闭包 (或者比如将它返回给调用者)。在排序描述符的例子中，我们已经看到过几个必须使用 @escaping 的函数参数了：”
 
 func sortDescriptor<Value, Key>(
 key: @escaping (Value) -> Key,
 by areInIncreasingOrder: @escaping (Key, Key) -> Bool)
 -> SortDescriptor<Value>
 {
     return { areInIncreasingOrder(key($0), key($1)) }
 }
 
 withoutActuallyEscaping
 “可能你会遇到这种情况：你确实知道一个闭包不会逃逸，但是编译器无法证明这点，所以它会强制你添加 @escaping 标注。”
 “我们可以通过为参数添加 @escaping 标注来修正这个问题，但是在这种情况下，我们确实知道闭包不会逃逸，因为延迟集合的生命周期是绑定在函数上的。Swift 为这种情况提供了一个特例函数，那就是 withoutActuallyEscaping。它可以让你把一个非逃逸闭包传递给一个期待逃逸闭包作为参数的函数。”
 
 “注意，使用 withoutActuallyEscaping 后，你就进入了 Swift 中不安全的领域。让闭包的复制从 withoutActuallyEscaping 调用的结果中逃逸的话，会造成不确定的行为。”
 */

extension Array{
    
    func all(matching predicate:@escaping (Element) -> Bool) -> Bool {
        return self.lazy.filter({!predicate($0)}).isEmpty
    }

    func all1(matching predicate:(Element) -> Bool) -> Bool {
        return withoutActuallyEscaping(predicate) { escapingClosure in
            return self.lazy.filter({!escapingClosure($0)}).isEmpty
        }
    }
}

extension Chapter6{
    
     func chapter6_4() -> Void {
//         let bool = self.and(true) {return false}
//         if and1(true, false){}
//         print("chapter6_4=====  \(bool)")

         let bool = [1,2,3,4].all(matching: {$0 % 2 == 0})
         
         let bool1 = [1,2,3,4].all1(matching: {$0 % 2 == 0})

         print("chapter6_4======= \(bool) \(bool1)")

         normalFunc {
             print("normalFunc 执行")
         }
         
         escapingFunc {
             print("escapingFunc 执行")
         }
         
         RunLoop.current.run(until: Date().addingTimeInterval(5))

         print("函数已返回，闭包还没执行\n")

     }
    
    // 1. 非逃逸闭包（默认，不能存、不能异步）
    func normalFunc(_ closure: () -> Void) {
        closure() // 必须在这里执行
    }
    
    func escapingFunc(_ closure: @escaping () -> Void) {
        
        // 存到外面变量 → 必须 @escaping
        savedClosure = closure
        
        // 异步延时执行 → 也必须 @escaping
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            closure()
        }
    }
    
    func transform(_ input:Int,with f:((Int) -> Int)?) -> Int {
        print("使用可选值重载")
        guard let f = f else { return input }
        return f(input)
    }
    
    func transform(_ input:Int,with f:((Int) -> Int)) -> Int {
        print("使用非可选值重载")
        return f(input)
    }

    
     func and(_ l:Bool,_ r:() -> Bool) -> Bool{
          guard l else {
              return false
          }
          return r()
     }
    
    func and1(_ l:Bool,_ r:@autoclosure () -> Bool) -> Bool{
         guard l else {
             return false
         }
         return r()
    }

}
