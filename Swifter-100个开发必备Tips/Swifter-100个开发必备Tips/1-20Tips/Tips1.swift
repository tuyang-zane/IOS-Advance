//
//  Tips1.swift
//  Swifter-100个开发必备Tips
//
//  Created by tuyang on 2026/4/22.
//

import Cocoa

/*
 Tip 1　柯里化（Currying）
 在Swift中可以将方法进行柯里化（Currying）
 也就是把接受多个参数的方法变换成接受第一个参数的方法，并且返回接受余下的参数、返回结果的新方法。举个例子，在Swift中我们可以这样写出多个括号的方法：”
 
 TargetAction
 它把不安全、容易崩溃、会泄漏、基于字符串的 OC Target-Action
 重构成了：
 安全、不崩溃、无泄漏、编译器检查的纯 Swift 版本。

 */

class Tips1: NSObject {
    
    let button = Control()

    func main() -> Void {
        let addToFour = addTwoNumbers(a: 4)
        let result = addToFour(6)
        print("main======= \(result)")
        
        // 绑定点击事件
//        button.setTarget(
//            target: self,
//            action: self.btnClicked, // 柯里化方法
//            controlEvent: .TouchUpInside
//        )

    }
    
    func addTwoNumbers(a:Int) -> (Int) -> Int {
        return { num in
            a + num
        }
    }
}

protocol TargetAction{
    func performAction()
}

struct TargetActionWrapper<T:AnyObject>:TargetAction {
    weak var target:T?
    let action:(T) -> () -> ()
    func performAction() {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case ValueChanged
    case TouchUpInside
}

class Control {
    var actions = [ControlEvent:TargetAction]()
    
    func setTarget<T:AnyObject>(target:T,action:@escaping (T) -> () -> (),controlEvent:ControlEvent) {
        actions[controlEvent] = TargetActionWrapper(target: target, action: action)
    }
    
    func removeTargetForControlEvent(controlEvent:ControlEvent) {
        actions[controlEvent] = nil
    }
    
    func performActionForControlEvent(controlEvent:ControlEvent) {
        actions[controlEvent]?.performAction()
    }
}

/*
 Tip 2　将protocol的方法声明为mutating
 “Swift的protocol不仅可以被class类型实现，也适用于struct和enum。因为这个原因，我们在写接口给别人用时需要多考虑是否使用mutating来修饰方法，比如定义为mutating func myMethod()。Swift的mutating关键字修饰方法是为了能在该方法中修改struct或enum的变量，所以如果你没在接口方法里写mutating的话，别人如果用struct或者enum来实现这个接口的话，就不能在方法里改变自己的变量了。比如下面的代码：”
 “在使用class来实现带有mutating的方法的接口时，具体实现的前面是不需要加mutating修饰的，因为class可以随意更改自己的成员变量。所以说在接口里用mutating修饰方法，对于class的实现是完全透明，可以当作不存在的。”
 */
protocol Vehicle {
    var numberOfWheels: Int{get}
    var color: NSColor{get set}
    mutating func changeColor()
}


struct Car:Vehicle {
    var numberOfWheels: Int = 4
    var color: NSColor = .black
    mutating func changeColor() {
        self.color = .white
    }
}

/*
 Tip 3　Sequence
 
 Tip 4　多元组（Tuple）
 (a,b) = (b,a)
 “现在我们写库的时候可以考虑直接返回一个带有NSError的多元组，而不是去填充地址了：
 func doSomethingMightCauseError() -> (Bool, NSError?) {
 
 }
 */

func swap<T>(a:inout T,b:inout T) {
    let temp = a
    a = b
    b = temp
}

func swapMe<T>(a:inout T,b:inout T) {
    (a,b) = (b,a)
}


/*
 Tip 5　@autoclosure和??操作符
 “@autoclosure做的事情就是把一句表达式自动地封装
  成一个闭包（closure），这样有时候在语法上会非常漂亮。”
 */

//func ??<T>(optional:T?,defaultValue:() -> T?) -> T? {
//    
//}

/*
 “可能你会有疑问，为什么这里要使用autoclosure，直接接受T作为参数并返回不行吗？这正是autoclosure的一个最值得称赞的地方。如果我们直接使用T，那么就意味着在??操作符真正取值之前，我们就必须准备好一个默认值，这个默认值的准备和计算是会降低效率的。但如果optional不是nil的话，就完全不需要这个默认值，而会直接返回optional解包后的值。这样一来，默认值就白白准备了，这样的“开销”是完全可以避免的，方法就是将默认值的计算推迟到optional判定为nil之后。”
 */
infix operator ??!
func ??!<T>(optional1:T?,defaultValue:@autoclosure () -> T) -> T {
    switch optional1{
        case .some(let value):
            return value
        case .none:
            return defaultValue()
    }
}

extension Tips1{
    func main5() -> Void {
        logIfTrue({return 2 > 1})
        logIfTrue({2 > 1})
        //“还可以更进一步，因为这个闭包是最后一个参数，所以可以用尾随闭包（trailing closure）的方式把大括号拿出来，然后省略括号，写成：”
        logIfTrue{2 > 1}
        
        // @autoclosure
        logIfTrue1(2 > 1)
        
        var level:Int? = 3
        var startLevel = 1
        var currentLevel = level ??! startLevel
        print("currentLevel======= \(currentLevel)")

    }
    
    func logIfTrue(_ predicate:() -> Bool) {
        if predicate() {
            print("predicate======= \(true)")
        }
    }
    
    /*
     “但是不管那种方式，要么书写起来十分麻烦，要么表达上不太清晰，看起来都让人很不舒服。于是@autoclosure登场了。我们可以改换方法参数，在参数名前面加上@autoclosure关键字：”
     */
    
    func logIfTrue1(_ predicate:@autoclosure () -> Bool) {
        if predicate() {
            print("predicate======= \(true)")
        }
    }

}


/*
 Tip 6　Optional Chaining”
 “使用Optional Chaining可以让我们省去很多不必要的判断和取值步骤，但是在使用的时候需要小心“陷阱”。”
 
 
 */
extension Tips1{
    var xiaoming:Chirld?{
        return nil
    }
    
    func main6() -> Void {
        let name = xiaoming?.pet?.toy?.name
        
        let playClosure = {(child:Chirld) -> () in
            child.pet?.toy?.play()
        }
        
    }
}

class Toy {
    let name:String
    init(name: String) {
        self.name = name
    }
    func play() {
        
    }
}

class Pet {
    var toy:Toy?
}

class Chirld {
    var pet:Pet?
}


/*
 Tip 7　操作符”
 “Swift的操作符是不能定义在局部域中的，因为一个操作符至少要能在全局范围使用，否则也就失去意义了”
*/

// 1. 加法优先级（和 + - 一样）
//infix operator +* : AdditionPrecedence

// 2. 乘法优先级（和 * / 一样）
infix operator +* : MultiplicationPrecedence

// 3. 逻辑优先级（最低，和 == 类似）
//infix operator +* : ComparisonPrecedence


struct Vector2D {
    var x = 0.0
    var y = 0.0
}

func +(lhs:Vector2D,rhs:Vector2D) -> Vector2D {
    return .init(x:lhs.x + rhs.x,y: lhs.y + rhs.y)
}

func +*(lhs:Vector2D,rhs:Vector2D) -> Double {
    return lhs.x*rhs.x + lhs.y*rhs.y
}

func -(lhs:Vector2D,rhs:Vector2D) -> Vector2D {
    return .init(x:lhs.x - rhs.x,y: lhs.y - rhs.y)
}


/*
 Tip 8　func的参数修饰
 有可能的地方，都被默认为是不可变的，也就是用let进行声明的。这样不仅可以确保安全，”
 func incrementor(let variable: Int) -> Int {
     return ++variable
 }
 
 Tip 9　方法参数名称省略
 
 Tip 10　字面量转换
 BooleanLiteralConvertible
 ArrayLiteralConvertible
 IntegerLiteralConvertible
 ...
 让自定义类型，直接支持写 true /false
 ExpressibleByBooleanLiteral
 = “能用布尔字面量初始化”
 
 */

extension Tips1{
    func main10() -> Void {
        let a:MyBool = true
        let b:MyBool = false
        print(a) // 1
        print(b) // 0
    }
}

enum MyBool: Int {  // 这里加 : Int
    case myFalse = 0
    case myTrue = 1
}

extension MyBool:ExpressibleByBooleanLiteral{
    init(booleanLiteral value: BooleanLiteralType) {
        self = value ? MyBool.myTrue : MyBool.myFalse
    }
}

func incrementor(variable:Int) -> Int {
    return variable + 1
}


/*
 Tip 11　下标
 “作为一门代表了先进生产力的语言，Swift是允许我们自定义下标的。我们不仅能对自己写的类型自定义下标，也能对那些已经支持下标访问的类型（没错，就是Array和Dictionay）进行扩展。我们重点来看看向已有类型添加下标访问的情况吧，比如说Array，我们很容易就可以在Swift的定义文件（在Xcode中按住Cmd键，并单击任意一个Swift内的类型或者函数就可以访问到）里，找到Array已经支持的下标访问类型：”
 
 Tip 12　方法嵌套”
 
 
 Tip 13　命名空间”
 “在我们进行app开发时，默认添加到app的主target的内容都是处于同一个命名空间中的，我们可以通过创建Cocoa (Touch) Framework的target的方法来新建一个module，这样我们就可以在两个不同的target中添加同样名字的类型了：”

 */

extension Tips1{
    func main11() -> Void {
        var arr = [1,2,3,4,5]
        print("main11======= \(arr[[0,2,3]])")
        arr[[0,2,3]] = [-1,-3,-4]
        print("main11======= \(arr)")
    }
}

extension Array {
    // 自定义下标：传入 [Int] 索引数组 → 批量读写
    subscript(input: [Int]) -> ArraySlice<Element> {
        get {
            var result = ArraySlice<Element>()
            for i in input {
                // 检查越界
                assert(i < self.count, "索引越界")
                result.append(self[i])
            }
            return result
        }
        set {
            for (index, i) in input.enumerated() {
                assert(i < self.count, "索引越界")
                self[i] = newValue[index]
            }
        }
    }
}

/*
 Tip 14　Any和AnyObject
 AnyObject可以代表任何class类型的实例。
 Any可以表示任意类型，甚至包括方法（func）类型。
 “假设原来的某个API返回的是一个id，那么在Swift中就被映射为AnyObject?”
 func someMethod() -> AnyObject? {}
 “由AnyObject来表示，于是Apple提出了一个更为特殊的Any，除了class以外，它还可以表示包括struct和enum在内的所有类型。”
 
 Tip 15　typealias和泛型接口”
 typealias是用来为已经存在的类型重新定义名字的，通过命名，可以使代码变得更加清晰”
 typealias Location = CGPoint
 typealias Distance = Double”
 “typealias是单一的，也就是说你必须指定将某个特定的类型通过typealias赋值为新名字，而不能将整个泛型类型进行重命名”
 “typealias Worker = Person<T>
 typealias Worker<T> = Person<T>”
 “一旦泛型类型的确定性得到保证后，我们就可以重命名了：
 class Person<T> {}
 typealias WorkId = String
 typealias Worker = Person<WorkId>”
 
 
 Tip 16　可变参数函数”
 “func sum(input: Int...) -> Int {
     //...
 }”

 Tip 17　初始化方法顺序”
 1、设置子类自己需要初始化的参数，power = 10。
 2、调用父类的相应的初始化方法，super.init()。
 3、对父类中的需要改变的成员进行设定，name = "tiger"。”
 
 */

class Cat {
    var name:String
    init() {
        self.name = "cat"
    }
}

class Tiger:Cat{
    let pow:String
    init(pow: String) {
        self.pow = pow
//        自动完成 super.init()
//        super.init()
//        name = "Tiger"
    }
}

extension Tips1{
    func main14() -> Void {
        let swiftInt:Int = 1
        let swiftString:String = "miao"
//        var array:[AnyObject] = []
        var array:[Any] = []
        array.append(swiftInt)
        array.append(swiftString)
        print("main14======= \(array)")
    }
}

protocol GeneratorType{
    associatedtype Element
    func next() -> Element?
}


/*
 Tip 18　Designated、Convenience和Required”
 “与designated初始化方法对应的是在init前加上convenience关键字的初始化方法。这类方法是Swift初始化方法中的“二等公民”，只作为补充和提供使用上的方便。所有的convenience初始化方法都必须调用同一个类
  中的designated初始化完成设置，另外convenience的初始化方法是不能被子类重写的，也不能从子类中以super的方式被调用”

 
 */

class ClassA {
    let numA:Int
    init(num: Int) {
        self.numA = num
    }
    convenience init(bigNum: Int) {
        self.init(num: bigNum)
    }
}


class ClassB: ClassA {
    let numB:Int
    convenience init(numB: Int) {
        self.numB += numB
        super.init(numA: self.numB)
    }
}
