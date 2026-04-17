//
//  Chapter4.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/17.
//

import Cocoa

/*
 结构体和类
 
 值类型
 “我们经常会处理一些需要有明确的生命周期的对象，我们会去初始化这样的对象，改变它，最后摧毁它。举个例子，一个文件句柄 (file handle) 就有着清晰的生命周期：我们会打开它，对其进行一些操作，然后在使用结束后我们需要把它关闭。如果我们想要打开两个拥有不同属性的文件句柄，我们就需要保证它们是独立的。想要比较两个文件句柄，我们可以检查它们是否指向着同样的内存地址。因为我们对地址进行比较，所以文件句柄最好是由引用类型来进行实现。这也正是 Foundation 框架中 FileHandle 类所做的事情。”
 “并不需要生命周期。比如一个 URL 在创建后就不会再被更改。更重要的是，它在被摧毁时并不需要进行额外的操作 (对比文件句柄，在摧毁时你需要将其关闭)。当我们比较两个 URL 变量时，我们并不关心它们是否指向内存中的同一地址，我们所比较的是它们是否指向同样的 URL。因为我们通过它们的属性来比较 URL，我们将其称为值。在 Objective-C 里，我们用 NSURL 来实现一个不可变的对象。不过在 Swift 中对应的 URL 却是一个结构体。”
 
 值语义 (value semantics) 引用语义 (reference semantics)
 “结构体只有一个持有者。比如，当我们将结构体变量传递给一个函数时，函数将接收到结构体的复制，它也只能改变它自己的这份复制。这叫做值语义 (value semantics)，有时候也被叫做复制语义。”
 “而对于对象来说，它们是通过传递引用来工作的，因此类对象会拥有很多持有者，这被叫做引用语义 (reference semantics)”
 
 可变性
 “在最近几年，操作可变状态的名声一直不好，其实这也名副其实。这是因为很多 bug 的主要诱因就是可变性，大部分专家都会推荐你尽可能地使用不可变的对象，以便写出安全可维护的代码。幸运的是，Swift 可以让我们在写出安全代码的同时，保留直观的可变代码的风格。”
 
 结构体
 “当你读到 let point = ... 这样的代码，并且你知道 point 是一个具有值语义的结构体变量时，你就知道它永远不会发生改变。这对读懂代码很有帮助。”
 “理解值类型的关键就是理解为什么这里会被调用。对结构体进行改变，在语义上来说，与重新为它进行赋值是相同的。即使在一个更大的结构体上只有某一个属性被改变了，也等同于整个结构体被用一个新的值进行了替代。在一个嵌套的结构体的最深层的某个改变，将会一路向上反映到最外层的实例上，并且一路上触发所有它遇到的 willSet 和 didSet。”
 “虽然语义上来说，我们将整个结构体替换为了新的结构体，但是一般来说这不会损失性能，编译器可以原地进行变更。由于这个结构体没有其他所有者，实际上我们没有必要进行复制。不过如果有多个持有者的话，重新赋值意味着发生复制。对于写时复制的结构体，工作方式又会略有不同 (我们稍后再说)”
 
 mutating
 “编译器会强制我们添加 mutating 关键字。只有使用了这个关键字，我们才能在方法内部对 self 的各部分进行改变。将方法标记为 mutating，意味着我们在这个方法内部改变了 self 的行为。现在它将表现得像是一个 var，而不再是 let：我们可以任意地改变可变属性。(不过要更精准说的话，它其实并不是一个 var，我们马上会进行说明)。”

 inout
 “想要理解 mutating 是如何工作的，我们需要来看看 inout 关键字。在次之前，我们先定义一个全局函数，来将一个矩形在两个轴方向上各移动 10 个点。我们不能简单地对 rectangle 参数调用 translate，因为所有的函数参数默认都是不可变的，它们都以复制的方式被传递进来。所以这里我们需要使用 translated(by:)，并将位移后的矩形作为新的值返回。调用者想要使用函数的结果对一个已有值进行变更的话，他们还需要手动重新赋值：”
 “在全局函数中，我们可以将一个或多个参数标记为 inout 来达到相同的效果。就和一个普通的参数一样，值被复制并作为参数被传到函数内。不过，我们可以改变这个复制 (就好像它是被 var 定义的一样)。然后当函数返回时，Swift 会将这个 (可能改变过的) 值进行复制并将其返回给调用者，同时将原来的值覆盖掉。”
 
 写时复制
 “我们这里有一个整数数组：
 var x = [1,2,3]
 如果我们创建了一个新的变量 y，并且把 x 赋值给它时，会发生复制，现在 x 和 y 含有的是独立的结构体：
 var y = x
 在内部，这些 Array 结构体含有指向某个内存的引用。这个内存就是数组中元素所存储的位置。两个数组的引用指向的是内存中同一个位置，这两个数组共享了它们的存储部分。不过，当我们改变 x 的时候，这个共享会被检测到，内存将会被复制。”“地改变两个变量。昂贵的元素复制操作只在必要的时候发生，也就是我们改变这两个变量的时候发生复制”

 实现写时复制
 “我们也可以通过 === 运算符来验证它们引用的是同一个对象”
 “我们可以先来逐字审视写时复制这个短语，并给出一个可用的实现：每次我们需要改变 _data 是，我们都先将其进行复制，然后对这个复制进行改变。这种方式不会很高效，因为我们将会进行非常多不必要的复制操作，不过它将会达成我们的目标，为 MyValue 赋予值语义。引用原来的 _data 的对象将不会被变更操作影响到。
 我们不再直接变更 _data，而是通过一个计算属性 _dataForWriting 来访问它。这个计算属性总是会复制 _data 并将该复制返回：”
 
 “写时复制 (高效方式)”
 “为了提供高效的写时复制特性，我们需要知道一个对象 (比如这里的 NSMutableData) 是否是唯一的。如果它是唯一引用，那么我们就可以直接原地修改对象。否则，我们需要在修改前创建对象的复制。在 Swift 中，我们可以使用 isKnownUniquelyReferenced 函数来检查某个引用只有一个持有者。如果你将一个 Swift 类的实例传递给这个函数，并且没有其他变量强引用这个对象的话，函数将返回 true。如果还有其他的强引用，则返回 false。不过，对于 Objective-C 的类，它会直接返回 false。所以，直接对 NSMutableData 使用这个函数的话没什么意义。我们可以创建一个简单的 Swift 类，来将任意的 Objective-C 对象 (或者其他任意值) 封装到 Swift 对象中：”
 “不单单是全局变量，对于结构体中的引用，这种方法也适用。有了这个方法，我们就可以重写 MyData，在发生改变前先检查对 _data 的引用是否是唯一的。我们还可以添加一个 print 语句，来在调试时快速查看创建复制的频度：”
 “当你定义你自己的结构体和类的时候，需要特别注意那些原本就可以复制和可变的行为。结构体应该是具有值语义的。当你在一个结构体中使用类时，我们需要保证它确实是不可变的。如果办不到这一点的话，我们就需要 (像上面那样的) 额外的步骤。或者就干脆使用一个类，这样我们的数据的使用者就不会期望它表现得像一个值。”
 
 “写时复制的陷阱”
 
 
 */

final class Empty{}

struct COWStruct {
    var ref:Empty = Empty()
    mutating func changing() -> String {
        if isKnownUniquelyReferenced($ref) {
            
        }
    }
}

extension Chapter4{
    func WriteInCopy4() -> Void {
        
    }
}

final class Box<A>{
    var unBox:A
    init(unBox: A) {
        self.unBox = unBox
    }
}

extension Chapter4{
    func WriteInCopy3() -> Void {
        var x = Box(unBox: NSMutableData())
        var y = x
        print("MutableArr============ \(isKnownUniquelyReferenced(&x))")
        
        var buffer = MyData()
        var _copy = buffer
        for byte in 0..<5 as CountableRange<UInt8> {
           buffer.append1(byte)
        }
    }
}

class Chapter4: NSObject {
    
    class func MutableArr() -> Void {
//        let mutableArr:NSMutableArray = [1,2,3]
//        for obj in mutableArr {
//            mutableArr.removeLastObject()
//            print("MutableArr============ \(obj)")
//        }
        
        let mutableArr:NSMutableArray = [1,2,3]
        let chatArr = mutableArr
        mutableArr.add(4)
        print("MutableArr============ \(chatArr)")
        
        let sca = BinaryScane(data: Data("hi".utf8))
        Chapter4.scaeResult(scane: sca)
   }
        

    
    class func scaeResult(scane:BinaryScane) {
        while let byte = scane.scaneByte() {
            print("scane============ \(byte)")
        }
        
        let p = Point(x: 0, y: 0)
//        p.x = 10
        
        var re = Rectangle(origin: Point.zero, size: .init(width: 320, height: 480))
        var screen = Rectangle(width: 320, height: 480) {
              didSet {
                  print("Screen changed: \(screen)")
              }
       }
       screen.origin.x = 0
        
        
        var scanes:[Rectangle] = []{
            didSet {
                print("scanes changed: \(screen)")
            }
        }
        scanes.append(screen)
        scanes[0].origin.x = 10
        
        
        var screen1 = Rectangle(width: 320, height: 480)
        screen1.translate(by: .zero)
        
        screen1 = Chapter4.translatedByTen(by: screen1)
        
        Chapter4.translatedByTen1(by: &screen1)
        
        
        // “我们不能对一个 let 定义的矩形调用 translateByTwentyTwenty。我们只能对可变值调用这个方法”
        let screen2 = Rectangle(width: 320, height: 480)
        // Chapter4.translatedByTen1(by: &screen2)
        
        
        var array = [Point(x: 0, y: 0), Point(x: 10, y: 10)]
//        array[0] += Point(x: 100, y: 100)
//        array // [(x: 100, y: 100), (x: 10, y: 10)]”
    }
    
    
    class func translatedByTen(by rectangle :Rectangle) -> Rectangle {
        return rectangle.translated(by: .init(x: 10, y: 10))
    }

//    “函数接受矩形 screen，在本地改变它的值，然后将新的值复制回去 (覆盖原来的 screen 的值)。这个行为和 mutating 方法如出一辙。实际上，mutating 标记的方法也就是结构体上的普通方法，只不过隐式的 self 被标记为了 inout 而已。”
    class func translatedByTen1(by rectangle :inout Rectangle){
        rectangle.translate(by: .init(x: 5, y: 5))
    }

    
    func WriteInCopy() -> Void {
        var input: [UInt8] = [0x0b,0xad,0xf0,0x0d]
        var other: [UInt8] = [0x0d]
        var d = Data(bytes: input)
        var e = d
        d.append(contentsOf: other)
        print("WriteInCopy============ \(d) \(e)")
        
        // “我们也可以通过 === 运算符来验证它们引用的是同一个对象”
        var f = NSMutableData(bytes: &input, length: input.count)
        var g = f
        f.append(&other, length: other.count)
        print("WriteInCopy============ \(f) \(g) \(f===g)")
        
        let theData = NSData(base64Encoded: "wAEP/w==")!
        let x = MyData(theData)
        let y = x
        x._data === y._data // true”
        print("WriteInCopy============  \(x._data === y._data)")

        x.append(0x55)
        print("WriteInCopy============  \(x)  \(y)")

    }

    func WriteInCopy2() -> Void {
        let theData = NSData(base64Encoded: "wAEP/w==")!
        var x = MyData(theData)
        let y = x
        x._data === y._data // true”
        print("WriteInCopy2============  \(x._data === y._data)")
        x.append1(0x55)
        x._data === y._data
        print("WriteInCopy2============  \(x)  \(y)  \(x._data === y._data)")
        
        // “每次我们调用 append 时，底层的 _data 对象都要被复制一次。因为 buffer 没有和其他的 MyData 实例共享存储，所以对它进行原地变更会高效得多 (同时也是安全的)。”
        var buffer = MyData(NSData())
        for byte in 0..<5 as CountableRange<UInt8> {
           buffer.append(byte)
        }
    }
}

struct MyData {
    fileprivate var _data:Box<NSMutableData>
    fileprivate var _dataForWriting: NSMutableData {
        mutating get{
            if !isKnownUniquelyReferenced(&_data) {
                print("makeing copy")
                _data = Box(unBox: _data.unBox.mutableCopy() as! NSMutableData)
            }
            return _data.unBox
        }
    }
    init() {
        _data = Box(unBox: NSMutableData())
    }
    // 非值语义 复制指针
    init(_ data: NSData) {
        // copy() 返回的是不可变的 NSData，不是 NSMutableData
        //想要可修改 → 必须用 mutableCopy()
        //想要不可修改 → 用 copy()
        self._data = Box(unBox: (data.mutableCopy() as!NSMutableData))
    }
}

extension MyData {
    
    mutating func append1(_ byte: UInt8) {
        var mutableByte = byte
        _dataForWriting.append(&mutableByte, length: 1)
    }

    func append(_ byte: UInt8) {
        var mutableByte = byte
        _data.unBox.append(&mutableByte, length: 1)
    }
}

struct Point {
    var x:Int
    var y:Int
}

extension Point{
    static let zero = Point.init(x: 0, y: 0)
    
    static func +(lhs:Point,rhs:Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

struct Size {
    var width:Int
    var height:Int
}

struct Rectangle {
    var origin:Point
    var size:Size
}

extension Rectangle{
    init(x:Int = 0,y:Int = 0,width:Int,height:Int) {
        origin = .init(x: x, y: y)
        size = .init(width: width, height: height)
    }
    
    mutating func translate(by offset :Point) {
        origin = origin + offset
    }
    
    func translated(by offset :Point) -> Rectangle {
        var copy = self
        copy.translate(by: offset)
        return copy
    }
}

class BinaryScane {
    var postion:Int
    let data:Data
    init(data: Data) {
        self.postion = 0
        self.data = data
    }
}

extension BinaryScane{
    func scaneByte() -> UInt8? {
        guard postion < data.count else {
            return nil
        }
        postion += 1
        return data[postion - 1]
    }
}
