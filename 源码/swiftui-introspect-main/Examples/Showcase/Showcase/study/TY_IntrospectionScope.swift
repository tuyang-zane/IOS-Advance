//
//  TY_IntrospectionScope.swift
//  Showcase
//
//  Created by tuyang on 2026/4/28.
//

import SwiftUI
import SwiftUIIntrospect
//OptionSet 是 Swift 专门用来表示【可以多选的枚举 / 选项组合】
struct TY_IntrospectionScope:OptionSet, Sendable {

	static let receiver = Self.init(rawValue: 1 << 0)
	
	static let ancestor = Self.init(rawValue: 1 << 1)

	let rawValue:UInt
	
	init(rawValue: UInt) {
		self.rawValue = rawValue
	}
	
}


//
//typealias TYIntrospectionViewID = UUID
//
//struct TY_IntrospectModifier<UIViewType:TY_IntrospectableViewType,Platform:TY_PlatformEntity> : ViewModifier{
//	
//	let id = TYIntrospectionViewID()
//	let scope: IntrospectionScope
//	let selector: IntrospectionSelector<PlatformSpecificEntity>?
//	let customize: (PlatformSpecificEntity) -> Void
//
//	init(_ viewType: UIViewType,
//		 
//	) {
//		<#statements#>
//	}
//	
//	func body(content: Content) -> some View {
//		content
//			.background(
//				Group {
//					/*
//					 给目标视图包一层 “空壳”
//					 让后续查找视图时定位更准确、更稳定
//					 （完全透明、看不见、无障碍忽略）
//					 */
//					if UIViewType.self == TY_IntrospectableViewType.self {
//						Color.white
//							.opacity(0)
//							.accessibility(hidden: true)
//					}
//				}
//			)
//			.background(
//				/*
//				 作用：
//				 创建一个锚点（标记）
//				 让后面的查找逻辑知道：
//				 从哪里开始找
//				 哪个是目标视图的位置
//				 它是 “定位标记”
//				 */
////				TYIntrospectionAnchorView(id: id)
////					.frame(width: 0, height: 0)
////					.accessibility(hidden: true)
//			)
//			.overlay {
//				// 3. overlay（核心：查找视图）
//				TY_IntrospectionView
//				
//			}
//	}
//}
//
////  强制：只有【类 class】才能遵守这个协议
////  结构体 struct / 枚举 enum 都不允许遵守！
//public protocol TY_PlatformEntity:AnyObject{
//	
//	// 不用Self 所有继承协议的都可以
//	associatedtype Base:TY_PlatformEntity
//	
//	// 作用：获取「父视图 / 祖先视图」
//	var ancestor: Base? { get }
//
//	// 作用：获取「所有子视图、孙子视图… 所有下级视图」
//	var descendants: [Base] { get }
//	
//	// 作用：判断「我是不是另一个视图的子孙」
//	func isDescendant(of other: Base) -> Bool
//}
//
//extension TY_PlatformEntity{
//	public var ancestor: Base? { nil }
//	
//	public var descendants: [Base] { [] }
//	
//	public func isDescendant(of other: Base) -> Bool { false }
//}
//
//extension TY_PlatformEntity{
//	var ancestors: some Sequence<Base> {
//		sequence(first: self~, next: {$0.ancestor~}).dropFirst()
//	}
//}
//
//postfix operator ~
//
//postfix func ~ <T>(lhs: some Any) -> T {
//	lhs as! T
//}
//
//postfix func ~ <T>(lhs: (some Any)?) -> T? {
//	lhs as? T
//}
