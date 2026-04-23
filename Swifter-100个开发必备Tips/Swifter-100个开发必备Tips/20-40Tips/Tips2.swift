//
//  Tips2.swift
//  Swifter-100个开发必备Tips
//
//  Created by tuyang on 2026/4/23.
//

import Cocoa

/*
Tip 21　static和class
 “swift中表示“类型范围作用域”这一概念的有两个不同的关键字，它们分别是static和class。这两个关键字确实都表达了这个意思”
 “在非class类型上下文中，我们统一使用static来描述类型作用域，包括在enum和struct中表述类型方法和类型属性时。在这两个值类型中，我们可以在类型范围内声明并使用存储属性、计算属性和方法。static适用的场景有下面这些：”
 “class关键字相对就明白许多，是专门用在class类型的上下文中的，可以用来修饰类方法及类的计算属性。要特别注意class中现在是不能出现存储属性的，我们如果写类似这样的代码的话：”
 
 
 Tip 22　多类型和容器”
 “Swift中有两个原生的容器类型，Array和Dictionay：”
 “如果我们要把不相关的类型放到同一个容器类型中的话，比较容易想到的是使用Any和AnyObject”(“这样的转换会造成部分信息的损失，我们从容器中取值时只能得到信息完全丢失后的结果，在使用时还需要进行一次类型转换。”)
 
 另一种做法是使用enum可以带有值的特点，将类型信息封装到特定的enum中。”
 enum IntOrString {
     case IntValue(Int)
     case StringValue(String)
 }
 
 
 Tip 23　default参数”
 func sayHello1(str1: String = "Hello", str2: String, str3: String) {
     println(str1 + str2 + str3)
 }

 Tip 24　正则表达式”

 Tip 25　模式匹配”

 Tip 26　…和..<
 0..<3都写了小于号了，自然是不包含最后的3的意思了。”

 Tip 27　AnyClass、元类型和.self”
 AnyClass在Swift中被一个typealias所定义：
 typealias AnyClass = AnyObject.Type,“通过AnyObject.Type这种方式所得到的是一个元类型（Meta）。“我们可以声明一个元类型来存储A这个类型本身，而从A中取出其类型时，我们需要使用到.self
 Bar.Type = 类型本身的类型（像个 “模具”）
 Bar.self = 类型本身的值（就是那个模具实体）

 
 Tip 28　接口和类方法中的Self”
 而在声明接口时，我们如果希望在接口中使用的类型就是实现这个接口本身的类型的话，就需要使用Self进行指代”
 
 
 Tip 29　动态类型和多方法”

 Tip 30　属性观察”
 在willSet和didSet中我们分别可以使用newValue和oldValue来获取将要设定的和已经设定的值。”
 在Swift中所声明的属性包括存储属性和计算属性两种。其中存储属性将会在内存中实际分配地址对属性进行存储，而计算属性则不包括背后的存储，只是提供set和get两种方法。在同一个类型中，属性观察和计算属性是不能同时存在的。也就是说，想在一个属性定义中同时出现set和willSet或didSet是一件办不到的事情。计算属性中我们可以通过改写set中的内容来达到和willSet及didSet同样的属性观察的目的”
 “因此在子类的重载属性中我们是可以对父类的属性任意地添加属性观察的，而不用在意父类中到底是存储属性还是计算属性：”

 
 
*/

//IntervalType的接口定义了一个方法，接受实现该接口的自身的类型，并返回一个同样的类型。
protocol IntervalType{
    func clamp(intervalToClamp:Self) -> Self
}

protocol Copyable {
    func copy() -> Self
}

class Bar : Copyable{
    
    var num:Int = 1
    
    required init() { }  // 必须加 required 初始化器

    func copy() -> Self {
        let instance = type(of: self).init()
        instance.num = num
        return instance
    }
    
    class func main() -> Void {
        
    }
}

class MyClass{
//    class var bar:Bar?
}


//我们想在protocol里定义一个类型域上的方法或者计算属性的话，应该用哪个关键字呢？答案是使用static进行定义，但是在用具体的类型来实现时还是要按照上面的规则：在struct或enum中仍然使用static，而在class里使用class关键字——虽然在protocol中定义时使用的是static：”
protocol MyProtocol{
    static func fool()
}

struct Point {
    let x:Double
    let y:Double

    // 存储属性
    static let zero = Point(x: 0, y: 0)
    
    // 计算属性
    static var ones: [Point] {
        return[
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 2)
        ]
    }
    
    static func add(p1:Point,p2:Point) -> Point {
        return Point(x: p1.x + p2.x, y: p1.y + p2.y)
    }
}

class Tips2: NSObject {

    func main() -> Void {
        let typeA = Bar.self
        typeA.main()
        print("typeA======= \(typeA)")
        
        let typeA1:AnyClass = Bar.self
        (typeA1 as! Bar.Type).main()

        let b = Bar()
        let c = b.copy()
        b.num = 100
        print("main======= \(b.num) \(c.num)")
    }
}


/*
 Tip 31　final
 final关键字可以用在class、func和var前面进行修饰，表示不允许对该内容进行继承或者重写操作
 1、类或者方法的功能确实已经完备了”
 2、子类继承和修改是一件危险的事情
 3、为了父类中某些代码一定会被执行
 性能考虑
 使用final的另一个重要理由是它可能带来性能的改善。因为编译器能够从final中获取额外的信息，因此可以对类或者方法调用进行额外的优化处理。但是这个优势在实际表现中可能带来的好处就算与Objective-C的动态派发相比也十分有限，因此在项目还有其他方面可以优化（一般来说会是算法或者图形相关内容导致性能瓶颈）的情况下，并不建议使用将类或者方法转为final的方式来追求性能的提升。”

 
 Tip 32　lazy修饰符和lazy方法”
 “在其他语言（包括Objective-C）中延时加载的情况是很常见的。我们在第一次访问某个属性时，要判断这个属性背后的存储是否已经存在，如果存在则直接返回，如果不存在则说明是首次访问，那么就进行初始化并存储后再返回。这样我们可以把这个属性的初始化时刻推迟，与包含它的对象的初始化时刻分开，以达到提升性能的目的。以Objective-C举例如下（虽然这里既没有费时操作，也不会因为使用延时加载而影响性能，但是作为一个最简单的例子，可以很好地说明问题）：”
 lazy 变量：读才初始化，赋值不初始化！，赋值会覆盖

 Tip 33　find
 已删除 firstIndex
 
 Tip 34　Reflection和MirrorType”
 在纯Swift范畴内也存在反射相关的一些内容，只不过相对来说功能要弱得多。

 
 Tip 35　隐式解包Optional

 Tip 36　多重Optional”

 Tip 37　Optional Map”

 Tip 38　Selector
 在Swift中没有@selector了，我们要生成一个selector的话现在只能使用字符串。Swift里对应原来SEL的类型是一个叫作Selector的结构体，它提供了一个接受字符串的初始化方法。上面的两个例子在Swift中等效的写法是：

 Tip 39　实例方法的动态调用
 在Swift中可以直接用Type.instanceMethod的语法来生成一个可以柯里化的方法。如果我们观察f的类型，可以知道它是：”
 let f: (classB) -> (Int) -> Int
 
 
 Tip 40　单例
 class MyClass {
     // 单例核心
     static let shared = MyClass()
     // 禁止外部 init
     private init() {}
 }

 
 */

struct Person {
    let name:String
    let age:Int
}

class classB {
    lazy var str: String = {
        let str = "1234"
        print("来了老弟=======")
        return str
    }()
    
    func method(num:Int) -> Int {
        return num + 1
    }
}

extension Tips2{
    func main2() -> Void {
        
        let f = classB.method
        let obj = classB()
        let result1 = f(obj)(1)
        
        print("resultresult=======  \(result1)")
        
        
        let method = Selector("callMe")
//        let method2 = Selector("callPhone:num:address")
        self.perform(method)
        
        let nums:[Int]? = [1,2,3]
        let result = nums.map { array in array.map { $0 * 2 } }

//        print("main2=======  \(b.str)")
        
        let arr = [1,2,3,4]
        arr.firstIndex(of: 2)

        let xm = Person(name: "1", age: 12)
        let mirror = Mirror(reflecting: xm)
        mirror.subjectType       // 被反射对象的类型（Any.Type）
        mirror.displayStyle      // 显示风格：struct/class/enum/tuple/optional/dictionary/collection等（Mirror.DisplayStyle）
        mirror.children          // 核心：存储属性/元素的集合，类型是 AnyCollection<Child>，Child = (label: String?, value: Any)
        mirror.superclassMirror   // 父类的Mirror（仅类有，struct/enum为nil）

//        print("main2=======  \(mirror.subjectType) \(mirror.displayStyle) \(mirror.children) \(mirror.superclassMirror)")
        print("main2=======  \(mirror.toDictionary())")

    }
    
    @objc func callMe() {
        print("callMe=======")
    }
    
    func callPhone(num:Int,address:String) {
        
    }

}


extension Mirror {
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        for child in self.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        // 递归父类（类才有）
        if let superMirror = self.superclassMirror {
            dict.merge(superMirror.toDictionary()) { $1 }
        }
        return dict
    }
}
