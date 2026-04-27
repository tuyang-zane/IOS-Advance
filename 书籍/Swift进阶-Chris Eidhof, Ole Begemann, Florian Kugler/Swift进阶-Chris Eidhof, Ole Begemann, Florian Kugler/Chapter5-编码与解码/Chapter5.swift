//
//  Chapter5.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by 小涂和小周的mac on 2026/4/19.
//

import Foundation

/*
 编码和解码
 “将程序内部的数据结构序列化为一些可交换的数据格式，以及反过来将通用的数据格式反序列化为内部使用的数据结构，这在编程中是一项非常常见的任务。Swift 将这些操作称为编码 (encoding) 和解码 (decoing)。Swift 4 的一个主要特性就是定义了一套标准的编码和解码数据的方法，所有的自定义类型都能选择使用这套方法。”
 
 Codable
 “Codable 系统 (以其基本“协议”命名，而这个协议其实是一个类型别名) 的设计主要围绕三个核心目标；”
 1、“普遍性 - 它对结构体，枚举和类都适用。”
 2、“类型安全 - 像是 JSON 这样的可交换格式通常都是弱类型，而你的代码应该要使用强类型数据。”
 3、“减少模板代码 - 在让自定义类型加入这套系统时，应该让开发者尽可能少地写重复的“适配代码”。编译器应该为你自动生成这些代码。”
 
 “某个类型通过声明自己遵守 Encodable 和/或 Decodable 协议来表明自己具备被序列化和/或反序列化的能力。这两个协议各自只有一个必须实现的方法 - Encodable 定义了 encode(to:) 用来对值自身进行编码，Decodable 指定了一个初始化方法，来从序列化的数据中创建实例：”
 
 Encoding
 “Swift 自带两个编码器，分别是 JSONEncoder 和 PropertyListEncoder，它们存在于 Foundation 中，而没有被定义在标准库里。对于满足 Codable 的类型，它们也将自动适配 Cocoa 的 NSKeyedArchiver。我们接下来会集中研究 JSONEncoder，因为 JSON 是最常见的格式。”
 
 Decoding
 “JSONEncoder 的解码器版本是 JSONDecoder。解码和编码遵循同样的模式：创建一个解码器，然后将 JSON 数据传递给它进行解码。JSONDecoder 解码器接受包含 UTF-8 编码的 JSON 文本的 Data 实例，不过和编码器一样，其他类型的解码器可能会有不同的接口：”
 */



///// 某个类型可以将自身编码为一种外部表示。
//public protocol Encodable {
///// 将值编码到给定的 encoder 中。
//public func encode(to encoder: Encoder) throws
//}
///// 某个类型可以从外部表示中解码得到自身。
//public protocol Decodable {
///// 通过从给定的 decoder 中解码来创建新的实例。
//public init(from decoder: Decoder) throws
//}


//“因为两个存储属性都已经是可编解码类型了，所以只要声明 Codable 就可以满足编译器的需要了。同样地，我们现在可以定义一个 Placemark 结构体了，由于 Coordinate 满足 Codable，它就也可以自动满足 Codable 了：”
struct Coordinate:Codable {
    var latitude:Double
    var longitude:Double
}


struct Placemark:Codable,Equatable {
    static func == (lhs: Placemark, rhs: Placemark) -> Bool {
        return (lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude && lhs.name == rhs.name)
    }
    var name:String
    var coordinate:Coordinate
    
    enum CodingKeys: CodingKey {
        case name
        case coordinate
    }
}


class Chapter5 {
    
//    “我们可以把一个 Placemark 数组编码为 JSON：”
//    “实际的编码步骤非常简单：创建并且配置编码器，然后将值传递给它进行编码。JSON 编码器通过 Data 实例的方式返回一个字节的集合，我们这里为了显示，将它转为了字符串。”
    func chapter5() -> Void {
        let places = [
            Placemark(name: "Berlin", coordinate: Coordinate(latitude: 52, longitude: 14)),
            Placemark(name: "Cape Tow", coordinate: Coordinate(latitude: -34, longitude: 18))
        ]
        
        do{
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(places)
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            print("chapter5==========  \(jsonString)")
            
            do{
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([Placemark].self, from: jsonData)
                print("chapter5==========  \(type(of: decoded))  \(decoded == places)")
            }catch{
                print(error.localizedDescription)
            }

        }catch{
            print(error.localizedDescription)
        }
    }
}


/*
 编码过程
 “现在先忽略 codingPath 和 userInfo，显然 Encoder 的核心功能就是提供一个编码容器。容器是编码器存储的一种沙盒表现形式。通过为每个要编码的值创建一个新的容器，编码器能够确保每个值都不会覆盖彼此的数据。”
 
 “容器有三种类型：
 键容器 (Keyed Container) 可以对键值对进行编码。将键容器想像为一个特殊的字典，到现在为止，这是最常见的容器。
 在基于键的编码容器中，键是强类型的，这为我们提供了类型安全和自动补全的特性。编码器最终会在写入目标格式 (比如 JSON) 时，将键转换为字符串 (或者数字)，不过这对开发者来说是隐藏的。自定义编码方式的最简单的办法就是更改你的类型所提供的键。我们马上会在下面看到一个例子。
 无键容器 (Unkeyed Container) 将对一系列值进行编码，而不需要对应的键，可以将它想像成被编码值的数组。因为没有对应的键来确定某个值，所以对于在容器中的值进行解码的时候，需要遵守和编码时同样的顺序。
 单值容器对一个单一值进行编码。你[…]”
 
 
 “/// 能将值编码为外部表示的原生格式的类型。
 public protocol Encoder {
 /// 编码过程中到当前点的编码键路径。
 var codingPath: [CodingKey] { get }
 /// 用户为编码设置的上下文信息。
 var userInfo: [CodingUserInfoKey : Any] { get }
 /// 返回一个合适用来存放以给定键类型为键的多个值的编码容器。
 func container<Key: CodingKey>(keyedBy type: Key.Type)
 -> KeyedEncodingContainer<Key>
 /// 返回一个合适用来存放多个无键值的编码容器。
 func unkeyedContainer() -> UnkeyedEncodingContainer
 /// 返回一个合适用来存放一个原始值的编码容器。
 func singleValueContainer() -> SingleValueEncodingContainer
 }”
 
 
 “要继续研究，我们就需要知道在我们为 Placemark 结构体添加 Codable 适配的时候，编译器为我们生成了什么代码。让我们一步步来。”

 Coding Keys
 “这个枚举包含的成员与结构体中的存储属性一一对应。枚举值即为键编码容器所使用的键。和字符串的键相比较，因为有编译器检查拼写错误，所以这些强类型的键要更加安全，也更加方便。不过，编码器最后为了存储需要，还是必须要能将这些键转为字符串或者整数值。CodingKey 协议会负责这个转换任务：”
 
 */

extension Chapter5{
}
