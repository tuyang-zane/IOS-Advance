//
//  EventMonitor.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

protocol EventMonitor: Sendable {
    // MARK: -请求事件
    func request(_ request: Request, didCreateInitialURLRequest urlRequest: URLRequest)
    
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest)

}

final class CompositeEventMonitor: EventMonitor {
    
    public let queue: DispatchQueue
    public var monitors: [any EventMonitor] {
        _monitors.read(\.self)
    }
    let _monitors: Protected<[any EventMonitor]>

    init(queue: DispatchQueue = DispatchQueue(label: "org.alamofire.compositeEventMonitor"), monitors: [any EventMonitor]) {
        self.queue = queue
        _monitors = Protected(monitors)
    }

    func request(_ request: Request, didCreateInitialURLRequest urlRequest: URLRequest)
    {
        
    }
    
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest){
        
    }

}
