//
//  EventMonitor.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/19.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

protocol GGEventMonitor: Sendable {
    // MARK: -请求事件
    func request(_ request: GGRequest, didCreateInitialURLRequest urlRequest: URLRequest)
    
    func request(_ request: GGRequest, didCreateURLRequest urlRequest: URLRequest)

    func request(_ request: GGRequest, didResumeTask task: URLSessionTask)
    
    func request(_ request: GGRequest, didSuspendTask task: URLSessionTask)

    func request(_ request: GGRequest, didCancelTask task: URLSessionTask)

}

extension GGEventMonitor{
    func request(_ request: GGRequest, didCreateInitialURLRequest urlRequest: URLRequest){}
    
    func request(_ request: GGRequest, didCreateURLRequest urlRequest: URLRequest){}
    
    func request(_ request: GGRequest, didResumeTask task: URLSessionTask) {}
    
    func request(_ request: GGRequest, didSuspendTask task: URLSessionTask){}
    
    func request(_ request: GGRequest, didCancelTask task: URLSessionTask) {}
}

final class GGCompositeEventMonitor: GGEventMonitor {
    
    public let queue: DispatchQueue
    public var monitors: [any GGEventMonitor] {
        _monitors.read(\.self)
    }
    let _monitors: GGProtected<[any GGEventMonitor]>

    init(queue: DispatchQueue = DispatchQueue(label: "org.GG.alamofire.compositeEventMonitor"), monitors: [any GGEventMonitor] = []) {
        self.queue = queue
        _monitors = GGProtected(monitors)
    }

    func request(_ request: GGRequest, didCreateInitialURLRequest urlRequest: URLRequest)
    {
        
    }
    
    func request(_ request: GGRequest, didCreateURLRequest urlRequest: URLRequest){
        
    }
    
    func request(_ request: GGRequest, didResumeTask task: URLSessionTask) {
        
    }
    
    func request(_ request: GGRequest, didSuspendTask task: URLSessionTask)
    {
        
    }
    
    func request(_ request: GGRequest, didCancelTask task: URLSessionTask) {
        
    }

}
