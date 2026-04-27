//
//  Tips3.swift
//  Swifter-100个开发必备Tips
//
//  Created by tuyang on 2026/4/23.
//

import Cocoa

/*
 Tip 41　条件编译
 Swift还是为我们提供了几种简单的机制来根据需求定制编译内容的。
 首先#if这一套编译标记还是存在的，使用的语法也和原来没有区别：
 #if <condition>
 #elseif <condition>
 #else
 #endif
 
 
 Tip 42　编译标记
 除了// MARK: 以外，Xcode还支持另外几种标记，它们分别是// TODO: 和//FIXME:。”

 
 Tip 43　@UIApplicationMain
 
 Tip 44　@objc和dynamic
 添加@objc修饰符并不意味着这个方法或者属性会变成动态派发，Swift依然可能会将其优化为静态调用。如果你需要和Objective-C里动态调用时相同的运行时特性的话，你需要使用的修饰符是dynamic。”
 
 Tip 45　可选接口

 Tip 46　内存管理，weak和unowned
 
 Tip 47　@autoreleasepool
 for i in 1...10000 {
             autoreleasepool {
                 let data = NSData.dataWithContentsOfFile(
                     path, options: nil, error: nil)

                 NSThread.sleepForTimeInterval(0.5)
             }
         }”

 
 Tip 48　值类型和引用类型
 var a = [1,2,3]
 var b = a
 let c = b
 test(a)
 func test(arr: [Int]) {
     for i in arr {
         println(i)
     }
 }
 “这么折腾一圈下来，只在第一句a初始化赋值时发生了内存分配，而之后的b、c甚至传递到test方法内的arr，和最开始的a在物理内存上都是同一个东西。而且这个a还只在栈空间上，于是这个过程对于数组来说，只发生了指针移动，而完全没有堆内存的分配和释放的问题，这样的运行效率可以说极高。
 值类型被复制的时机是值类型的内容发生改变时，比如下面在b中又加入了一个数，此时值复制就是必须的了：
 var a = [1,2,3]
 var b = a
 b.append(5)
 // 此时 a 和 b 的内存地址不再相同”

 
 Tip 49　Foundation框架
 
 Tip 50　String还是NSString
 
 Tip 51　UnsafePointer
 
 Tip 52　C指针内存管理
 
 Tip 54　GCD和延时调用
 
 
 Tip 58　KVO
 
 
 “Tip 61　哈希”

 
 Tip 67　性能考虑”
 “相对于Objective-C，Swift最大的改变就在于方法调用上的优化。在Objective-C中，所有的对于NSObject的方法调用在编译时都会被转为objc_msgSend方法。这个方法运用Objective-C的运行时的特性，使用派发的方式在运行时对方法进行查找。因为Objective-C的类型并不是编译时确定的，我们在代码中所写的类型不过是向编译器的一种“建议”，对于任何方法，这种查找的代价基本都是相同的。”
 methodToCall = findMethodInClass(class, selector);”
 methodToCall(); // 调用

 “Swift因为使用了更安全和更严格的类型，如果我们在编写的代码中指明了某个实际的类型的话（注意，需要的是实际具体的类型，而不是像Any这样的抽象的接口），我们就可以向编译器保证在运行时该对象一定属于被声明的类型。这对编译器进行代码优化来说是非常有帮助的，因为有了更多更明确的类型信息，编译器就可以在类型中处理多态时建立虚函数表（vtable），这是一个带有索引的保存了方法所在位置的数组。在方法调用时，与原来动态派发和查找方法不同，现在只需要通过索引就可以直接拿到方法并进行调用了，这是实实在在的性能提升。这个过程大概相当于：”
 // Swift
 methodToCall = class.vtable[methodIndex]
 // 直接使用
 methodIndex 获取实现
 methodToCall(); // 调用”
 
 “更进一步，在确定的情况下，编译器对Swift的优化甚至可以做到将某些方法调用优化为inline的形式。比如在某个方法被final标记时，由于不存在被重写的可能，vtable中该方法的实现就完全固定了。对于这样的方法，编译器在合适的情况下可以在生成代码的阶段就将方法内容提取到调用的地方，从而完全避免调用。”
 
 
 Tip 72　delegate
 “要想在Swift中使用weak delegate，我们就需要将protocol限制在class内。一”
 
 
 Tip 75　Toll-Free Bridging和Unmanaged”
 
 
 */



//@objc protocol OptionalProtocol {
//    optional func optionalMethod()
//}

class Tips3: NSObject {

}
