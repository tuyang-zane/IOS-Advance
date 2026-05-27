//
//  GGJayProvider.swift
//  Basic
//
//  Created by tuyang on 2026/5/27.
//

import UIKit

typealias Completion = (_ result:Result<>) -> Void

protocol GGJayProviderTargetType:AnyObject {
    associatedtype Target: GGTargetType
    
    
}

class GGJayProvider: NSObject {

}
