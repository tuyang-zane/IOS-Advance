//
//  Chapter3.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/16.
//

import Cocoa

/*
 可选值
 
 3.1 哨岗值
 这些函数都返回了一个“魔法”数来表示函数并没有返回真实的值。这样的值被称为“哨岗值。
 通过枚举解决魔法数的问题,“它的枚举中含有“关联值”的概念。也就是说，枚举可以在它们的值中包含另外的关联的值：”
 if let
 使用 if let 来进行可选绑定 (optional binding) 要比上面使用 switch 语句要稍好一些”
  
 while let
 “while let 语句和 if let 非常相似，它代表一个当条件返回 nil 时终止的循环。”

 guard let
 “当然，guard 并不局限于用在绑定上。guard 能够接受任何在普通的 if 语句中能接受的条件。比如上面的空数组的例子可以用 guard 重写为：”

 可选链
 ?
 ??
 
 可选值
 map
 flatMap
 
 
 “可选值判等”
 隐式转换
 
 
 Equatable 和 ==
 
 
 
*/

//enum Optional<Wrapped> {
//    case none
//    case some(Wrapped)
//}

class Chapter3: NSObject {

    class func OptionalEqual() -> Void {
        let regex = "Hello$"
        if regex.first == "^"{
            
        }
        // 我们其实并不需要将 "^" 声明为可选值”
        if regex.first == Optional("^"){// or: == .some("^")
            
        }
        
        var dictWithNil:[String:Int?] = [
            "one":1,
            "two":2,
            "none":nil
        ]
        dictWithNil["two"] = nil
        print("dictWithNil============ \(dictWithNil)")

        dictWithNil["two"] = Optional(nil)
        print("dictWithNil============ \(dictWithNil)")

        dictWithNil["two"] = .some(nil)
        print("dictWithNil============ \(dictWithNil)")

        dictWithNil["two"]? = nil
        print("dictWithNil============ \(dictWithNil)")

        dictWithNil["three"]? = nil
        print("dictWithNil============ \(dictWithNil)")

        dictWithNil.index(forKey: "three")
        print("dictWithNil============ \(dictWithNil)")
        
        
        let a:[Int?] = [1,2,nil]
        let b:[Int?] = [1,2,nil]

        print("a==b============ \(a == b)")

    }
    
    class func ChainFunc() -> Void {
        let str:String? = "Never say never"
        let upper:String
        if str != nil {
            //“这看起来有点出乎意料。我们不是刚才才说过可选链调用的结果是一个可选值么？为什么在第一个 uppercased() 后面不需要加上问号？这是因为可选链是一个“展平”操作。str?.uppercased() 返回了一个可选值，如果你再对它调用 ?.lowercased() 的话，逻辑上来说你将得到一个可选值的可选值。”
            upper = str?.uppercased().lowercased() ?? ""
        }
        
        20.half?.half?.half
        
        var optional:Person? = Person(name: "ty", age: 32)
        
        
//        “这种写法非常繁琐，也很丑陋。特别注意，在这种情况下你不能使用可选绑定。因为 Person 是一个结构体，它是一个值类型，绑定后的值只是原来的值的局部作用域的复制，对这个复制进行变更，并不会影响原来的值：”
        if optional != nil {
            optional!.age += 1
        }
        
        if var optional1 = optional {
            optional1.age += 1
        }
        
        optional?.age += 1
        print("ChainFunc============ \(optional?.age)")
        
        // “请注意 age = 10 和 age? = 10 的细微不同。前一种写法无条件地将一个新值赋给变量，而后一种写法只在 a 的值在赋值发生前不是 nil 的时候才生效。”
        var age:Int? = 32
        age? = 10
        
        var age1:Int? = nil
        age1 = 10
        print("age1============ \(age1)")
        
        let i:Int? = nil
        let j:Int? = nil
        let k:Int? = 45
        
        let m = i ?? j ?? k
        print("m============ \(type(of: m))")

        
        var substring:String? = "32"
        print("msubstring \(substring ??? "--")")
        
        
        let charas:[Character] = ["a","b","c"]

        let stringNumber = ["1","2","3","foo"]
        let x = stringNumber.first.map{Int($0)}
        let y = stringNumber.first.flatMap{Int($0)}

        print("stringNumber====== \(x)")

    }
    
    class func OptionFunc() -> Void {
        var array = ["one","two","three","four","4"]
        if let idx = array.index(of: "four") {
            array.remove(at: idx)
        }
        print("OptionFunc============ \(array)")
        
//        while let line = readLine() {
//            print("line \(line)")
//        }
        
        let maybeInts = array.map { Int($0) } // [Optional(1), Optional(2), nil]”
        print("maybeInts============ \(maybeInts)")
        
        // “如果你只想对非 nil 的值做 for 循环的话，可以使用 case 来进行模式匹配：”
        //“这里使用了 x? 这个模式，它只会匹配那些非 nil 的值。这个语法是 .Some(x) 的简写形式，所以该循环还可以被写为：”
        for case let i? in maybeInts {
            print("maybeInts============111 \(i)")
        }
        
        for case let .some(i) in maybeInts {
            print("maybeInts============222 \(i)")
        }

        for case nil in maybeInts {
            print("nilnil============")
        }

        let j = 5
        if case 0..<10 = j{
            print("范围内============")
        }
        
        let s = "Tylaor Swift"
        if case Pattern(s: "Swift") = s{
        }
    }
}
public func flatten<S:Sequence,T>(source:S) -> [T] where S.Element == T? {
    let filtered = source.lazy.filter{$0 != nil}
    return filtered.map{$0!}
}

extension Sequence{
    func flatMap<U>(transform:(Element) -> U?) -> [U] {
        return flatten(source: self.lazy.map(transform))
    }
}

extension Array{
    func reduce(_ nextPartialResult:(Element,Element) -> Element) -> Element? {
        guard let first = first else { return nil }
        return dropFirst().reduce(first, nextPartialResult)
    }
    
    func reduce_alt(_ nextPartialResult:(Element,Element) -> Element) -> Element? {
        return first.map {
            dropFirst().reduce($0, nextPartialResult)
        }
    }
}

extension Optional{
    func map<U>(_ transform:(Wrapped)->U) -> U? {
        if let value = self {
            return transform(value)
        }
        return nil
    }
}

extension Collection where Element : Equatable{
    func index(of elemetn:Element) -> Optional<Index> {
        var idx = self.startIndex
        while idx != endIndex {
            if self[idx] == elemetn{
                return .some(idx)
            }
            formIndex(after: &idx)
        }
        return .none
    }
}


class TextField {
    private(set) var text = ""
    var didchange:((String) -> ())?
    private func textDidChange(newText:String) {
        text = newText
        didchange?(newText)
    }
}

struct Person {
    var name:String
    var age:Int
}


infix operator ???
public func ???<T>(optional:T?,defaultValue:@autoclosure()->String)->String{
    switch optional {
        case let value?:return String(describing: value)
        case nil:return defaultValue()
    }
}


extension Int{
    var half: Int? {
        guard self < -1 || self > 1 else { return nil }
        return self / 2
    }
}

extension Pattern{
    static func ~=(pattern:Pattern,value:String) -> Bool {
        return !value.ranges(of: pattern.s).isEmpty
    }
}

struct Pattern {
    let s:String
    init(s: String) {
        self.s = s
    }
}
