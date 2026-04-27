//
//  Chapter1.m
//  Objective-C高级编程 iOS与OS X多线程和内存管理
//
//  Created by tuyang on 2026/4/9.
//

#import "Chapter1.h"
#import "Test.h"

@implementation Chapter1
/*
 1.1
 在 O b j e c t i v e - C 中 采 ⽤ A u t o m a t i c R e f e r e n c e C o u n t i n g （ A R C ） 机 制 ， 让 编 译 器 来 进 ⾏ 内
 存 管 理 。 在 新 ⼀ 代 A p p l e L L V M 编 译 器 中 设 置 A R C 为 有 效 状 态 ， 就 ⽆ 需 再 次 键 ⼊ r e t a i n 或
 者 r e l e a s e 代 码 ， 这 在 降 低 程 序 崩 溃 、 内 存 泄 漏 等 ⻛ 险 的 同 时 ， 很 ⼤ 程 度 上 减 少 了 开 发 程 序
 的 ⼯ 作 量 。 编 译 器 完 全 清 楚 ⽬ 标 对 象 ， 并 能 ⽴ 刻 释 放 那 些 不 再 被 使 ⽤ 的 对 象 。 如 此 ⼀ 来 ， 应
 ⽤ 程 序 将 具 有 可 预 测 性 ， 且 能 流 畅 运 ⾏ ， 速 度 也 将 ⼤ 幅 提 升 。 ①
 “ 在 L L V M 编 译 器 中 设 置 A R C 为 有 效 状 态 ， 就 ⽆ 需 再 次 键 ⼊ r e t a i n 或 者 是 r e l e a s e 代 码 。 ”
 */


/*
 1、2
 • ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 所 持 有 。
 • ⾮ ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 也 能 持 有 。
 • 不 再 需 要 ⾃ ⼰ 持 有 的 对 象 时 释 放 。
 • ⾮ ⾃ ⼰ 持 有 的 对 象 ⽆ 法 释 放
 ****** ⽤ 计 数 式 内 存 管 理 的 思 考 ⽅ 式 仅 此 ⽽ 已 。 按 照 这 个 思 路 ， 完 全 不 必 考 虑 引 ⽤ 计 数 。
上 ⽂ 出 现 了 “ ⽣ 成 ” 、 “ 持 有 ” 、 “ 释 放 ” 三 个 词 。 ⽽ 在 O b j e c t i v e - C 内 存 管 理 中 还 要 加 上 “ 废 弃 ”
⼀ 词 ， 这 四 个 词 将 在 本 书 中 频 繁 出 现
 O b j e c t i v e - C 内 存 管 理 中 的 a l l o c / r e t a i n / r e l e a s e / d e a l l o c ⽅ 法 分 别 指 代 N S O b j e c t 类 的 a l l o c 类
 ⽅ 法 、 r e t a i n 实 例 ⽅ 法 、 r e l e a s e 实 例 ⽅ 法 和 d e a l l o c 实 例 ⽅ 法
 
 
 ****** copy:方法利 ⽤ 基 于 N S C o p y i n g ⽅ 法 约 定 ， 由 各 类 实 现 的 c o p y W i t h Z o n e ： ⽅ 法 ⽣ 成 并 持 有
 对 象 的 副 本 。
 mutablecopy： 与 c o p y ⽅ 法 类 似 ， m u t a b l e C o p y ⽅ 法 利 ⽤ 基 于 N S M u t a b l e C o p y i n g ⽅ 法 约 定 ， 由
各 类 实 现 的 m u t a b l e C o p y W i t h Z o n e ： ⽅ 法 ⽣ 成 并 持 有 对 象 的 副 本 。
 两 者 的 区 别 在 于 ， c o p y ⽅ 法
 ⽣ 成 不 可 变 更 的 对 象 ， ⽽ m u t a b l e C o p y ⽅ 法 ⽣ 成 可 变 更 的 对 象 。 这 类 似 于 N S A r r a y 类 对 象 与
 N S M u t a b l e A r r a y 类 对 象 的 差 异 。 ⽤ 这 些 ⽅ 法 ⽣ 成 的 对 象 ， 虽 然 是 对 象 的 副 本 ， 但 同 a l l o c 、 n e w
 ⽅ 法 ⼀ 样 ， 在 “ ⾃ ⼰ ⽣ 成 并 持 有 对 象 ” 这 点 上 没 有 改 变 。
 
 
 ****** 对 于 ⽤ a l l o c / n e w / c o p y / m u t a b l e C o p y ⽅ 法 ⽣ 成 并 持 有 的 对 象 ， 或 是 ⽤ r e t a i n ⽅ 法 持 有 的 对 象 ，
 由 于 持 有 者 是 ⾃ ⼰ ， 所 以 在 不 需 要 该 对 象 时 需 要 将 其 释 放 。 ⽽ 由 此 以 外 所 得 到 的 对 象 绝 对 不 能 释
 放 。 倘 若 在 应 ⽤ 程 序 中 释 放 了 ⾮ ⾃ ⼰ 所 持 有 的 对 象 就 会 造 成 崩 溃 。 例 如 ⾃ ⼰ ⽣ 成 并 持 有 对 象 后 ，
 在 释 放 完 不 再 需 要 的 对 象 之 后 再 次 释 放 。
 
 */
- (void)Chapter1_2{
    //⾃ ⼰ ⽣ 成 并 持 有 对 象
    id obj = [[NSObject alloc]init];
    // 等价于
    id obj1 = [NSObject new];

    // 取 得 ⾮ ⾃ ⼰ ⽣ 成 并 持 有 的 对 象, 取 得 的 对 象 存 在 ， 但 ⾃ ⼰ 不 持 有 对 像
    id arr = [NSMutableArray array];

    // ⾃ ⼰ 持 有 对 象
    [arr retain];
    
    id arr1 = [[NSMutableArray alloc]init];

    // 释 放 对 象
    [arr1 release];
    
    //  得 ⾮ ⾃ ⼰ ⽣ 成 并 持 有 的 对 象, ⼰ 持 有 对 象
    id obj2 = [self allocObject];

    // 取 得 ⾮ ⾃ ⼰ ⽣ 成 并 持 有 的 对 象, 取 得 的 对 象 存 在 ， 但 ⾃ ⼰ 不 持 有 对 像
    id obj3 = [self object];

    // ⾃ ⼰ 持 有 对 象
    [obj3 retain];
    
    // 自己生成、持有对象、释放对象
    id obj4 = [[NSObject alloc]init];
    [obj4 release];
    
    /*
     释放之后，再次释放，应用崩溃
     原因：再度废弃已经废弃的对象，访问已经废弃的对象崩溃
     */
    [obj4 release];

    // 释放了非自己持有的对象
    id obj5 = [self object];
    [obj5 release];

}

// 原 封 不 动 地 返 回 ⽤ a l l o c ⽅ 法 ⽣ 成 并 持 有 的 对 象 ， 就 能 让 调 ⽤ ⽅ 也 持 有 该 对 象 。
- (id)allocObject{
    id obj = [[NSObject alloc]init];
    return obj;
}


- (id)object{
    id obj = [[NSObject alloc]init];
    // 自己持有对象
    // 我 们 使 ⽤ 了 a u t o r e l e a s e ⽅ 法 。 ⽤ 该 ⽅ 法 ， 可 以 使 取 得 的 对 象 存 在 ， 但 ⾃ ⼰ 不 持 有 对 象 。  a u t o r e l e a s e 提 供 这 样 的 功 能 ， 使 对 象 在 超 出 指 定 的 ⽣ 存 范 围 时 能 够 ⾃ 动 并 正 确 地 释 放 。（注册到autoreleasepool，pool结束时release）
    [obj autorelease];
    return obj;
}


/*
 1.2.3 内存管理 ===== GNUstep源码
 通 过 a l l o c W i t h Z o n e ： 类 ⽅ 法 调 ⽤ N S A l l o c a t e O b j e c t 函 数 分 配 了 对 象 。 下 ⾯ 我 们 来 看 看
 N S A l l o c a t e O b j e c t 函 数 。
 N S A l l o c a t e O b j e c t 函 数 通 过 调 ⽤ N S Z o n e M a l l o c 函 数 来 分 配 存 放 对 象 所 需 的 内 存 空 间 ， 之 后
 将 该 内 存 空 间 置 0 ， 最 后 返 回 作 为 对 象 ⽽ 使 ⽤ 的 指 针 。
 
 （经典alloc）
 struct obj_layout {
 NSUInteger retained;
 };
 
 inline id
 NSAllocateObject (Class aClass, NSUInteger extraBytes, NSZone *zone )
 {
     int size = 计 算 容 纳 对 象 所 需 内 存 ⼤ ⼩ ；
     id new = NSZoneMalloc (zone, size);
     memset(new, 0, size);
     new = (id) & (( struct obj_layout *) new) [1];
 
     //(struct obj_layout *)new [0] → 引用计数本身
     //(struct obj_layout *)new [1] → 跳过引用计数，指向真正对象
     //&(...)取地址，拿到真正对象的起始位置。
     //(id)转成对象指针给你用。
 }
 
 区域（Zone）：
 N S D e f a u l t M a l l o c Z o n e 、 N S Z o n e M a l l o c 等 名 称 中 包 含 的 N S Z o n e 是 什 么 呢 ？ 它 是 为 防
 ⽌ 内 存 碎 ⽚ 化 ⽽ 引 ⼊ 的 结 构 。 对 内 存 分 配 的 区 域 本 身 进 ⾏ 多 重 化 管 理 ， 根 据 使 ⽤ 对 象 的 ⽬
 的 、 对 象 的 ⼤ ⼩ 分 配 内 存 ， 从 ⽽ 提 ⾼ 了 内 存 管 理 的 效 率 。
 但 是 ， 如 同 苹 果 官 ⽅ ⽂ 档 P r o g r a m m i n g W i t h A R C R e l e a s e N o t e s 中 所 说 ， 现 在 的 运 ⾏
 时 系 统 只 是 简 单 地 忽 略 了 区 域 的 概 念 。 运 ⾏ 时 系 统 中 的 内 存 管 理 本 身 已 极 具 效 率 ， 使 ⽤ 区 域
 来 管 理 内 存 反 ⽽ 会 引 起 内 存 使 ⽤ 效 率 低 下 以 及 源 代 码 复 杂 化 等 问 题。
 以下是去掉zone源码
 
 （现代alloc核心）
 struct obj_layout i{
   NSUInteger retained;
 };
 
 + (id) alloc {
    // 1. 计算总大小：引用计数头 + 对象本身大小
    int size = sizeof（struct obj_layout） + 对 象 ⼤ ⼩ ；
    // 2. 申请内存，并自动清零（比malloc干净）
    struct obj_layout *p = (struct obj_layout *) calloc (1, size) ;
    // 3. 指针+1，跳过头部，返回真正的对象
    return (id)(p+1) ;
 };
 
 retaincount:
 - (NUInteger) retainCount{
    // +1 代表对象自己默认占 1 次引用（alloc 出来就有 1）（alloc不会进入obj_layout， obj_layout里存的 retained = 额外引用次数）
    return NSExtraRefCount(self) + 1;
 }
 
 inline NSUInteger
 NSExtraRefCount (id anobject) {
      / 1、 把 anObject（也就是 self）强行看成 obj_layout 结构体指针
        2、 [-1] = 往前退 1 个结构体大小，也就是 退回到引用计数的位置
        3、 取出里面的 retained值
      /
      return ((struct obj_layout *) anobject) [-1].retained;
 }
 
 retain：
 - (id) retain{
     NSIncrementExtraRefCount (self );
     return self;
 }
 inline
 void NSIncrementExtraRefCount(id anObject) {
     // 检查是否溢出（防止无限加）
     if (((struct obj_layout *)anObject)[-1].retained == UINT_MAX - 1) {
          [NSException raise: NSInternalInconsistencyExceptionformat: @"NIncrementExtraRefCount ( ) asked to increment too far");
     }
     // 👑 核心代码：额外计数 +1！
     ((struct obj_layout *)anObject)[-1].retained++;
 }

 release:
 - (void)release {
     // 减1，如果返回YES = 额外计数已经是0
     if (NSDecrementExtraRefCountWasZero(self)) {
         [self dealloc]; // 销毁对象
     }
 }
 BOOL NSDecrementExtraRefCountWasZero(id anObject) {
     // 拿到额外引用计数
     struct obj_layout *header = (struct obj_layout *)anObject - 1;

     // 如果额外计数已经是0 → 返回YES
     if (header->retained == 0) {
         return YES;
     } else {
         // 否则 → 额外计数 -1
         header->retained--;
         return NO;
     }
 }
 
 deallloc:
 - (void)dealloc {
     NSDeallocateObject(self); // 销毁对象，释放内存
 }

 inline void
 NSDeallocateObject(id anObject) {
     // 👑 核心第一步：指针往回退1，找到真正的内存头
     struct obj_layout *o = &((struct obj_layout *)anObject)[-1];
     // 👑 核心第二步：释放整块内存
     free(o);
 }
 */

+ (id)alloc{
    return [self allocWithZone:NSDefaultMallocZone()];
}

+ (id)allocWithZone:(NSZone *)z{
    return NSAllocateObject(self, 0, z);
}

- (void)retainCount{
    id obj = [[NSObject alloc]init];
    NSLog(@"retaincount=======  %d",[obj retainCount]);
}

/*
 1.2.4 内存管理 ===== 苹果源码（lldb）
 -retain
 CFDoExternRefOperation
 CFBasicHashAddValue

 -release
 CFDoExternRefOperation
 CFBasicHashRemoveValue
 
 -retainCount
 CFDoExternRefOperation
 CFBasicHashGetCountOfKey
 
 int __CFDoExternRefOperation(uintptr_t op, id obj) {
     CFBasicHashRef table = 取得对象的散列表(obj);
     int count;
     switch (op) {
         case OPERATION_retainCount:
             count = CFBasicHashGetCountOfKey(table, obj);
             return count;
         case OPERATION_retain:
             CFBasicHashAddValue(table, obj);
             return obj;
         case OPERATION_release:
             count = CFBasicHashRemoveValue(table, obj);
             return 0 == count;
     }
 }
 
 G N U s t e p 将 引 ⽤ 计 数 保 存 在 对 象 占 ⽤ 内 存 块 头 部 的 变 量 中 ， ⽽ 苹 果 的 实 现 ， 则 是 保 存 在 引 ⽤
 计 数 表 的 记 录 中 。
 通 过 内 存 块 头 部 管 理 引 ⽤ 计 数 的 好 处 如 下 ：
 • 少 量 代 码 即 可 完 成 。
 • 能 够 统 ⼀ 管 理 引 ⽤ 计 数 ⽤ 内 存 块 与 对 象 ⽤ 内 存 块 。
 
 通 过 引 ⽤ 计 数 表 管 理 引 ⽤ 计 数 的 好 处 如 下 ：
 • 对 象 ⽤ 内 存 块 的 分 配 ⽆ 需 考 虑 内 存 块 头 部 。
 • 引 ⽤ 计 数 表 各 记 录 中 存 有 内 存 块 地 址 ， 可 从 各 个 记 录 追 溯 到 各 对 象 的 内 存 块 。
  */


/*
 1.2.5 autorelease
 顾 名 思 义 ， a u t o r e l e a s e 就 是 ⾃ 动 释 放 。 这 看 上 去 很 像 A R C ， 但 实 际 上 它 更 类 似 于 C 语 ⾔ 中
 ⾃ 动 变 量 ① （ 局 部 变 量 ） 的 特 性 。
 我 们 来 复 习 ⼀ 下 C 语 ⾔ 的 ⾃ 动 变 量 。 程 序 执 ⾏ 时 ， 若 某 ⾃ 动 变 量 超 出 其 作 ⽤ 域 ， 该 ⾃ 动 变
 量 将 被 ⾃ 动 废 弃 。
 {
   int a;
 }
 // 因为超出其作用域，自动变量a，被废弃不可再访问
 
 另 外 ， 同 C 语 ⾔ 的 ⾃ 动 变 量 不 同 的 是 ， 编 程 ⼈ 员 可 以 设 定 变 量 的 作 ⽤ 域 。
 a u t o r e l e a s e 的 具 体 使 ⽤ ⽅ 法 如 下 ：
 （ 1 ） ⽣ 成 并 持 有 N S A u t o r e l e a s e P o o l 对 象 ；
 （ 2 ） 调 ⽤ 已 分 配 对 象 的 a u t o r e l e a s e 实 例 ⽅ 法 ；
 （ 3 ） 废 弃 N S A u t o r e l e a s e P o o l 对 象 。
 
 在 C o c o a 框 架 中 ， 相 当 于 程 序 主 循 环 的 N S R u n L o o p 或 者 在 其 他 程 序 可 运 ⾏ 的 地 ⽅ ， 对
 N S A u t o r e l e a s e P o o l 对 象 进 ⾏ ⽣ 成 、 持 有 和 废 弃 处 理 。 因 此 ， 应 ⽤ 程 序 开 发 者 不 ⼀ 定 ⾮ 得 使 ⽤
 N S A u t o r e l e a s e P o o l 对 象 来 进 ⾏ 开 发 ⼯ 作 。
 (N S R u n L o o p 每 次 循 环 过 程 中 N S A u t o r e l e a s e P o o l 对 象 被 ⽣ 成 或 废 弃)
 尽 管 如 此 ， 但 在 ⼤ 量 产 ⽣ a u t o r e l e a s e 的 对 象 时 ， 只 要 不 废 弃 N S A u t o r e l e a s e P o o l 对 象 ， 那 么
 ⽣ 成 的 对 象 就 不 能 被 释 放 ， 因 此 有 时 会 产 ⽣ 内 存 不 ⾜ 的 现 象 。 典 型 的 例 ⼦ 是 读 ⼊ ⼤ 量 图 像 的 同 时
 改 变 其 尺 ⼨ 。 图 像 ⽂ 件 读 ⼊ 到 N S D a t a 对 象 ， 并 从 中 ⽣ 成 U I l m a g e 对 象 ， 改 变 该 对 象 尺 ⼨ 后 ⽣ 成
 新 的 U l I m a g e 对 象 。 这 种 情 况 下 ， 就 会 ⼤ 量 产 ⽣ a u t o r e l e a s e 的 对 象 。
 
 另 外 ， C o c o a 框 架 中 也 有 很 多 类 ⽅ 法 ⽤ 于 返 回 a u t o r e l e a s e 的 对 象 。 ⽐ 如 N S M u t a b l e A r r a y 类
 的 a r r a y W i t h C a p a c i t y 类 ⽅ 法 。
 */

- (void)realsePool{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    id obj = [[NSObject alloc]init];
    [obj autorelease];
    [pool drain]; // obj自动调用release == [obj release];
}

- (void)moreImgesPool{
    for (int i = 0; i < 10000000000; i ++) {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];

        /*
         读 ⼊ 图 像
         ⼤ 量 产 ⽣ a u t o r e l e a s e 的 对 象 。
         由 于 没 有 废 弃 N S A u t o r e l e a s e P o o l 对 象
         * 最 终 导 致 内 存 不 ⾜ ！
         */
        
        [pool drain];
        // a u t o r e l e a s e 的 对 象 被 r e l e a s e
    }
}

- (void)cocoaPool{
    // 等同
    id array = [NSMutableArray arrayWithCapacity:1];
    
    id array1 = [[NSMutableArray arrayWithCapacity:1] autorelease];
}


/*
 1.2.5 autorelease实现
 G N U s t e p 中 的 a u t o r e l e a s e 实 际 上 是 ⽤ ⼀ 种 特 殊 的 ⽅ 法 来 实 现 的 。 这 种 ⽅ 法 能 够 ⾼ 效
 地 运 ⾏ O S X 、 i O S ⽤ 应 ⽤ 程 序 中 频 繁 调 ⽤ 的 a u t o r e l e a s e ⽅ 法 ， 它 被 称 为 “ I M P C a c h i n g " 。
 在 进 ⾏ ⽅ 法 调 ⽤ 时 ， 为 了 解 决 类 名 / ⽅ 法 名 以 及 取 得 ⽅ 法 运 ⾏ 时 的 函 数 指 针 ， 要 在 框 架 初 始
 化 时 对 其 结 果 值 进 ⾏ 缓 存 。
 
 // 1. 拿到 autoreleasepool 类
 id autorelease_class = [NSAutoreleasePool class];
 // 2. 拿到 addObject: 方法名
 SEL autorelease_sel = @selector(addobject:) ;
 // 3. 直接拿到方法的函数指针（最关键！）
 IMP autorelease_imp = [autorelease_class methodForSelector: autorelease_sel];
 
 // 实际方法调用就是调用缓存中的结果值
 - (id) autorelease{
    // 直接调用函数指针！
    (*autorelease_imp) (autorelease_class, autorelease_sel, self) :
 }
 
 
 + (void)addObject:(id )anobj{
     NSAutoreleasePool * pool = 取 得 正 在 使 ⽤ 的 N S A u t o r e l e a s e P o o 1 对 象 ；;
     if (pool != nil) {
         [pool addobject:an0bj]:
     }
     else {
         N S L o g （ e " N S A u t o r e l e a s e P o o l 对 象 ⾮ 存 在 状 态 下 调 ⽤ a u t o r e l e a s e " ） ；
     }
 }
 */

+ (void)autorelease{
    /*
     底层要做 3 件事：
     找 类
     找 方法名 @selector
     找 方法对应的函数指针（IMP）
     autorelease 被调用几百万次 → 每次都找 → 太慢！
     */
    [NSAutoreleasePool addObject:self];
}

/*
 1.2.7 苹果的实现
 class AutoreleasePoolPage
 {
     // 相当于 生成或持有 NSAutoreleasePool 类对象
     static inline void *push ( ){
     }
     // 相当于 废弃 NSAutoreleasePool 类对象
     static inline void *pop (void *token){
     }
     static inline id autorelease (id obj )
     {
         // 相当于NSAutoreleasePoo1类的addObject类⽅法
         AutoreleasePoolPage *autoreleasePoolPage = 取得正在使用的 AutoreleasePoolPage 实例；
         autoreleasePoolPage->add ( obj ) ;
     }
     id * add (id obj){
        // 将对象追加到内部数组中
     }
     void releaseAll(){
        // 调用内部数组中对象的 release 实例方法
     }
 };
 
 // 对外接口：开启自动释放池（对应 push）
 void *objc_autoreleasePoolPush ( void)
 {
     return AutoreleasePoolPage::push ( );
 }
 // 对外接口：销毁自动释放池（对应 pop）
 void objc_autoreleasePoolPop (void *ctxt )
 {
     AutoreleasePoolPage::pop ( ctxt ) ;
 }
 // 对外接口：对象加入自动释放池（对应 autorelease）
 id *objc_autorelease ( id obj )
 {
     return AutoreleasePoolPage::autorelease ( obj);
 }
 
 通 过 N S A u t o r e l e a s e P o o l 类 中 的 调 试 ⽤ ⾮ 公 开 类 ⽅ 法 s h o w P o o l s 来 确 认 已 被 a u t o r e l e a s e
 的 对 象 的 状 况 。 s h o w P o o l s 会 将 现 在 的 N S A u t o r e l e a s e P o o l 的 状 况 输 出 到 控 制 台 。
  */

+ (void)appleAutorelease{
    // 等同于objc_autoreleasePoolPush()
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];

    id obj = [[NSObject alloc]init];
    
    // 等同于objc_autorelease()
    [obj autorelease];
    
    // 等同于objc_autoreleasePoolPop()
    [pool drain];
    
    // 只能在ios上使用，该 函 数 在 检 查 某 对 象 是 否 被 ⾃ 动 r e l e a s e 时 ⾮ 常 有 ⽤ 。
    [NSAutoreleasePool showPools];
}

/*
 1.3 ARC规则
 __strong修饰:是id类型和对象类型默认的所有权修饰符。
     相同
     id obj = [[NSObject alloc]init];
     id __strong obj = [[NSObject alloc]init];

     ARC无效时,等同于上面，持有强引用的变量在超出去作用域时被废弃，随着强引用失效，引用的对象会随之释放
     {
        id obj = [[NSObject alloc]init];
        [obj release];
     }
 
     正 如 苹 果 宣 称 的 那 样 ， 通 过 _ s t r o n g 修 饰 符 ， 不 必 再 次 键 ⼊ r e t a i n 或 者 r e l e a s e ， 完 美 地 满 ⾜
     了 “ 引 ⽤ 计 数 式 内 存 管 理 的 思 考 ⽅ 式 ” ：
     • ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 所 持 有 。
     • ⾮ ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 也 能 持 有 。
     • 不 再 需 要 ⾃ ⼰ 持 有 的 对 象 时 释 放 。
     • ⾮ ⾃ ⼰ 持 有 的 对 象 ⽆ 法 释 放 。
     前 两 项 “ ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 持 有 ” 和 “ ⾮ ⾃ ⼰ ⽣ 成 的 对 象 ， ⾃ ⼰ 也 能 持 有 ” 只 需 通 过 对
     带_ s t r o n g 修 饰 符 的 变 量 赋 值 便 可 达 成 。 通 过 废 弃 带 _ _ s t r o n g 修 饰 符 的 变 量 （ 变 量 作 ⽤ 域 结 束 或
     是 成 员 变 量 所 属 对 象 废 弃 ） 或 者 对 变 量 赋 值 ， 都 可 以 做 到 “ 不 再 需 要 ⾃ ⼰ 持 有 的 对 象 时 释 放 ” 。
     最 后 ⼀ 项 “ ⾮ ⾃ ⼰ 持 有 的 对 象 ⽆ 法 释 放 ” ， 由 于 不 必 再 次 键 ⼊ r e l e a s e ， 所 以 原 本 就 不 会 执 ⾏ 。 这
     些 都 满 ⾜ 于 引 ⽤ 计 数 式 内 存 管 理 的 思 考 ⽅ 式 。
 */
+ (void)strong{
    
    {
        // 自己生成并持有对象
        id obj = [[NSObject alloc]init];
        id __strong obj1 = [[NSObject alloc]init];
    }
    // ocj超出作用域，引用失效，引用的对象会随之释放

    
    {
        // 取得非自己持有的对象
        id __strong obj = [NSMutableArray array];
    }
    // ocj超出作用域，引用失效，引用的对象会随之释放
    
    
    // 附有 __strong修饰符的变量之间可以相互赋值
    {
        // 对象A，obj0持有对象A的强引用
        id __strong obj0 = [[NSObject alloc]init];
        // 对象A，obj1持有对象B的强引用
        id __strong obj1 = [[NSObject alloc]init];
        // obj2不持有任何对象
        id __strong obj2 = nil;
        /*
         o b j 0 持 有 由 o b j 1 賦 值 的 对 象 B 的 强 引 ⽤
         因 为 o b j 0 被 赋 值 ， 所 以 原 先 持 有 的 对 对 象 A 的 强 引 ⽤ 失 效 。
         * 对 象 A 的 所 有 者 不 存 在 ， 因 此 废 弃 对 象 A 。
         *
         * 此 时 ， 持 有 对 象 B 的 强 引 ⽤ 的 变 量 为
         * o b j 0 和 o b j 1 o
         */
        obj0 = obj1;
        // obj2、obj1、obj0都持有对象B
        obj2 = obj0;
        // obj2、obj1都持有对象B
        obj0 = nil;
        // obj2都持有对象B
        obj1 = nil;
        // 对象B的强引用失效，对象B的所有者不存在。因 此 废 弃 对 象 B
        obj2 = nil;
    }
    
    {
        // test 持有Test对象的强引用
        id __strong test = [[Test alloc]init];
        // Test 对象的 _obj成员持有 NSObject 对象的强引用
        [test setObjetc:[[NSObject alloc]init]];
    }
    // 因为test超出作用域，强引用失效，所以自动释放Test对象，Test对象的所有者不存在，因此废弃该对象
    // 废弃Test对象的同时，_obj成员也被废弃，NSObject对象的所有者不存在，因此也被废弃
}

/*
 __weak修饰符：看 起 来 好 像 通 过
 _ s t r o n g 修 饰 符 编 译 器 就 能 够 完 美 地 进 ⾏ 内 存 管 理 。 但 是 遗 憾 的 是 ， 仅 通 过
 s t r o n g 修 饰 符 是 不 能 解 决 有 些 重 ⼤ 问 题 的 。
 这 ⾥ 提 到 的 重 ⼤ 问 题 就 是 引 ⽤ 计 数 式 内 存 管 理 中 必 然 会 发 ⽣ 的 “ 循 环 引 ⽤ ” 的 问
 */
+ (void)weak{
    // 循环引用
    {
        // test0持有 对象TestA的强引用
        id test0 = [[Test alloc] init];
        // test1持有 对象TestB的强引用
        id test1 = [[Test alloc] init];
        // 对象TestA的_obj 持有 test1的强引用
        [test0 setObjetc:test1];
        // 对象TestB的_obj 持有 test0的强引用
        [test1 setObjetc:test0];
        
        // 此时对象TestA的强引用变量为test0和对象TestB的_obj
        // TestB的强引用变量为test1和对象TestA的_obj
    }
    // 因为test0变量超出作用域，释放test0持有的TestA的引用
    
    // 因为test1变量超出作用域，释放test1持有的TestB的引用
    
    // 此时持有TestA的强引用为TestB的_obj
    // 此时持有TestB的强引用为TestA的_obj
    // 发生内存泄漏
    
    {
        // 生成并对对象弱引用
        id __weak obj0 = [[NSObject alloc]init];

        // 自己生成并持有对象
        id __strong obj1 = [[NSObject alloc]init];
        // obj2持有生成对象的弱引用
        id __weak obj2 = obj1;
    }
    // 超出域自动释放
}

/*
 __unsafe_unretained: 修 饰 符 正 如 其 名 u n s a f e 所 ⽰ ， 是 不 安 全 的 所 有 权 修 饰 符 。 尽 管 A R C 式
 的 内 存 管 理 是 编 译 器 的 ⼯ 作 ， 但 附 有 _ _ u n s a f e _ u n r e t a i n e d 修 饰 符 的 变 量 不 属 于 编 译 器 的 内 存 管 理
 对 象 。 这 ⼀ 点 在 使 ⽤ 时 要 注 意
 */
+ (void)unsafeunretained{
    // 和__weak一样，因为自己生成持有的对象不能为自己所有，立即释放
    id __unsafe_unretained obj = [[NSObject alloc]init];
    
    id __unsafe_unretained obj1 = nil;
    {
        id __strong obj0 = [[NSObject alloc]init];
        obj1 = obj0; // 不持有强引用，也不持有弱引用
        NSLog(@"A: %@",obj1);
    }
    // 对象无持有者，所以废弃该对象，碰巧正常运行而已
    NSLog(@"B: %@",obj1);  // 👈 野指针！悬垂指针！
    /*
     不是正常，是运气好！
     内存还没被覆盖
     内存数据还残留
     系统还没复用这块内存
     一旦内存被覆盖 → 直接崩溃（坏内存访问、EXC_BAD_ACCESS）
     */
}

/*
 __autoreleasing
 另 外 ， 根 据 后 ⾯ 要 讲 到 的 遵 守 内 存 管 理 ⽅ 法 命 名 规 则 （ 参 考 1 . 3 . 4 节 ） ， i n i t ⽅ 法 返 回 值 的 对
 象 不 注 册 到 a u t o r e l e a s e p o o l
 
 那 么 i d 的 指 针 i d * o b j
 推 出 来 的 是 i d _ a u t o r e l e a s i n g * o b j 。 同 样 地 ， 对 象 的 指 针 N S O b j e c t * * o b j 便 成 为
T NSObject * autoreleasing *obj.
 
 只 有
作 为 a l l o c / n e w / c o p y / m u t a b l e C o p y ⽅ 法 的 返 回 值 ⽽ 取 得 对 象 时 ， 能 够 ⾃ ⼰ ⽣ 成 并 持 有 对 象 。 其 他
情 况 即 “ 取 得 ⾮ ⾃ ⼰ ⽣ 成 并 持 有 的 对 象
 
显 式 地 指 定 _ _ a u t o r e l e a s i n g 修 饰
符 时 ， 必 须 注 意 对 象 变 量 要 为 ⾃ 动 变 量 （ 包 括 局 部 变 量 、 函 数 以 及 ⽅ 法 参 数
 */


+ (void)autoreleasing{
    // ARC 无效时会像下面这样使用
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    id obj = [[NSObject alloc]init];
    [obj autorelease];
    [pool drain];
    
    /*
     ARC 有效时
     @autoreleasepool 来替代 NSAutoreleasePool对象生成
     __autoreleasing 来替换 [obj autorelease]方法，即对象注册到autoreleasePool
     但是显示的添加__autoreleasing和显示添加__strong一样，
     这 是 由 于 编 译 器 会 检 查 ⽅ 法 名 是 否 以 a l l o c / n e w /
    c o p y / m u t a b l e C o p y 开 始 ， 如 果 不 是 则 ⾃ 动 将 返 回 值 的 对 象 注 册 到 a u t o r e l e a s e p o o l
     */
    @autoreleasepool {
        id __autoreleasing obj = [[NSObject alloc]init];
    }
    
    @autoreleasepool {
        // 取得非自己生成并持有对象
        id __strong obj = [NSMutableArray array];
        // 因obj是强引用，所以自己持有对象，并且该对象由编译器判断方法名自动注册到autoreleasePool
    }
    // 超出作用域，自动释放自己持有的对象。同时随着@autoreleasepool块结束注册到pool的所有对象被自动释放

    //在 访 问 附 有 _ w e a k 修 饰 符 的 变 量 时 ， 实 际 上 必 定 要 访 问 注 册 到 a u t o r e l e a s e p o o l 的 对 象 。
    {
        id  obj0 = [[NSObject alloc]init];
        id __weak obj1 = obj0;
        
        // 与下面相同
//        id __weak obj1 = obj0;
//        id __autoreleasing temp = obj1;
        /*
         为 什 么 在 访 问 附 有 _ w e a k 修 饰 符 的 变 量 时 必 须 访 问 注 册 到 a u t o r e l e a s e p o o l 的 对 象 呢 ？ 这 是
         因 为 _ w e a k 修 饰 符 只 持 有 对 象 的 弱 引 ⽤ ， ⽽ 在 访 问 引 ⽤ 对 象 的 过 程 中 ， 该 对 象 有 可 能 被 废 弃 。
         如 果 把 要 访 问 的 对 象 注 册 到 a u t o r e l e a s e p o o l 中 ， 那 么 在 @ @ a u t o r e l e a s e p o o l 块 结 束 之 前 都 能 确 保 该 对
         象 存 在 。 因 此 ， 在 使 ⽤ 附 有 _ w e a k 修 饰 符 的 变 量 时 就 必 定 要 使 ⽤ 注 册 到 a u t o r e l e a s e p o o l 中 的 对 象 。
         */
    }
}

+ (id) array{
    id obj = [[NSMutableArray alloc]init];
    return obj;
}
// __strong 超出作用域自动释放,由于return会被释放，但是作为函数的返值 会被自己加入autoreleasePool

- (void) error{
    NSError * error = nil;
    BOOL result = [self performSelectorWitherror:&error];
    
    // 相同
    NSError ** pError1 = &error;
    NSError * __strong * pError2 = &error;
}

/*
 使 ⽤ 附 有 _ _ a u t o r e l e a s i n g 修 饰 符 的 变 量 作 为 对 象 取 与 除 a l l o c / n e w / c o p y / m u t a b l e C o p y 外 其 他 ⽅ 法 的 返 回 值 取 得 对 象 完 全 ⼀ 样 ， 都 会 注 册 到
 a u t o r e l e a s e p o o l ， 并 取 得 ⾮ ⾃ ⼰ ⽣ 成 并 持 有 的 对 象
 */
- (BOOL)performSelectorWitherror:(NSError **)error{
    return false;
}

// 等同于
- (BOOL)performSelectorWitherror1:(NSError * __autoreleasing *)error{
//    *error = [[NSError alloc]initWithDomain:MyAppDomain code:erroCode userInfo:nil];
    return false;
}

@end
