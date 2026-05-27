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
    func request(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping GGCompletion) -> GGCancellable
}

class GGJayProvider<Target:GGTargetType>: GGJayProviderTargetType {

    func request(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping GGCompletion) -> any GGCancellable {
        
    }
}
