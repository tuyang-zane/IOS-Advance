//
//  Chapter2.m
//  Objective-C高级编程 iOS与OS X多线程和内存管理
//
//  Created by tuyang on 2026/4/13.
//

#import "Chapter2.h"

@implementation Chapter2


/*
 2.1 block
 B l o c k s 是 C 语 ⾔ 的 扩 充 功 能 。 可 以 ⽤ ⼀ 句 话 来 表 示 B l o c k s 的 扩 充 功 能 ： 带 有 ⾃ 动 变 量 （ 局 部 变 量 ） 的 匿 名 函 数 。
 顾 名 思 义 ， 所 谓 匿 名 函 数 就 是 不 带 有 名 称 的 函 数 。 C 语 ⾔ 的 标 准 不 允 许 存 在 这 样 的 函 数 。
 
 由 “ ^ ” 开 始 的 B l o c k 语 法 ⽣ 成 的 B l o c k 被 赋 值 给 变 量 b l k 中 。 因 为 与 通 常 的 变 量 相 同 ， 所 以
 当 然 也 可 以 由 B l o c k 类 型 变 量 向 B l o c k 类 型 变 量 赋 值 。
 */
int buttonCallBack(int event){
    printf("buttonID======%d  %d",buttonID,event);
    return 1;
}

- (void)Chapter2_1{
    // 这 样 ⼀ 来 ， 函 数 f u n c 的 地 址 就 能 赋 值 给 函 数 指 针 类 型 变 量 f u n c p t r 中 了 。
    int (*funcint) (int) = &buttonCallBack;
    int (^blk) (int) = ^ (int count) {return count + 1;};
}

@end
