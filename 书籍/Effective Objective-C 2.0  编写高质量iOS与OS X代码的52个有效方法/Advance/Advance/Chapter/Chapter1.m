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
 说明当前“栈帧”（stackframe）⾥分配了两块内存，每块内存的⼤⼩都能容下⼀枚指针（在
 32位架构的计算机上是4字节，64位计算机上是8字节）。这两块内存⾥的值都⼀ 样，就是NSString实例的内存地址。
 
 分 配 在 堆 中 的 内 存 必 须 直 接 管 理 ， ⽽ 分 配 在 栈 上 ⽤ 于 保 存 变 量 的 内 存 则 会 在 其 栈 帧 弹 出
 时 ⾃ 动 清 理 。
 O b j e c t i v e - C 将 堆 内 存 管 理 抽 象 出 来 了 。 不 需 要 ⽤ m a l l o c 及 f r e e 来 分 配 或 释 放 对 象 所 占
 内 存 。 O b j e c t i v e - C 运 ⾏ 期 环 境 把 这 部 分 ⼯ 作 抽 象 为 ⼀ 套 内 存 管 理 架 构 ， 名 叫 “ 引 ⽤ 计 数 ”
 */

- (void)Chapter1{
    NSString * str1  = @"the string";
    NSString * str2 = str1;
}



/*
 第 2 条 ： 在 类 的 头 ⽂ 件 中 尽 量 少 引 ⼊ 其 他 头 ⽂ 件
 @class Chapter1
 这 叫 做 “ 向 前 声 明 ” （ f o r w a r d d e c l a r i n g ） 该 类 。 现 在 E O C P e r s o n 的 头 ⽂ 件 变 成 了 这 样 ：
 ⾮ 确 有 必 要 ， 否 则 不 要 引 ⼈ 头 ⽂ 件 。
⼀ 般 来 说 ， 应 在 某 个 类 的 头 ⽂ 件 中 使 ⽤ 向 前 声
明 来 提 及 别 的 类 ， 并 在 实 现 ⽂ 件 中 引 ⼊ 那 些 类 的 头 ⽂ 件 。 这 样 做 可 以 尽 量 降 低 类 之 间
的 耦 合 （ c o u p l i n g ） 。
• 有 时 ⽆ 法 使 ⽤ 向 前 声 明 ， ⽐ 如 要 声 明 某 个 类 遵 循 ⼀ 项 协 议 。 这 种 情 况 下 ， 尽 量 把 “ 该
类 遵 循 某 协 议 ” 的 这 条 声 明 移 ⾄ “ c l a s s - c o n t i n u a t i o n 分 类 ” 中 。 如 果 不 ⾏ 的 话 ， 就 把
协 议 单 独 放 在 ⼀ 个 头 ⽂ 件 中 ， 然 后 将 其 引 ⼈ 。
 */


/*
 第 3 条 ： 多 ⽤ 字 ⾯ 量 语 法 ， 少 ⽤ 与 之 等 价 的 ⽅ 法
 */

/*
 第 5 条 ： ⽤ 枚 举 表 示 状 态 、 选 项 、 状 态 码
 枚 举 只 是 ⼀ 种 常 量 命 名 ⽅ 式 。 某 个 对 象 所 经 历 的 各 种 状 态 就 可 以 定 义 为 ⼀ 个 简 单 的 校 举
 集 （ e n u m e r a t i o n s e t ） 。 ⽐ 如 说 ， 可 以 ⽤ 下 列 枚 举 表 示 “ 套 接 字 连 接 ” （ s o c k e t c o n n e c t i o n ） 的 状 态 ：
 由 于 每 种 状 态 都 ⽤ ⼀ 个 便 于 理 解 的 值 来 表 示 ， 所 以 这 样 写 出 来 的 代 码 更 易 读 懂
 实 现 枚 举 所 ⽤ 的 数 据 类 型 取 决
 于 编 译 器 ， 不 过 其 ⼆ 进 制 位 （ b i t ） 的 个 数 必 须 能 完 全 表 示 下 枚 举 编 号 才 ⾏ 。 在 前 例 中 ， 由 于
 最 ⼤ 编 号 是 2 ， 所 以 使 ⽤ 1 个 字 节 ° 的 c h a r 类 型 即 可
 
 C + + 1 1 标 准 修 订 了 枚 举 的 某 些 特 性 。 其 中 ⼀ 项 改 动 是 ： 可 以 指 明 ⽤ 何 种 “ 底 层 数 据 类 型 ”
 （ u n d e r l y i n g t y p e ） 来 保 存 枚 举 类 型 的 变 量 。 这 样 做 的 好 处 是 ， 可 以 向 前 声 明 枚 举 变 量 了 。 若
 不 指 定 底 层 数 据 类 型 ， 则 ⽆ 法 向 前 声 明 枚 举 类 型 ， 因 为 编 译 器 不 清 楚 底 层 数 据 类 型 的 ⼤ ⼩ ，
 所 以 在 ⽤ 到 此 枚 举 类 型 时 ， 也 就 不 知 道 究 竟 该 给 变 量 分 配 多 少 空 间
 
 还 有 ⼀ 种 情 况 应 该 使 ⽤ 枚 举 类 型 ， 那 就 是 定 义 选 项 的 时 候 。 若 这 些 选 项 可 以 彼 此 组
 合 ， 则 更 应 如 此 。 只 要 枚 举 定 义 得 对 ， 各 选 项 之 间 就 可 通 过 “ 按 位 或 操 作 符 ” （ b i t w i s e O R
 o p e r a t o r ） 来 组 合 。 例 如 ， i O S U I 框 架 中 有 如 下 枚 举 类 型 ， ⽤ 来 表 示 某 个 视 图 应 该 如 何 在 ⽔ 平
 或 垂 直 ⽅ 向 上 调 整 ⼤ ⼩
 */
enum ESConnetctedState:NSInteger{
    ESConnetcted,
    ESConnetcting,
    ESConnetctedDisconnect,

};

/*
 按位或  iOS 所有系统 API 都这么用
 << 就是 左移运算符
 
 按位与 & → 判断是否拥有某一项
 if (type & ESAutoreaszingRight) {
     // 包含 Right
 }
 
 同时拥有 Right + Top
 enum ESAutoreaszing type = ESAutoreaszingRight | ESAutoreaszingTop;
 
 一个 int 变量就能存储 32 个开关状态
 速度极快（CPU 原生位运算）
 iOS 所有系统 API 都这么用
 */

enum ESAutoreaszing{
    ESAutoreaszingNone    = 0,       // 00000
    ESAutoreaszingMargin  = 1 << 0,  // 00001 = 1
    ESAutoreaszingRight   = 1 << 1,  // 00010 = 2
    ESAutoreaszingTop     = 1 << 2,  // 00100 = 4
    ESAutoreaszingHeight  = 1 << 3,  // 01000 = 8
    ESAutoreaszinBottom   = 1 << 4,  // 10000 = 16
};

@end
