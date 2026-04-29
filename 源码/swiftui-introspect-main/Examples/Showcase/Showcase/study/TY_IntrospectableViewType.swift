//
//  TY_IntrospectableViewType.swift
//  Showcase
//
//  Created by tuyang on 2026/4/28.
//

import Cocoa

// 主协议
protocol TY_IntrospectableViewType{
	// 父 还是 直接接受
	var scope:TY_IntrospectionScope{get} // 任何遵守这个协议的类型，必须实现一个只读属性 scope
}

extension TY_IntrospectableViewType{
	
	// 如果你没有自己写 scope，我就自动给你返回 .receiver
	var scope: TY_IntrospectionScope{.receiver}
}
