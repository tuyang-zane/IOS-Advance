//
//  TY_IntrospectionView.swift
//  Showcase
//
//  Created by tuyang on 2026/4/28.
//

import SwiftUI

typealias IntrospectionViewID = UUID

public typealias _TYPlatformViewControllerRepresentable = NSViewControllerRepresentable

@MainActor
protocol TYPlatformViewControllerRepresentable:_TYPlatformViewControllerRepresentable{
	
	typealias ViewController = NSViewControllerType
	func makePlatformViewController(context: Context) -> ViewController
	func updatePlatformViewController(_ controller: ViewController, context: Context)
	static func dismantlePlatformViewController(_ controller: ViewController, coordinator: Coordinator)
}

extension TYPlatformViewControllerRepresentable{
	public func makeNSViewController(context: Context) -> ViewController {
		makePlatformViewController(context: context)
	}
	
	public func updateNSViewController(_ controller: ViewController, context: Context) {
		updateNSViewController(controller, context: context)
	}
	
	public static func dismantleNSViewController(_ controller: ViewController, coordinator: Coordinator) {
		dismantlePlatformViewController(controller, coordinator: coordinator)
	}
}

//struct TY_IntrospectionView<Target: TY_PlatformEntity>:TYPlatformViewControllerRepresentable {
//
////	typealias NSViewControllerType = TYIntrospectionPlatformViewController
//
//	final class TargetCache {
//		weak var target: Target? = nil
//	}
//
//	private let id: IntrospectionViewID
//
//	@Binding
//	private var observed: Void // workaround for state changes not triggering view updates
//
//	private let selector: (TYIntrospectionPlatformViewController) -> Target?
//	private let customize: (Target) -> Void
//
//}

final class TYIntrospectionPlatformViewController: TYPlatformViewController {
	
	let id: IntrospectionViewID
	var handler: (() -> Void)? = nil

	init(id: IntrospectionViewID, handler: (() -> Void)? = nil) {
		self.id = id
		super.init(nibName: nil, bundle: nil)
		self.handler = { [weak self] in
			guard let self else { return }
//			handler?(self)
		}
//		self.isIntrospectionPlatformEntity = true
//		IntrospectionStore.shared[id, default: .init()].controller = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

public typealias TYPlatformViewController = NSViewController

import ObjectiveC

//extension TY_PlatformEntity {
//	
//	// UnsafeRawPointer.self → 目标类型是：UnsafeRawPointer（原始指针）
//	var isIntrospectionPlatformEntity: Bool {
//		get {
//			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
//			return objc_getAssociatedObject(self, key) as? Bool ?? false
//		}
//		set {
//			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
//			objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//		}
//	}
//}

//extension TY_PlatformEntity {
//	/*
//	 给 UIView/NSView 动态加一个存储属性
//	 存的是 introspect 核心控制器
//	 用 Weak 弱引用，避免内存泄漏
//	 用 Runtime 关联对象实现存储
//	 给视图绑一个 “不会泄漏的间谍控制器”，用来做 SwiftUI 视图内省。
//	 */
//	fileprivate var introspectionController: TYIntrospectionPlatformViewController? {
//		get {
//			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
//			return (objc_getAssociatedObject(self, key) as? Weak<TYIntrospectionPlatformViewController>)?.wrappedValue
//		}
//		set {
//			let key = unsafeBitCast(Selector(#function), to: UnsafeRawPointer.self)
//			objc_setAssociatedObject(self, key, Weak(wrappedValue: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//		}
//	}
//}


/*
 // 作用：让引用类型的变量变成 weak 弱引用，防止循环引用（内存泄漏）！
 weak 不能用在很多地方
 不能用在 let
 不能用在泛型里
 不能用在 @State 里
 不能用在数组里
 @Weak 包装后，哪里都能用！
 结构体内
 泛型里
 数组里
 各种高级封装里
 */
@_spi(Advanced)
@propertyWrapper
public final class Weak<T: AnyObject> {
	private weak var _wrappedValue: T? = nil

	public var wrappedValue: T? {
		get { _wrappedValue }
		set { _wrappedValue = newValue }
	}

	public init(wrappedValue: T? = nil) {
		self._wrappedValue = wrappedValue
	}
}


