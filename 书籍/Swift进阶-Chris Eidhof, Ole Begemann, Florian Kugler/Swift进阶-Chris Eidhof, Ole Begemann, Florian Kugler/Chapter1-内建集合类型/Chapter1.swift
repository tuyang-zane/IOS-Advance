//
//  Chapter1.swift
//  Swift进阶-Chris Eidhof, Ole Begemann, Florian Kugler
//
//  Created by tuyang on 2026/4/13.
//

import Cocoa

/*
 内建集合类型
 
 1、数组
 值语义——写时复制
 “Swift 标准库中的所有集合类型都使用了“写时复制”这一技术，它能够保证只在必要的时候对数据进行复制。在我们的例子中，直到 y.append 被调用的之前，x 和 y 都将共享内部的存储”
 
 数组和可选值
 Swift 数组提供了你能想到的所有常规操作方法，像是 isEmpty 或是 count。数组也允许直接使用特定的下标直接访问其中的元素，像是 fibs[3]。不过要牢记在使用下标获取元素之前，你需要确保索引值没有超出范围。比如获取索引值为 3 的元素，你需要保证数组中至少有 4 个元素。否则，你的程序将会崩溃
 
 数组变形:函数式编程
 map 和 flatMap — 如何对元素进行变换
 filter — 元素是否应该被包含在结果中
 reduce — 如何将元素合并到一个总和的值中
 sequence — 序列中下一个元素应该是什么？
 forEach — 对于一个元素，应该执行怎样的操作
 sort，lexicographicCompare 和 partition — 两个元素应该以怎样的顺序进行排列
 index，first 和 contains — 元素是否符合某个条件
 min 和 max — 两个元素中的最小/最大值是哪个
 elementsEqual 和 starts — 两个元素是否相等
 split — 这个元素是否是一个分割符
 prefix - 当判断为真的时候，将元素滤出到结果中。一旦不为真，就将剩余的抛弃。和 filter 类似，但是会提前退出。这个函数在处理无限序列或者是延迟计算 (lazily-computed) 的序列时会非常有用。
 drop - 当判断为真的时候，丢弃元素。一旦不为真，返回将其余的元素。和 prefix(while:) 类似，不过返回相反的集合。
 accumulate — 累加，和 reduce 类似，不过是将所有元素合并到一个数组中，并保留合并时每一步的值。
 all(matching:) 和 none(matching:) — 测试序列中是不是所有元素都满足某个标准，以及是不是没有任何元素满足某个标准。它们可以通过 contains 和它进行了精心对应的否定形式来构建。
 count(where:) — 计算满足条件的元素的个数，和 filter 相似，但是不会构建数组。
 indices(where:) — 返回一个包含满足某个标准的所有元素的索引的列表，和 index(where:) 类似，但是不会在遇到首个元素时就停止。

 
 Map：转换数组，map 用来变形，for 用来做事。
 首先，它很短。长度短一般意味着错误少，不过更重要的是，它比原来更清晰。所有无关的内容都被移除了，一旦你习惯了 map 满天飞的世界，你就会发现 map 就像是一个信号，一旦你看到它，就会知道即将有一个函数被作用在数组的每个元素上，并返回另一个数组，它将包含所有被转换后的结果。
 其次，squared 将由 map 的结果得到，我们不会再改变它的值，所以也就不再需要用 var 来进行声明了，我们可以将其声明为 let。另外，由于数组元素的类型可以从传递给 map 的函数中推断出来，我们也不再需要为 squared 显式地指明类型了。
 ① 阅读代码的人会被误导、map 会创建一个没用的数组全是void（浪费内存）、③ 不符合函数式编程规范、代码意图不清晰
 array.map { item in
    table.insert(item)
 }

 Filter:
 另一个常见操作是检查一个数组，然后将这个数组中符合一定条件的元素过滤出来并用它们创建一个新的数组。对数组进行循环并且根据条件过滤其中元素的模式可以用数组的 filter 方法表示：
 bigArray.filter { someCondition }.count > 0
 filter会创建一个全新的数组，并且会对数组中的每个元素都进行操作。然而在上面这段代码中，这显然是不必要的。上面的代码仅仅检查了是否有至少一个元素满足条件，在这个情景下，使用 contains(where:) 更为合适：
 bigArray.contains { someCondition }
 这种做法会比原来快得多，主要因为两个方面：它不会去为了计数而创建一整个全新的数组，并且一旦找到了第一个匹配的元素，它就将提前退出。一般来说，你只应该在需要所有结果时才去选择使用 filter。
 
 Reduce:
 map 和 filter 都作用在一个数组上，并产生另一个新的、经过修改的数组。不过有时候，你可能会想把所有元素合并为一个新的值。比如，要是我们想将元素的值全部加起来，可以这样写：
     另一个关于性能的小提示：reduce 相当灵活，所以在构建数组或者是执行其他操作时看到 reduce 的话不足为奇、比如，你可以只使用 reduce 就能实现 map 和 filter：
     当使用 inout 是，编译器不会每次都创建一个新的数组，这样一来，这个版本的 filter 时间复杂度再次回到了 O(n)。当 reduce(into:_:) 的调用被编译器内联时，生成的代码通常会和使用 for 循环所得到的代码是一致的。
 
 flatMap:
 有时候我们会想要对一个数组用一个函数进行 map，但是这个变形函数返回的是另一个数组，而不是单独的元素。如果我们有一系列的 Markdown 文件，并且想将这些文件中所有的链接都提取到一个单独的数组中的话，我们可以尝试使用 markdownFiles.map(extractLinks) 来构建。不过问题是这个方法返回的是一个包含了 URL 的数组的数组，这个数组中的每个元素都是一个文件中的 URL 的数组。为了得到一个包含所有 URL 的数组，你还要对这个由 map 取回的数组中的每一个数组用 joined 来进行展平 (flatten)，将它归并到一个单一数组.
 注：
 arr += 数组
 本质是创建临时数组 → 拷贝 → 拼接
 arr.append(contentsOf: 数组)
 是直接向原数组内存空间追加元素，不创建临时数组、不额外拷贝

 forEach：
 我们最后要讨论的操作是 forEach。它和 for 循环的作为非常类似：传入的函数对序列中的每个元素执行一次。和 map 不同，forEach 不返回任何值。技术上来说，我们可以不暇思索地将一个 for 循环替换为 forEach：
 如果你想要对集合中的每个元素都调用一个函数的话，使用 forEach 会比较合适。你只需要将函数或者方法直接通过参数的方式传递给 forEach 就行了，这可以改善代码的清晰度和准确性。不过，for 循环和 forEach 有些细微的不同，值得我们注意。比如，当一个 for 循环中有 return 语句时，将它重写为 forEach 会造成代码行为上的极大区别。
 
 
 数组类型：
 切片
 它将返回数组的一个切片 (slice)，其中包含了原数组中从第二个元素开始的所有部分。得到的结果的类型是 ArraySlice，而不是 Array。切片类型只是数组的一种表示方式，它背后的数据仍然是原来的数组，只不过是用切片的方式来进行表示。这意味着原来的数组并不需要被复制。ArraySlice 具有的方法和 Array 上定义的方法是一致的，因此你可以把它当做数组来进行处理。
 此材料受版权保护。
 桥接
 Swift 数组可以桥接到 Objective-C 中。实际上它们也能被用在 C 代码里，不过我们稍后才会涉及到这个问题。因为 NSArray 只能持有对象，所以对 Swift 数组进行桥接转换时，编译器和运行时会自动把不兼容的值 (比如 Swift 的枚举) 用一个不透明的 box 对象包装起来。不少值类型 (比如 Int，Bool 和 String，甚至 Dictionary 和 Set) 将被自动桥接到它们在 Objctive-C 中所对应的类型。
 */


class Chapter1: NSObject {
    
    //  值语义——写时复制
    class func Chapter1Arr() {
        let x = [0,1,2,3,4]
        var y = x
        y.append(5)
        print("Chapter1Arr======== \(x) \(y)")
    }
    
    //“就算你拥有的是一个不可变的 NSArry，但是它的引用特性并不能保证这个数组不会被改变：”
    class func ObjChapter1Arr() {
        let a = NSMutableArray(array: [1,2,3])
        let b:NSArray = a
        a.insert(4, at: 3)
        print("ObjChapter1Arr======== \(a) \(b)")
        
        // 手动复制
        let d = a.copy() as! NSArray
        a.insert(5, at: 4)
        print("ObjChapter1Arr======== \(a) \(d)")
    }
    
    class func MapArr() {
        var squared:[Int] = [];
        let fibs = [0,1,2,3,4]
        for fib in fibs {
            squared.append(fib)
        }
        print("MapArr======== \(squared)")
        
        let _squared = fibs.map{fib in fib * fib}
        print("MapArr======== \(_squared)")
        
        print("accumulate======== \(fibs.accumulate(0, +))")
    }
    
    class func FilterArr() {
        let numbers = [1,2,3,4,5,6,7,8,9,10]
        let result1 = numbers.filter{num in num % 2 == 0}
        print("FilterArr======== \(result1)")
        
        let result2 = (1..<10).map{$0 * $0}.filter{$0 % 2 == 0}
        print("FilterArr======== \(result2)")
    }
    
    class func ReduceArr() {
        let fibs = [0, 1, 1, 2, 3, 5]
        var total = 0
        for num in fibs {
            total = total + num
        }
        print("ReduceArr======== \(total)")
        print("ReduceArr======== \(fibs.reduce(0, +))")
    }
    
    class func FlatMapArr() {
        let suits = ["♠︎", "♥︎", "♣︎", "♦︎"]
        let ranks = ["J","Q","K","A"]
        let result = suits.flatMap { suit in
            ranks.map { rank in
                (suit, rank)
            }
        }
        print("FlatMapArr======== \(result)")
    }
    
    class func ForEachArr() {
        for element in [1,2,3] {
            print("ForEachArr======== \(element)")
        }
        [1,2,3].forEach{print("ForEachArr======== \($0)")}
    }
    
    class func SlinceArr() {
        let slince = [1,2,3,4,5,6,7,8,9,10][1...]
        let newArr = Array(slince)
        print("SlinceArr======== \(newArr)   \(type(of: slince))")
    }
    
}

extension Array{
    
    // “在实现中，它使用的是 append(contentsOf:) 而不是 append(_:)，这样它将能把结果数组进行展平：”
    func flatMap<T>(_ transform:(Element) -> [T]) -> [T] {
        var arr:[T] = []
        for x in self {
//            arr += transform(x)
            arr.append(contentsOf: transform(x))
        }
        return arr
    }
    
    // 时间复杂度n2
    func reduce<Result>(_ initialResult: Result,_ nextPartResult:(Result,Element) -> Result) -> Result {
        var runging:Result = initialResult
        for x in self {
            runging = nextPartResult(runging,x)
        }
        return runging
    }
    
    func map2<T>(_ transform:(Element) -> T) -> [T] {
        return self.reduce([], {$0 + [transform($1)]})
    }
    
    func filter2(_ isIncluded:(Element) -> Bool) -> [Element] {
//        return self.reduce([], {$0 + (isIncluded($1) == true ? [$1] : [])})
        return self.reduce([], {isIncluded($1) ? $0 + [$1] : $0})
    }

    func filter3(_ isIncluded:(Element) -> Bool) -> [Element] {
        return self.reduce(into: []) { result, Element in
            if isIncluded(Element) {
                result.append(Element)
            }
        }
    }

    func map<T>(_ transform:(Element) -> T) -> [T] {
        var arr:[T] = []
        for x in self {
            arr.append(transform(x))
        }
        return arr
    }
    
    func accumulate<Result>(_ initialResult: Result,
                            _ nextPartialResult: (Result, Element) -> Result) -> [Result]{
        var running = initialResult
        return self.map { Element in
            running = nextPartialResult(running, Element)
            return running
        }
    }
    
    func filter(_ isIncluded:(Element) -> Bool) -> [Element] {
        var arr:[Element] = []
        for x in self where isIncluded(x){
            arr.append(x)
        }
        return arr
    }
    
}

extension Array where Element:Equatable{
    func index(of element:Element) -> Int? {
        for idx in self.indices where self[idx] == element {
            return idx
        }
        return nil
    }
}



/*
 1.2、字典
 另一个关键的数据结构是 Dictionary。字典包含键以及它们所对应的值。在一个字典中，每个键都只能出现一次。通过键来获取值所花费的平均时间是常数量级的 (作
 为对比，在数组中搜寻一个特定元素所花的时间将与数组尺寸成正比)。和数组有所不同，字典是无序的，使用 for 循环来枚举字典中的键值对时，顺序是不确定的。
 我们使用下标的方式可以得到某个设置的值。字典查找将返回的是可选值，当特定键不存在时，下标查询返回 nil。这点和数组有所不同，在数组中，使用越界下标进行访问将会导致程序崩溃。
 
 可变性
 和数组一样，使用 let 定义的字典是不可变的：你不能向其中添加、删除或者修改条目。如果想要定义一个可变的字典，你需要使用 var 进行声明。想要将某个值从字典中移除，可以用下标将对应的值设为 nil，或者调用 removeValue(forKey:)。后一种方法除了删除这个键以外，还会将被删除的值返回 (如果待删除的键不存在，则返回 nil)。
 
 有用的字典方法
 merge(_:uniquingKeysWith:)，它接受两个参数，第一个是要进行合并的键值对，第二个是定义如何合并相同键的两个值的函数。我们使用了 { $1 } 来作为合并两个值的策略。也就是说，如果某个键同时存在于 settings 和 ovderSetting 中时，我们使用 ovderSetting 中的值。
 mapValues:“它已经有一个 map 函数来产生数组。不过我们有时候想要的是结果保持字典的结构，只对其中的值进行映射。mapValues 方法就是做这件事”
 
 Hashable 要求
 字典其实是哈希表。字典通过键的 hashValue 来为每个键指定一个位置，以及它所对应的存储。这也就是 Dictionary 要求它的 Key 类型需要遵守 Hashable 协议的原因。标准库中所有的基本数据类型都是遵守 Hashable 协议的，它们包括字符串，整数，浮点数以及布尔值。不带有关联值的枚举类型也会自动遵守 Hashable。
 
 1.3 Set
 标准库中第三种主要的集合类型是集合 Set (虽然听起来有些别扭)。集合是一组无序的元素，每个元素只会出现一次。你可以将集合想像为一个只存储了键而没有存储值的字典。和 Dictionary 一样，Set 也是通过哈希表实现的，并拥有类似的性能特性和要求。测试集合中是否包含某个元素是一个常数时间的操作，和字典中的键一样，集合中的元素也必须满足 Hashable。
 “和其他集合类型一样，集合也支持我们已经见过的那些基本操作：你可以用 for 循环进行迭代，对它进行 map 或 filter 操作，或者做其他各种事情。”
 
 集合代数
 补集、交集、并集
 
 索引集合和字符集合
 字典和集合在函数中也会是非常好用的数据结构。我们如果想要为 Sequence 写一个扩展，来获取序列中所有的唯一元素，我们只需要将这些元素放到一个 Set 里，然后返回这个集合的内容就行了。不过，因为 Set 并没有定义顺序，所以这么做是不稳定的，输入的元素的顺序在结果中可能会不一致。为了解决这个问题，我们可以创建一个扩展来解决这个问题，在扩展方法内部我们还是使用 Set 来验证唯一性：
 
 Range
*/

enum Setting {
   case text(String)
   case int(Int)
   case bool(Bool)
}

class Chapter1_2: NSObject {
    
    class func Set() {
        let naturals:Set = [1,2,3,2]
        print("Set=======  \(naturals)  \(naturals.contains(3))  \(naturals.contains(0))")
        
        var iPods: Set = ["iPod touch", "iPod nano", "iPod mini",
        "iPod shuffle", "iPod Classic"]
        let discontinuedIPods: Set = ["iPod mini", "iPod Classic",
        "iPod nano", "iPod shuffle"]
        
        // 补集
        let currentIPods = iPods.subtracting(discontinuedIPods)
        print("currentIPods=======  \(currentIPods)")
        
        // 交集
        let iPodsWithTouch = iPods.intersection(discontinuedIPods)
        print("iPodsWithTouch=======  \(iPodsWithTouch)")
        
        // 并集
        iPods.formUnion(discontinuedIPods)
        print("discontinued=======  \(iPods)")
        
        
        print("unique=======  \([1,2,3,12,1,3,4,5,6,4,6].unique())")
    }
    
    class func Dictionary() {
        let defaultSetting:[String:Setting] = [
            "Mode":.bool(false),
            "Name":.text("ty")
        ];
        print("Dictionary=======  \(defaultSetting["Name"])")
        var userSettings = defaultSetting
        userSettings["Name"] = .text("Jared's iPhone")
        userSettings["Do Not Disturb"] = .bool(true)
        userSettings.updateValue(.text("ty123"), forKey: "Name")
        print("Dictionary=======  \(userSettings)")
    }
    
    class func MergeDictionary() {
        var setting:[String:Setting] = [
            "Mode":.bool(false),
            "Name":.text("ty")
        ];
        let ovderSetting:[String:Setting] = [
            "Name":.text("Jared's iPhone")
        ];
        setting.merge(ovderSetting, uniquingKeysWith:{$1})
        print("MergeDictionary=======  \(setting)")
        
        
        let frequencies = "hello".frequencies // ["e": 1, "o": 1, "l": 2, "h": 1]
        print("MergeDictionary=======  \(frequencies.filter { $0.value > 1 })")
        
        //["Name": "Jared\'s iPhone", "Mode": "false"]
        let settingsAsStrings = setting.mapValues { setting in
            switch setting {
                case .text(let text): return text
                case .int(let number): return String(number)
                case .bool(let value): return String(value)
            }
        }
    }
    
}

extension Sequence where Element:Hashable{
    
    /*  我们还可以从一个 (Key,Value) 键值对的序列中构建新的字典。如果我们能能保证键是唯一的，那么就可以使用 Dictionary(uniqueKeysWithValues:)。不过，对于一个序列中某个键可能存在多次的情况，就和上面一样，我们需要提供一个函数来对相同键对应的两个值进行合并。比如，要计算序列中某个元素出现的次数，我们可以对每个元素进行映射，将它们和 1 对应起来，然后从得到的 (元素, 次数) 的键值对序列中创建字典。如果我们遇到相同键下的两个值 (也就是说，我们看到了同样地元素若干次)，我们只需要将次数用 + 累加起来就行了
     */
    var frequencies: [Element:Int] {
        let frequencyPairs = self.map{($0,1)}
        return Dictionary(frequencyPairs, uniquingKeysWith: +)
    }
    
    // Set 来验证唯一性
    func unique() -> [Element] {
        var seen:Set<Element> = []
        return filter{ element in
            if seen.contains(element){
                return false
            }else{
                seen.insert(element)
                return true
            }
        }
    }
    
}
