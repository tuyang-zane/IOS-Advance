//
//  Chapter1-函数式思想.swift
//  函数式Swift-Chris Eidhof; Florian Kugler; Wouter Swierstra; 陈聿菡; 杜欣; 王巍
//
//  Created by 小涂和小周的mac on 2026/4/22.
//

import Cocoa

/*
 函数式思想
 函数在 Swift 中是⼀等值 (ĩrst-class-values)，换句话说，函数可以作为参数被传递到其它函
 数，也可以作为其它函数的返回值。如果你习惯了使⽤像是整型，布尔型或是结构体这样的简
 单类型来编程，那么这个理念可能看来⾮常奇怪。
 
 函数式编程的核⼼理念就是
 函数是值，它和结构体、整型或是布尔型没有什么区别 —— 对函数使⽤另外⼀套命名规则会
 违背这⼀理念。
 
 */

typealias Distance = Double

struct Ship {
    var postion:Postion
    var firingRange:Distance
    var unsafeRange:Distance
}

extension Ship{
    func canEngageShip(target:Ship,friendly:Ship) -> Bool {
//        let dx = target.postion.x - postion.x
//        let dy = target.postion.y - postion.y
//        let friendlyDx = friendly.postion.x - target.postion.x
//        let friendlyDy = friendly.postion.y - target.postion.y

        let targetDistance = target.postion.minus(postion).length
        let friendlyDistance = friendly.postion.minus(target.postion).length
        return targetDistance <= firingRange
        && targetDistance > unsafeRange
        && (friendlyDistance > unsafeRange)
    }
}

struct Postion {
    var x:Double
    var y:Double
}

extension Postion{
    func minus(_ p:Postion) -> Postion {
        return Postion(x: x - p.x, y: y - p.y)
    }
    
    var length: Double {
        return sqrt(x*x + y*y)
    }
    
    func inRange(range:Distance) -> Bool {
        return sqrt(x*x + y*y) <= range
    }
}

class Chapter1: NSObject {
    
    func circle(radius:Distance) -> Region {
        return {point in point.length < radius}
    }
    
    func circle2(radius: Distance, center: Postion) -> Region {
        return { point in point.minus(center).length <= radius }
    }
    
    func shift (region:@escaping Region, offset: Postion) -> Region {
        return { point in region(point.minus(offset)) }
    }
}


//从现在开始，Region 类型将指代把 Position 转化为 Bool 的函数。严格来说这不是必须的，但是它可以让我们更容易理解在接下来即将看到的⼀些类型。
typealias Region = (Postion) -> Bool



/*
 我们将会围绕⼀个已经存在且⾯向
 对象的 API，展⽰如何使⽤⾼阶函数将其以⼩巧且函数式的⽅式进⾏封装。
 */

typealias Filter = CIImage -> CIImage

//模糊
func blur(radius:Double) -> Filter {
    return { image in
        let parameters = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image
        ]
        
    }
}
