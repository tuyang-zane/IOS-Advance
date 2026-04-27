//
//  Chapter4.swift
//  函数式Swift-Chris Eidhof; Florian Kugler; Wouter Swierstra; 陈聿菡; 杜欣; 王巍
//
//  Created by tuyang on 2026/4/24.
//

import Cocoa

/*
 迭代器和序列
 
*/
protocol IteratorProtocol1 {
    associatedtype Element
    mutating func next() -> Element?
}

struct ReverseIndexIterator:IteratorProtocol1 {
    var index:Int
    init<T>(arr:[T]) {
        self.index = arr.endIndex - 1
    }
    mutating func next() -> Int?{
        guard self.index >= 0 else { return nil }
        defer { self.index -= 1 }
        return self.index
   }
}

/*
 // 解析器
 “事实证明，直接操作字符串的性能其实会很差。所以在选择输入和剩余部分的类型时，我们会使用 String.CharacterView 而不是字符串。别小看这点微不足道的改动，它会使性能得到大幅提升：”
 
*/


//typealias Stream = String.CharacterView
//
//typealias Parser<Result> = (Stream) -> (Result,Stream)?

class Chapter4: NSObject {
    
    func main() -> Void {
        
        let one = character(matching: {$0 == "1"})
//        one.parse("123".characters)
        
        let letters = ["A", "B", "C"]
        var iterator = ReverseIndexIterator.init(arr: letters)
        while let i = iterator.next() {
             print("Element \(i) of the array is \(letters[i])")
        }
    }
    
    func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
        Parser<Character> { input in
            guard let char = input.first, condition(char) else { return nil }
            return (char, String(input.dropFirst()))
        }
    }

}

struct Parser<Result> {
    typealias Stream = String
    let parse: (Stream) -> (Result, Stream)? // 改名更清晰
}

extension Parser {
    func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
        Parser<Character> { input in
            guard let char = input.first, condition(char) else { return nil }
            return (char, String(input.dropFirst()))
        }
    }
}
