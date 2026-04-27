//
//  Chatper9.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/22.
//

import Cocoa

/*
 协议
 “Swift 的协议和 Objective-C 的协议不同。Swift 协议可以被用作代理，也可以让你对接口进行抽象 (比如 IteratorProtocol 和 Sequence)。它们和 Objective-C 协议的最大不同在于我们可以让结构体和枚举类型满足协议。除此之外，Swift协议还可以有关联类型。我们还可以通过协议扩展的方式为协议添加方法实现。我们会在面向协议编程的部分讨论所有这些内容。”
 
  1、不过在 Swift 中，Sequence 中的代码共享是通过协议和协议扩展来实现的。通过这么做，Sequence 协议和它的扩展在结构体和枚举这样的值类型中依然可用，而这些值类型是不支持子类继承的。”
  2、“不再依赖于子类让类型系统更加灵活。在 Swift (以及其他大多数面向对象的语言) 中，一个类只能有一个父类。当我们创建一个类时，我们必须同时选择父类，而且我们只能选择一个父类，我们无法创建比如同时继承了 AbstractSequence 和 Stream 的类。这有时候会成为问题。在 Cocoa 中就有一些例子，比如 NSMutableAttributedString，框架的设计师必须在 NSAttributedString 和 NSMutableString 之间选择一个父类。”
  3、协议扩展是一种可以在不共享基类的前提下共享代码的方法。协议定义了一组最小可行的方法集合，以供类型进行实现。而类型通过扩展的方式在这些最小方法上实现更多更复杂的特性。”
 
 
 面向协议编程
 “比如在一个图形应用中，我们想要进行两种渲染：我们会将图形使用 Core Graphics 的 CGContext 渲染到屏幕上，或者创建一个 SVG 格式的图形文件。我们可以从定义绘图 API 的最小功能集的协议开始进行实现”
 
 协议扩展
 “Swift 的协议的另一个强大特性是我们可以使用完整的方法实现来扩展一个协议。你可以扩展你自己的协议，也可以对已有协议进行扩展。比如，我们可以向 Drawing 添加一个方法，给定一个中心点和一个半径，渲染一个圆：”
 作为协议的作者，当你想在扩展中添加一个协议方法，你有两种方法。首先，你可以只在扩展中进行添加，就像我们上面 addCircle 所做的那样。或者，你还可以在协议定义本身中添加这个方法的声明，让它成为协议要求的方法。协议要求的方法是动态派发的，而仅定义在扩展中的方法是静态派发的。它们的区别虽然很微小，但不论对于协议的作者还是协议的使用者来说，都十分重要。”

 通过协议进行代码共享相比与通过继承的共享，有这几个优势”
 1、“我们不需要被强制使用某个父类。”
 2、“我们可以让已经存在的类型满足协议 (比如我们让 CGContext 满足了 Drawing)。子类就没那么灵活了，如果 CGContext 是一个类的话，我们无法以追溯的方式去变更它的父类。”
 3、“协议既可以用于类，也可以用于结构体，而父类就无法和结构体一起使用了。”
 4、“最后，当处理协议时，我们无需担心方法重写或者在正确的时间调用 super 这样的问题。”
 
 
 “当我们将 otherSample 定义为 Drawing 类型的变量时，编译器会自动将 SVG 值封装到一个代表协议的类型中，这个封装被称作存在容器 (existential container)，我们会在本章后面讨论具体细节。现在，我们可以这样考虑这个行为：当我们对存在容器调用 addCircle 时，方法是静态派发的，也就是说，它总是会使用 Drawing 的扩展。如果它是动态派发，那么它肯定需要将方法的接收者 SVG 类型考虑在内。”

  
 “协议的两种类型”
 “带有关联类型的协议和普通的协议是不同的。”
 
 类型抹消
 “在未来版本的 Swift 中，我们可能可以通过类似这样的代码解决该问题：
 let iterator: Any<IteratorProtocol where .Element == Int> = ConstantIterator()
 不过现在，我们还不能表达这个。不过，我们可以将 IteratorProtocol 用作泛型参数的约束：
 func nextInt<I: IteratorProtocol>(iterator: inout I) -> Int?
 where I.Element == Int {
    return iterator.next()
 }”
 
 “带有 Self 的协议”
 “带有 Self 要求的协议在行为上和那些带有关联类型的协议很相似。最简单的带有 Self 的协议是 Equatable。它有一个 (运算符形式的) 方法，用来比较两个元素：”
 protocol Equatable {
   static func ==(lhs: Self, rhs: Self) -> Bool
 }

 
 协议内幕
 对于普通的协议 (也就是没有被约束为只能由 class 实现的协议)，会使用不透明存在容器 (opaque existential container)。不透明存在容器中含有一个存储值的缓冲区 (大小为三个指针，也就是 24 字节)；一些元数据 (一个指针，8 字节)；以及若干个目击表 (0 个或者多个指针，每个 8 字节)。如果值无法放在缓冲区里，那么它将被存储到堆上，缓冲区里将变为存储引用，它将指向值在堆上的地址。元数据里包含关于类型的信息 (比如是否能够按条件进行类型转换等)。关于目击表，我们接下来会马上对它进行讨论。”
 “目击表是让动态派发成为可能的关键。它为一个特定的类型将协议的实现进行编码：对于协议中的每个方法，表中会包含一个指向特定类型中的实现的入口。有时候这被称为 vtable。某种意义上来说，在我们前面创建第一版的 AnyIterator 时，我们手动实现了一个目击表。”
 
 */

protocol Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool
}

class IntIterator {
    var nextImpl: () -> Int?
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Int {
        var iteratorCopy = iterator
        self.nextImpl = { iteratorCopy.next() }
    }
}

class Chatper9: NSObject {

    func main() -> Void {
//        var otherSample:Drawing = SVG()
        
    }

}

struct ConstantIterator1:IteratorProtocol1 {
    mutating func next() -> Int? {
        return 1
    }
}

public protocol IteratorProtocol1{
    // 关联类型
    associatedtype Element
    mutating func next() -> Element?
}

protocol Drawing{
    mutating func addEllipse(rect: CGRect, fill: NSColor)
    mutating func addRectangle(rect: CGRect, fill: NSColor)
}

extension Drawing{
    mutating func addCircle(center: CGPoint, radius: CGFloat, fill: NSColor) {
        let diameter = radius * 2
        let origin = CGPoint(x: center.x - radius, y: center.y - radius)
        let size = CGSize(width: diameter, height: diameter)
        let rect = CGRect(origin: origin, size: size)
        addEllipse(rect: rect, fill: fill)
    }
}

extension CGContext:Drawing{
    func addEllipse(rect: CGRect, fill: NSColor) {
    }
    func addRectangle(rect: CGRect, fill: NSColor) {
        
    }
}

//struct SVG {
//    var rootNode = XMLNode(tag:"svg")
//    mutating func append(node: XMLNode) {
//        rootNode.children.append(node)
//    }
//}
//
//extension SVG{
//    mutating func addCircle(center: CGPoint, radius: CGFloat, fill: UIColor) {
//    var attributes: [String:String] = ["cx": "\(center.x)",
//                                       "cy": "\(center.y)",
//                                       "r": "\(radius)",
//                                       ]
//                                       attributes["fill"] = String(hexColor: fill)
//                                       append(node: XMLNode(tag: "circle", attributes: attributes))
//                                       }
//}
