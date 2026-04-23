//
//  Chapter3.swift
//  函数式Swift-Chris Eidhof; Florian Kugler; Wouter Swierstra; 陈聿菡; 杜欣; 王巍
//
//  Created by tuyang on 2026/4/23.
//

import Cocoa

/*
 不可变性的价值
 
 值类型与引用类型
 在了解一款软件的时候，耦合度通常被用来描述代码各个独立部分之间彼此依赖的程度。耦合度是衡量软件构建好坏的重要因素之一。最坏的情况下，所有类和方法都错综复杂相互关联，共享大量可变变量，甚至连具体的实现细节都存在依赖关系。这样的代码难以维护和更新：你无法理解或修改一小段独立的代码片段，而是需要一直站在整体的角度来考虑整个系统。”
 总而言之，Swift 提供了几种专门控制程序中使用可变状态的语法特征。虽然完全避开可选状态几乎不可能，但是仍有很多程序过度且不必要地使用可变性。学会在可能的时候避免使用可变状态和对象，将有助于降低耦合度，从而改善你的代码结构。”

*/



/*
 枚举
 
 关联值(枚举支持）
 
 纯函数式数据结构
 
 二叉搜索树
 */

enum MayorResult {
    case success(String)
    case error(Error)
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum LookupError: Error {
    case capitalNotFound
    case populationNotFound
}

enum PopulationResult {
    case success(Int)
    case error(LookupError)
}

enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}

extension Encoding{
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ascii: return String.Encoding.ascii
        case .nextstep: return String.Encoding.nextstep
        case .japaneseEUC: return String.Encoding.japaneseEUC
        case .utf8: return String.Encoding.utf8
        }
    }
    
    init?(encoding: String.Encoding) {
        switch encoding {
        case String.Encoding.ascii: self = .ascii
        case String.Encoding.nextstep: self = .nextstep
        case String.Encoding.japaneseEUC: self = .japaneseEUC
        case String.Encoding.utf8: self = .utf8
        default: return nil
        }
    }
    
    var localizedName: String {
        return String.localizedName(of: nsStringEncoding)
    }
}
 
class Chapter3: NSObject {

    func main() -> Void {
        let exampleSuccess:PopulationResult = .success(100)
        do{
//            populationOfCapital(country: "asd")
        }catch{
            
        }
    }
    
//    func populationOfCapital(country: String) -> PopulationResult {
//        guard let capital = capitals[country] else {
//            return .error(.capitalNotFound)
//        }
//        guard let population = cities[capital] else {
//            return .error(.populationNotFound)
//        }
//        return .success(population)
//    }
    
//    func populationOfCapital(country: String) throws -> Int {
//        guard let capital = capitals[country] else {
//            throw LookupError.capitalNotFound
//        }
//        guard let population = cities[capital] else {
//            throw LookupError.populationNotFound
//        }
//        return population
//    }
}

