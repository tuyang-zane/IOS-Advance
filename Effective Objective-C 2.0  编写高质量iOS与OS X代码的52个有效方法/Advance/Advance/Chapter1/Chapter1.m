//
//  Chapter1.m
//  Advance
//
//  Created by 小涂和小周的mac on 2026/4/9.
//

#import "Chapter1.h"

@implementation Chapter1

/*
 1.1 oc简介
 因 该 语 ⾔ 使 ⽤ “ 消 息 结 构 ” （ m e s s a g i n g s t r u c t u r e ） ⽽ ⾮ “ 函 数 调 ⽤ ” （ f u n c t i o n
 c a l l i n g ） 。 O b j e c t i v e - C 语 ⾔ 由 S m a l l t a l k ° 演 化 ⽽ 来 ， 后 者 是 消 息 型 语 ⾔ 的 ⿐ 祖
 
 关键区别：使用消息结构的语言，其运行时所执行的代码由运行时环境决定，而使用函数调用的语言，则由编译器决定，如果方法是多态，则按照虚方法表（virtual table）来查出到底应该执行哪个函数。oc的重要工作都是由运行期组件（runtime component）而非编译器来完成。runtime component本质上就是一种与开发者所编写代码相链接的动态库（dynamic library），只需要更新runtime component就可获得性能提升。
 
 NSString *,指向NSString的指针。所有oc的对象都要这样声明。因为对象所占内存总是分配在堆空间（heap space），绝不会分配在栈（stack）上。
 str2并不是拷贝该对象，只是这两个会同时指向此对象，只 有 ⼀ 个 N S S t r i n g 实 例 ， 然 ⽽ 有 两 个 变 量 指 向 此 实 例 。 两 个 变 量 都 是 N S S t r i n g * 型 ， 这
 说 明 当 前 “ 栈 帧 ” （ s t a c k f r a m e ） ⾥ 分 配 了 两 块 内 存 ， 每 块 内 存 的 ⼤ ⼩ 都 能 容 下 ⼀ 枚 指 针 （ 在
 3 2 位 架 构 的 计 算 机 上 是 4 字 节 ， 6 4 位 计 算 机 上 是 8 字 节 ） 。 这 两 块 内 存 ⾥ 的 值 都 ⼀ 样，就是NSString实例的内存地址。
 */

- (void)Chapter1{
    NSString * str1  = @"the string";
    NSString * str2 = str1;
}

@end
