//
//  TextType.swift
//  swiftui-introspect
//
//  Created by tuyang on 2026/4/27.
//
#if !os(watchOS)

// 枚举
public struct TextType:TY_IntrospectableViewType{}

// 关联
extension TY_IntrospectableViewType where Self == TextType{
	internal static var text:Self{.init()}
}

#if canImport(UIKit)
public import UIKit
extension iOSViewVersion<TextType,UILabel>{
	public static let v13 = Self(for: .v13)
	public static let v14 = Self(for: .v14)
	public static let v15 = Self(for: .v15)
	public static let v16 = Self(for: .v16)
	public static let v17 = Self(for: .v17)
	public static let v18 = Self(for: .v18)
	public static let v26 = Self(for: .v26)
}

#elseif canImport(AppKit)

//public import AppKit
//extension macOSViewVersion<TextType, NSLabel> {
//	public static let v10_15 = Self(for: .v10_15)
//	public static let v11 = Self(for: .v11)
//	public static let v12 = Self(for: .v12)
//	public static let v13 = Self(for: .v13)
//	public static let v14 = Self(for: .v14)
//	public static let v15 = Self(for: .v15)
//	public static let v26 = Self(for: .v26)
//}

#endif

#endif
