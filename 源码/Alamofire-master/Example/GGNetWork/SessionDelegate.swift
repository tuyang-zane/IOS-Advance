//
//  SessionDelegate.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/21.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

class GGSessionDelegate: NSObject,@unchecked Sendable {
    private let fileManager: FileManager
    var eventMonitor: (any GGEventMonitor)?

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}

extension GGSessionDelegate:URLSessionDelegate{
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        
    }
}
