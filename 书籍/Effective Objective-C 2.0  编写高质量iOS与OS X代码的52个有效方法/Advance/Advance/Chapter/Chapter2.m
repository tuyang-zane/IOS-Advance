//
//  Chapter2.m
//  Advance
//
//  Created by tuyang on 2026/4/13.
//

#import "Chapter2.h"

@implementation Chapter2

@synthesize firstname = _myFirstname;
@dynamic lastname;


/*
 第 6 条 ： 理 解 “ 属 性 ” 这 ⼀ 概 念
 
  然 ⽽ 编 写 O b j e c t i v e - C 代 码 时 却 很 少 这 么 做 。 这 种 写 法 的 问 题 是 ： 对 象 布 局 在
 编 译 期 （ c o m p i l e t i m e ） 就 已 经 固 定 了
  这 种 写 法 的 问 题 是 ： 对 象 布 局 在
 编 译 期 （ c o m p i l e t i m e ） 就 已 经 固 定 了 。 只 要 碰 到 访 问 _
 f r s t N a m e 变 量 的 代 码 ， 编 译 器 就 把 其
 替 换 为 “ 偏 移 量 ” （ o f f s e t ） ， 这 个 偏 移 量 是 “ 硬 编 码 ” （ h a r d c o d e ） ， 表 示 该 变 量 距 离 存 放 对 象 的
 内 存 区 域 的 起 始 地 址 有 多 远 。 这 样 做 ⽬ 前 来 看 没 问 题 ， 但 是 如 果 ⼜ 加 了 ⼀ 个 实 例 变 量 ， 那 就
 麻 烦 了 。 ⽐ 如 说 ， 假 设 在 _ f i r s t N a m e 之 前 ⼜ 多 了 ⼀ 个 实 例 变 量 ：
 如 果 代 码 使 ⽤ 了 编 译 期 计 算 出 来 的 偏 移 量 ， 那 么 在 修 改 类 定 义 之 后 必 须 重 新 编 译 ， 否 则 就 会 出 错
 
 @interface Chapter2 : NSObject
 {// 成员变量
     @public
     NSString * _firstname;
     NSString * _twoname;
     NSString * _lastname;

     @private
     NSString * _date;
 }
 @end

 这 时 @ p r o p e r t y 语 法 就 派 上 ⽤ 场 了
 @property NSString * firstname; 等同于
 - (NSString*) firstName;
 - (void) setFirstName: (NSString*) firstName;
 - (NSString*) lastName;
 - (void) setLastName: (NSString*) lastName:
 
 然 ⽽ 属 性 还 有 更 多 优 势 。 如 果 使 ⽤ 了 属 性 的 话 ， 那 么 编 译 器 就 会 ⾃ 动 编 写 访 问 这 些 属
 性 所 需 的 ⽅ 法 ， 此 过 程 叫 做 “ ⾃ 动 合 成 ” （ a u t o s y n t h e s i s ） 。 需 要 强 调 的 是 ， 这 个 过 程 由 编 译
 器 在 编 译 期 执 ⾏ ， 所 以 编 辑 器 ⾥ 看 不 到 这 些 “ 合 成 ⽅ 法 ” （ s y n t h e s i z e d m e t h o d ） 的 源 代 码 。 除
 然 ⽽ 属 性 还 有 更 多 优 势 。 如 果 使 ⽤ 了 属 性 的 话 ， 那 么 编 译 器 就 会 ⾃ 动 编 写 访 问 这 些 属
 性 所 需 的 ⽅ 法 ， 此 过 程 叫 做 “ ⾃ 动 合 成 ” （ a u t o s y n t h e s i s ） 。 需 要 强 调 的 是 ， 这 个 过 程 由 编 译
 器 在 编 译 期 执 ⾏ ， 所 以 编 辑 器 ⾥ 看 不 到 这 些 “ 合 成 ⽅ 法 ” （ s y n t h e s i z e d m e t h o d ） 的 源 代 码 。 除
 了 ⽣ 成 ⽅ 法 代 码 之 外 ， 编 译 器 还 要 ⾃ 动 向 类 中 添 加 适 当 类 型 的 实 例 变 量 ， 并 且 在 属 性 名 前
 ⾯ 加 下 划 线 ， 以 此 作 为 实 例 变 量 的 名 字 。 在 前 例 中 ， 会 ⽣ 成 两 个 实 例 变 量 ， 其 名 称 分 别 为 _
 f r s t N a m e 与 _ l a s t N a m c 。 也 可 以 在 类 的 实 现 代 码 ⾥ 通 过 @ s y n t h e s i z e 语 法 来 指 定 实 例 变 量 的
 名 字 ：
 @synthesize firstname = _myFirstname;

 就 是 使 ⽤ @ d y n a m i c 关 键 字 ， 它 会 告 诉 编 译 器 ： 不 要 ⾃ 动 创 建 实 现 属 性 所 ⽤ 的 实 例 变
 量 ， 也 不 要 为 其 创 建 存 取 ⽅ 法 。 ⽽ 且 ， 在 编 译 访 问 属 性 的 代 码 时 ， 即 使 编 译 器 发 现 没 有 定 义
 存 取 ⽅ 法 ， 也 不 会 报 错 ， 它 相 信 这 些 ⽅ 法 能 在 运 ⾏ 期 找 到 。 ⽐ ⽅ 说 ， 如 果 从 C o r e D a t a 框 架
 中 的 N S M a n a g e d O b j e c t 类 ⾥ 继 承 了 ⼀ 个 ⼦ 类 ， 那 么 就 需 要 在 运 ⾏ 期 动 态 创 建 存 取 ⽅ 法 。 继 承
 N S M a n a g e d O b j e c t 时 之 所 以 要 这 样 做 ， 是 因 为 ⼦ 类 的 某 些 属 性 不 是 实 例 变 量 ， 其 数 据 来 ⾃ 后
 端 的 数 据 库 中
 @dynamic NSString * lastname
 
 属 性 特 质
 
 原 ⼦ 性:
 在 默 认 情 况 下 ， 由 编 译 器 所 合 成 的 ⽅ 法 会 通 过 锁 定 机 制 确 保 其 原 ⼦ 性 （ a t o m i c i t y ） ® ’ 。 如 果
 属 性 具 备 n o n a t o m i c 特 质 ， 则 不 使 ⽤ 同 步 锁 。 请 注 意 ， 尽 管 没 有 名 为 “ a t o m i c ” 的 特 质 （ 如
 果 某 属 性 不 具 备 n o n a t o m i c 特 质 ， 那 它 就 是 “ 原 ⼦ 的 ” （ a t o m i c ） ） ， 但 是 仍 然 可 以 在 属 性 特 质
 中 写 明 这 ⼀ 点 ， 编 译 器 不 会 报 错 。 若 是 ⾃ ⼰ 定 义 存 取 ⽅ 法 ， 那 么 就 应 该 遵 从 与 属 性 特 质 相 符
 的 原 ⼦ 性 。
 
 读 / 写 权 限
 • 具 备 r e a d w r i t e （ 读 写 ） 特 质 的 属 性 拥 有 “ 获 取 ⽅ 法 ” （ g e t t e r ） 与 “ 设 置 ⽅ 法 ” （ s e t t e r ） ® 。
 若 该 属 性 由 @ s y n t h e s i z e 实 现 ， 则 编 译 器 会 ⾃ 动 ⽣ 成 这 两 个 ⽅ 法 。
  • 具 备 r e a d o n l y （ 只 读 ） 特 质 的 属 性 仅 拥 有 获 取 ⽅ 法 ， 只 有 当 该 属 性 由 @ s y n t h e s i z e 实
 现 时 ， 编 译 器 才 会 为 其 合 成 获 取 ⽅ 法 。 你 可 以 ⽤ 此 特 质 把 某 个 属 性 对 外 公 开 为 只 读 属
 性 ， 然 后 在 “ c l a s s - c o n t i n u a t i o n 分 类 ” 中 将 其 重 新 定 义 为 读 写 属 性 。 第 2 7 条 详 述 了 这
 种 做 法 。
 
 内 存 管 理 语 义
 属 性 ⽤ 于 封 装 数 据 ， ⽽ 数 据 则 要 有 “ 具 体 的 所 有 权 语 义 ” （ c o n c r e t e o w n e r s h i p s e m a n t i c ） 。
 下 ⾯ 这 ⼀ 组 特 质 仅 会 影 响 “ 设 置 ⽅ 法 ” 。 例 如 ， ⽤ “ 设 置 ⽅ 法 ” 设 定 ⼀ 个 新 值 时 ， 它 是 应 该
 “ 保 留 ” （ r e t a i n ） ® 此 值 呢 ， 还 是 只 将 其 赋 给 底 层 实 例 变 量 就 好 ？ 编 译 器 在 合 成 存 取 ⽅ 法 时 ， 要
 根 据 此 特 质 来 决 定 所 ⽣ 成 的 代 码 。 如 果 ⾃ ⼰ 编 写 存 取 ⽅ 法 ， 那 么 就 必 须 同 有 关 属 性 所 具 备 的
 特 质 相 符
 • assign “ 设 置 ⽅ 法 ” 只 会 执 ⾏ 针 对 “ 纯 量 类 型 ” （ s c a l a r t y p e ， 例 如 C G F l o a t 或
 N S I n t e g e r 等 ） 的 简 单 赋 值 操 作 。
 • s t r o n g 此 特 质 表 明 该 属 性 定 义 了 ⼀ 种 “ 拥 有 关 系 ” （ o w n i n g r e l a t i o n s h i p ） 。 为 这 种 属
 性 设 置 新 值 时 ， 设 置 ⽅ 法 会 先 保 留 新 值 ， 并 释 放 旧 值 ， 然 后 再 将 新 值 设 置 上 去 。
 • w e a k 此 特 质 表 明 该 属 性 定 义 了 ⼀ 种 “ ⾮ 拥 有 关 系 ” （ n o n o w n i n g r e l a t i o n s h i p ） 。 这
 种 属 性 设 置 新 值 时 ， 设 置 ⽅ 法 既 不 保 留 新 值 ， 也 不 释 放 旧 值 。 此 特 质 同 a s s i g n 类 似 ，
 然 ⽽ 在 属 性 所 指 的 对 象 遭 到 摧 毁 时 ， 属 性 值 也 会 清 空 （ n i l o u t ） 。
 • u n s a f e _ u n r e t a i n e d 此 特 质 的 语 义 和 a s s i g n 相 同 ， 但 是 它 适 ⽤ 于 “ 对 象 类 型 ” （ o b j e c t
 t y p e ） ， 该 特 质 表 达 ⼀ 种 “ ⾮ 拥 有 关 系 ” （ “ 不 保 留 ” ， u n r e t a i n e d ） ， 当 ⽬ 标 对 象 遭 到 摧 毁
 时 ， 属 性 值 不 会 ⾃ 动 清 空 （ “ 不 安 全 ” ， u n s a f e ） ， 这 ⼀ 点 与 w e a k 有 区 别 。
 • c o p y 此 特 质 所 表 达 的 所 属 关 系 与 s t r o n g 类 似 。 然 ⽽ 设 置 ⽅ 法 并 不 保 留 新 值 ， ⽽ 是
 将 其 “ 拷 ⻉ ” （ c o p y ） 。 当 属 性 类 型 N S S t r i n g * 时 ， 经 常 ⽤ 此 特 质 来 保 护 其 封 装 性 ，
 因 为 传 递 给 设 置 ⽅ 法 的 新 值 有 可 能 指 向 ⼀ 个 N S M u t a b l e S t r i n g 类 的 实 例 。 这 个 类 是
 N S S t r i n g 的 ⼦ 类 ， 表 示 ⼀ 种 可 以 修 改 其 值 的 字 符 串 ， 此 时 若 是 不 拷 ⻉ 字 符 串 ， 那 么 设
 置 完 属 性 之 后 ， 字 符 串 的 值 就 可 能 会 在 对 象 不 知 情 的 情 况 下 遭 ⼈ 更 改 。 所 以 ， 这 时 就
 要 拷 ⻉ ⼀ 份 “ 不 可 变 ” （ i m m u t a b l e ） 的 字 符 串 ， 确 保 对 象 中 的 字 符 申 值 不 会 ⽆ 意 间 变
 动 。 只 要 实 现 属 性 所 ⽤ 的 对 象 是 “ 可 变 的 ” （ m u t a b l e ） ， 就 应 该 在 设 置 新 属 性 值 时 拷 ⻉
 ⼀ 份 。
 
 ⽅ 法 名
 • g e t t e r = < n a m e > 指 定 “ 获 取 ⽅ 法 ” 的 ⽅ 法 名 。 如 果 某 属 性 是 B o o l e a n 型 ， ⽽ 你 想 为
 其 获 取 ⽅ 法 加 上 “ i s ” 前 缀 ， 那 么 就 可 以 ⽤ 这 个 办 法 来 指 定 。 ⽐ 如 说 ， 在 U I S w i t c h 类
 中 ， 表 示 “ 开 关 ” （ s w i t c h ） 是 否 打 开 的 属 性 就 是 这 样 定 义 的 ：
 @property (nonatomic, getter=isOn) BOOL on;
 s e t t e r = < n a m e > 指 定 “ 设 置 ⽅ 法 ” 的 ⽅ 法 名 。 这 种 ⽤ 法 不 太 常 ⻅ 。
 通 过 上 述 特 质 ， 可 以 微 调 由 编 译 器 所 合 成 的 存 取 ⽅ 法 。 不 过 需 要 注 意 ： 若 是 ⾃ ⼰ 来 实 现
 这 些 存 取 ⽅ 法 ， 那 么 应 该 保 证 其 具 备 相 关 属 性 所 声 明 的 特 质 。 ⽐ ⽅ 说 ， 如 果 将 某 个 属 性 声 明
 为 c o p y ， 那 么 就 应 该 在 “ 设 置 ⽅ 法 ” 中 拷 ⻉ 相 关 对 象 ， 否 则 会 误 导 该 属 性 的 使 ⽤ 者 ， ⽽ 且 ，
 若 是 不 遵 从 这 ⼀ 约 定 ， 还 会 令 程 序 产 ⽣ b u g 。
 
 */

- (void)Chapter2_{
   // self.isOn
}

@end


/*
第 7 条 ： 在 对 象 内 部 尽 量 直 接 访 问 实 例 变 量
在 对 象 之 外 访 问 实 例 变 量 时 ， 总 是 应 该 通 过 属 性 来 做 ， 然 ⽽ 在 对 象 内 部 访 问 实 例 变 量 时
⼜ 该 如 何 呢 ？ O b j e c t i v e - C 的 开 发 者 们 ⼀ 直 在 激 烈 争 论 这 个 问 题 。 有 的 ⼈ 认 为 ， ⽆ 论 什 么 情
况 ， 都 应 该 通 过 属 性 来 访 问 实 例 变 量 ； 也 有 ⼈ 说 ， “ 通 过 属 性 访 问 ” 与 “ 直 接 访 问 ” 这 两 种
做 法 应 该 搭 配 着 ⽤ 。 除 了 ⼏ 种 特 殊 情 况 之 外 ， 笔 者 强 烈 建 议 ⼤ 家 在 读 取 实 例 变 量 的 时 候 采 ⽤
直 接 访 问 的 形 式 ， ⽽ 在 设 置 实 例 变 量 的 时 候 通 过 属 性 来 做 。
*/
@interface EOCPerson : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
// Convenience for firstName + " " + lastName:
- (NSString*) fullName;
- (void) setFullName: (NSString*) fullName;
@end

@implementation EOCPerson

//- (NSString *)fullName{
//    return  [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
//}
//
//- (void)setFullName:(NSString *)fullName{
//    NSArray *components = [fullName componentsSeparatedByString: @" "];
//    self.firstName = [components objectAtIndex: 0];
//    self.lastName = [components objectAtIndex: 1];
//}

/*
 // 在 f u l l N a m e 的 获 取 ⽅ 法 与 设 置 ⽅ 法 中 ， 我 们 使 ⽤ “ 点 语 法 ” ， 通 过 存 取 ⽅ 法 来 访 问 相 关 实 例 变 量 。 现 在 假 设 重 写 这 两 个 ⽅ 法 ， 不 经 由 存 取 ⽅ 法 ， ⽽ 是 直 接 访 问 实 例 变 量

 这 两 种 写 法 有 ⼏ 个 区 别 。
 • 由 于 不 经 过 O b j e c t i v e - C 的 “ ⽅ 法 派 发 ” （ m e t h o d d i s p a t c h ， 参 ⻅ 第 1 1 条 ） 步 骤 ， 所 以
 直 接 访 问 实 例 变 量 的 速 度 当 然 ⽐ 较 快 。 在 这 种 情 况 下 ， 编 译 器 所 ⽣ 成 的 代 码 会 直 接 访
 问 保 存 对 象 实 例 变 量 的 那 块 内 存 。
 • 直 接 访 问 实 例 变 量 时 ， 不 会 调 ⽤ 其 “ 设 置 ⽅ 法 ” ， 这 就 绕 过 了 为 相 关 属 性 所 定 义 的 “ 内
 存 管 理 语 义 ” 。 ⽐ ⽅ 说 ， 如 果 在 A R C 下 直 接 访 问 ⼀ 个 声 明 为 c o p y 的 属 性 ， 那 么 并 不
 会 拷 ⻉ 该 属 性 ， 只 会 保 留 新 值 并 释 放 旧 值 。
 • 如 果 直 接 访 问 实 例 变 量 ， 那 么 不 会 触 发 “ 键 值 观 测 ” （ K e y - V a l u e O b s e r v i n g , K V O ） ° 通
 知 。 这 样 做 是 否 会 产 ⽣ 问 题 ， 还 取 决 于 具 体 的 对 象 ⾏ 为 。
 • 通 过 属 性 来 访 问 有 助 于 排 查 与 之 相 关 的 错 误 ， 因 为 可 以 给 “ 获 取 ⽅ 法 ” 和 / 或 “ 设 置
 ⽅ 法 ” 中 新 增 “ 断 点 ” （ b r e a k p o i n t ） ， 监 控 该 属 性 的 调 ⽤ 者 及 其 访 问 时 机 。
 
 有 ⼀ 种 合 理 的 折 中 ⽅ 案 ， 那 就 是 ： 在 写 ⼊ 实 例 变 量 时 ， 通 过 其 “ 设 置 ⽅ 法 ” 来 做 ， ⽽ 在
 读 取 实 例 变 量 时 ， 则 直 接 访 问 之 。 此 办 法 既 能 提 ⾼ 读 取 操 作 的 速 度 ， ⼜ 能 控 制 对 属 性 的 写 ⼊
 操 作 。 之 所 以 要 通 过 “ 设 置 ⽅ 法 ” 来 写 ⼊ 实 例 变 量 ， 其 ⾸ 要 原 因 在 于 ， 这 样 做 能 够 确 保 相 关
 属 性 的 “ 内 存 管 理 语 义 ” 得 以 贯 彻 。 但 是 ， 选 ⽤ 这 种 做 法 时 ， 需 注 意 ⼏ 个 问 题 。
 
 第 ⼀ 个 要 注 意 的 地 ⽅ 就 是 ， 在 初 始 化 ⽅ 法 中 应 该 如 何 设 置 属 性 值 。 这 种 情 况 下 总 是 应
 该 直 接 访 问 实 例 变 量 ， 因 为 ⼦ 类 可 能 会 “ 覆 写 ” （ o v c r r i d e ） 设 置 ⽅ 法 。 假 设 E O C P e r s o n 有 ⼀
 个 ⼦ 类 叫 做 E O C S m i t h P e r s o n ， 这 个 ⼦ 类 专 ⻔ 表 示 那 些 姓 “ S m i t h ” 的 ⼈ 。 该 ⼦ 类 可 能 会 覆 写
 l a s t N a m e 属 性 所 对 应 的 设 置 ⽅ 法 ：
 
 另 外 ⼀ 个 要 注 意 的 问 题 是 “ 惰 性 初 始 化 ” （ l a z y i n i t i a l i z a t i o n ） e
 。 在 这 种 情 况 下 ， 必 须 通 过
 “ 获 取 ⽅ 法 ” 来 访 问 属 性 ， 否 则 ， 实 例 变 量 就 永 远 不 会 初 始 化 。 ⽐ ⽅ 说 ， E O C P e r s o n 类 也 许
 会 ⽤ ⼀ 个 属 性 来 表 示 ⼈ 脑 中 的 信 息 ， 这 个 属 性 所 指 代 的 对 象 相 当 复 杂 。 由 于 此 属 性 不 常 ⽤ ，
 ⽽ 且 创 建 该 属 性 的 成 本 较 ⾼ ， 所 以 ， 我 们 可 能 会 在 “ 获 取 ⽅ 法 ” 中 对 其 执 ⾏ 惰 性 初 始 化 ： •
 若 没 有 调 ⽤ “ 获 取 ⽅ 法 ” 就 直 接 访 问 实 例 变 量 ， 则 会 看 到 尚 未 设 置 好 的 b r a i n ， 所 以 说 ，
 如 果 使 ⽤ 了 “ 惰 性 初 始 化 ” 技 术 ， 那 么 必 须 通 过 存 取 ⽅ 法 来 访 问 b r a i n 属 性 。
  */

- (NSString *)fullName{
    return  [NSString stringWithFormat:@"%@ %@",_firstName,_lastName];
}

- (void)setFullName:(NSString *)fullName{
    NSArray *components = [fullName componentsSeparatedByString: @" "];
    _firstName = [components objectAtIndex: 0];
    _lastName = [components objectAtIndex: 1];
}

@end


/*
 第 8 条 ： 理 解 “ 对 象 等 同 性 ” 这 ⼀ 概 念
 根 据 “ 等 同 性 ” （ e q u a l i t y ） 来 ⽐ 较 对 象 是 ⼀ 个 ⾮ 常 有 ⽤ 的 功 能 。 不 过 ， 按 照 = - 操 作 符 ⽐
 较 出 来 的 结 果 未 必 是 我 们 想 要 的 ， 因 为 该 操 作 ⽐ 较 的 是 两 个 指 针 本 身 ， ⽽ 不 是 其 所 指 的 对
 象 。 应 该 使 ⽤ N S O b j e c t 协 议 中 声 明 的 “ i s E q u a l ” ： ⽅ 法 来 判 断 两 个 对 象 的 等 同 性 。
 ⼀ 般 来 说 ，
 两 个 类 型 不 同 的 对 象 总 是 不 相 等 的 （ u n e q u a l ） 。 某 些 对 象 提 供 了 特 殊 的 “ 等 同 性 判 定 ⽅ 法 ”
 （ e q u a l i t y - c h e c k i n g m e t h o d ） ， 如 果 已 经 知 道 两 个 受 测 对 象 都 属 于 同 ⼀ 个 类 ， 那 么 就 可 以 使 ⽤ 这
 种 ⽅ 法 。
 
 // 因为 b 是运行时创建的字符串，不在常量区，地址不同！
 NSString *a = @"123";
 NSString *b = [NSString stringWithFormat:@"12%d",3];
 if (a == b) {
     NSLog(@"Hello, World!");
 }

 
 N S O b j e c t 类 对 这 两 个 ⽅ 法 的 默 认 实 现 是 ： 当 且 仅 当 其 “ 指 针 值 ” （ p o i n t e r v a l u e ） ® 完 全 相
 等 时 ， 这 两 个 对 象 才 相 等 。 若 想 在 ⾃ 定 义 的 对 象 中 正 确 覆 写 这 些 ⽅ 法 ， 就 必 须 先 理 解 其 约 定
 （ c o n t r a c t ） 。 如 果 “ i s E q u a l ： ” ⽅ 法 判 定 两 个 对 象 相 等 ， 那 么 其 h a s h ⽅ 法 也 必 须 返 回 同 ⼀ 个
 值 。 但 是 ， 如 果 两 个 对 象 的 h a s h ⽅ 法 返 回 同 ⼀ 个 值 ， 那 么 “ i s E q u a l ： ” ⽅ 法 未 必 会 认 为 两 者
 相 等 。
 - (BOOL) isEqual: (id) object {
 if (self == object) return YES;
 if ([self class] != [object class]) return NO;
 EOCPerson *otherPerson = (EOPerson*) object;
 if (!_firstName isEqualToString: otherPerson.firstName])
 return NO;
 if (![_lastName isEqualToString:otherPerson.lastName])
 return NO;
 if (_age!= otherPerson.age)
 return No;
 return YES;
 }
 先 ， 直 接 判 断 两 个 指 针 是 否 相 等 。 若 相 等 ， 则 其 均 指 向 同 ⼀ 对 象 ， 所 以 受 测 的
 对 象 也 必 定 相 等 。 接 下 来 ， ⽐ 较 两 对 象 所 属 的 类 。 若 不 属 于 同 ⼀ 个 类 ， 则 两 对 象 不 相
 等 。 E O C P e r s o n 对 象 当 然 不 可 能 与 E O C D o g 对 象 相 等 。 不 过 ， 有 时 我 们 可 能 认 为 ： ⼀ 个
 E O C P e r s o n 实 例 可 以 与 其 ⼦ 类 （ ⽐ 如 E O C S m i t h P e r s o n ） 实 例 相 等 。 在 继 承 体 系 （ i n h e r i t a n c e
 h i e r a r c h y ） 中 判 断 等 同 性 时 ， 经 常 遭 遇 此 类 问 题 。 所 以 实 现 “ i s E q u a l ： ” ⽅ 法 时 要 考 虑 到 这 种
 情 况 。 最 后 ， 检 测 每 个 属 性 是 否 相 等 。 只 要 其 中 有 不 相 等 的 属 性 ， 就 判 定 两 对 象 不 等 ， 否 则
 两 对 象 相 等 。
 
 接 下 来 该 实 现 h a s h ⽅ 法 了 。 回 想 ⼀ 下 ， 根 据 等 同 性 约 定 ： 若 两 对 象 相 等 ， 则 其 哈 希 码
 （ h a s h ） ® 也 相 等 ， 但 是 两 个 哈 希 码 相 同 的 对 象 却 未 必 相 等 。 这 是 能 否 正 确 覆 写 “ i s E q u a l ： ” ⽅ 法
 的 关 键 所 在 。 下 ⾯ 这 种 写 法 完 全 可 ⾏ ：
 - (NSUInteger) hash {
   return 1337;
 }
 
 不 过 若 是 这 么 写 的 话 ， 在 c o l l e c t i o n 中 使 ⽤ 这 种 对 象 将 产 ⽣ 性 能 问 题 ， 因 为 c o l l e c t i o n 在
 检 索 哈 希 表 （ h a s h t a b l e ） 时 ， 会 ⽤ 对 象 的 哈 希 码 做 索 引 。 假 如 某 个 c o l l e c t i o n 是 ⽤ s e t ° 实 现 的 ，
 那 么 s e t 可 能 会 根 据 哈 希 码 把 对 象 分 装 到 不 同 的 数 组 ® 中 。 在 向 s e t 中 添 加 新 对 象 时 ， 要 根 据 其
 哈 希 码 找 到 与 之 相 关 的 那 个 数 组 ， 依 次 检 查 其 中 各 个 元 素 ， 看 数 组 中 已 有 的 对 象 是 否 和 将 要
 添 加 的 新 对 象 相 等 。 如 果 相 等 ， 那 就 说 明 要 添 加 的 对 象 已 经 在 s e t ⾥ ⾯ 了 。 由 此 可 知 ， 如 果
 令 每 个 对 象 都 返 回 相 同 的 哈 希 码 ， 那 么 在 s e t 中 已 有 1 0 0 0 0 0 0 个 对 象 的 情 况 下 ， 若 是 继 续 向
 其 中 添 加 对 象 ， 则 需 将 这 1 0 0 0 0 0 0 个 对 象 全 部 扫 描 ⼀ 遍 。
 
 - (NSUInteger) hash {
 NSString *stringToHash =
 [NSStringstringWithFormat: @"8@:80:81",
 firstName, _lastName, _agel;
 return [stringToHash hash];
 }
 
 */


/*
 第 9 条 ： 以 “ 类 族 模 式 ” 隐 藏 实 现 细 节
 “ 类 族 ” （ c l a s s c l u s t e r ） 是 ⼀ 种 很 有 ⽤ 的 模 式 （ p a t t e r n ） ， 可 以 隐 藏 “ 抽 象 基 类 ” （ a b s t r a c t
 b a s e c l a s s ） 背 后 的 实 现 细 节 。 O b j e c t i v e - C 的 系 统 框 架 中 普 遍 使 ⽤ 此 模 式 。 ⽐ 如 ， i O S 的 ⽤ 户
 界 ⾯ 框 架 （ u s e r i n t e r f a c e f r a m e w o r k ） U I K i t 中 就 有 ⼀ 个 名 为 U I B u t t o n 的 类 。 想 创 建 按 钮 ， 需
 要 调 ⽤ 下 ⾯ 这 个 “ 类 ⽅ 法 ” （ c l a s s m e t h o d ） 。 ：
 + (UIButton*) buttonWithType: (UIButtonType) type;
 
 现 在 举 例 来 演 示 如 何 创 建 类 族 。 假 设 有 ⼀ 个 处 理 雇 员 的 类 ， 每 个 雇 员 都 有 “ 名 字 ” 和
 “ 薪 ⽔ ” 这 两 个 属 性 ， 管 理 者 可 以 命 令 其 执 ⾏ ⽇ 常 ⼯ 作 。 但 是 ， 各 种 雇 员 的 ⼯ 作 内 容 却 不 同 。
 经 理 在 带 领 雇 员 做 项 ⽬ 时 ， ⽆ 须 关 ⼼ 每 个 ⼈ 如 何 完 成 其 ⼯ 作 ， 仅 需 指 示 其 开 ⼯ 即 可 。
 
 */

// 2. 然后是类声明
//@interface EOCEmployee : NSObject
//@property (copy) NSString *name;
//@property NSUInteger salary;
//+ (EOCEmployee *)employeeWithType:(EOCEmployeeType)type;
//@end
//
//// 3. 最后是实现
//@implementation EOCEmployee
//
//@end


