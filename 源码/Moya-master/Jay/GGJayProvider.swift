//
//  GGJayProvider.swift
//  Basic
//
//  Created by tuyang on 2026/5/27.
//

import UIKit

typealias GGCompletion = (_ result:Result<GGResponse,GGError>) -> Void

protocol GGJayProviderTargetType:AnyObject {
    associatedtype Target: GGTargetType
    
    /// 指定的请求发起方式。返回一个“可取消”令牌，以便稍后取消该请求。
    func request(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping GGCompletion) -> GGCancellable
}

class GGJayProvider<Target:GGTargetType>: GGJayProviderTargetType {

    /// 传递给 Alamofire 作为回调队列。如果为空，则将使用 Alamofire 的默认值（自 2017 年其 API 发布以来，即主线程队列）。
    let callbackQueue: DispatchQueue?
    
    func request(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping GGCompletion) -> any GGCancellable {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        requestNormal(target, callbackQueue: callbackQueue, completion: completion)
    }
    
    func endpoint(_ token:GGTargetType) -> <#return type#> {
        <#function body#>
    }
}


extension GGJayProvider {
    func requestNormal(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping Moya.GGCompletion) -> GGCancellable {
        
    }
}
