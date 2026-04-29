//
//  main.swift
//  Showcase
//
//  Created by tuyang on 2026/4/29.
//

import SwiftUI
import SwiftUIIntrospect
import AppKit

extension View{
	// 主方法，获取uikit类型
	@MainActor
	public func ty_introspect<SwiftUIViewType: IntrospectableViewType, PlatformSpecificEntity: PlatformEntity>(
		_ viewType: SwiftUIViewType,
		on platforms: PlatformViewVersionPredicate<SwiftUIViewType, PlatformSpecificEntity>...,
		customize: @escaping (PlatformSpecificEntity) -> Void
	) -> some View {
		self.modifier(TY_IntrospectModifier(viewType, platforms: platforms,customize: customize))
	}
}

struct TY_IntrospectModifier<SwiftUIViewType:IntrospectableViewType,PlatformSpecificEntity: PlatformEntity> : ViewModifier{

//	let id = udid
//	let scope: IntrospectionScope
//	let selector: IntrospectionSelector<PlatformSpecificEntity>?
	let customize: (PlatformSpecificEntity) -> Void
//	let selector: ((PlatformSpecificEntity, IntrospectionScope) -> PlatformSpecificEntity?)?

	let targetType: PlatformSpecificEntity.Type

	init(_ viewType: SwiftUIViewType,
		 platforms: [PlatformViewVersionPredicate<SwiftUIViewType, PlatformSpecificEntity>],
		 customize: @escaping (PlatformSpecificEntity) -> Void
	) {
		self.customize = customize
		
		self.targetType = PlatformSpecificEntity.self

//		self.selector = platforms.lazy.compactMap(\.selector).first
	}

	func body(content: Content) -> some View {
		content
			.background(
				Group {
					/*
					 给目标视图包一层 “空壳”
					 让后续查找视图时定位更准确、更稳定
					 （完全透明、看不见、无障碍忽略）
					 */
					if SwiftUIViewType.self == TY_IntrospectableViewType.self {
						Color.white
							.opacity(0)
							.accessibility(hidden: true)
					}
				}
			)
			.background(
				/*
				 作用：
				 创建一个锚点（标记）
				 让后面的查找逻辑知道：
				 从哪里开始找
				 哪个是目标视图的位置
				 它是 “定位标记”
				 */
				AnchorView()
					.frame(width: 0, height: 0)
					.accessibility(hidden: true)
			)
			.overlay {
				// 3. 侦察兵（核心查找）
				IntrospectionView(targetType: targetType, customize: customize)
					.frame(width: 0, height: 0)

			}
	}
}

class IntrospectStore {
	@MainActor static let shared  = IntrospectStore()
	var anchor: NSView? = nil
}

struct AnchorView:NSViewRepresentable {
	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		// 把这个 view 存起来，供后续查找使用
		// 实际库中会通过 Environment 或全局弱引用字典来传递
		IntrospectStore.shared.anchor = view
		return view
	}
	func updateNSView(_ nsView: NSView, context: Context) {
		
	}
}

struct IntrospectionView<Entity: PlatformEntity>: NSViewRepresentable {
	let targetType: Entity.Type // 接收目标的类型
	let customize: (Entity) -> Void

	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		return view
	}
	
	func updateNSView(_ nsView: NSView, context: Context) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			// 1. 拿到锚点（背景里的透明 View）
			guard let anchor = IntrospectStore.shared.anchor else {
				print("❌ 还没找到锚点")
				return
			}
			
			// 2. 打印调试信息，看看锚点的父视图里到底有哪些子视图
			print("✅ 找到锚点，它的父视图是: \(String(describing: anchor.superview))")
			if let subviews = anchor.superview?.subviews {
				print("父视图里的所有子视图：", subviews.map { NSStringFromClass(type(of: $0)) })
			}

			// 3. 在锚点的父视图或同级视图里，寻找类型匹配的视图
			// 注意：根据实际打印结果，你可能需要调整查找路径（比如找 superview 的 superview）
			if let foundView = anchor.superview?.subviews.first(where: { $0 is Entity }) as? Entity {
				print("🎉 成功找到目标控件：", foundView)
				customize(foundView)
			} else {
				print("⚠️ 在父视图的子视图里没找到目标类型：", Entity.self)
			}
		}
	}
}


extension View{
	var uiView: NSView? {
		// 这里需要通过 UIHostingController 或者其他方式获取，
		// 但在学习阶段，你可以理解为：我们需要一个桥梁拿到当前的 UIView 实例
		// 原版库是通过 IntrospectionAnchorView 内部实现的
		return nil
	}
}
