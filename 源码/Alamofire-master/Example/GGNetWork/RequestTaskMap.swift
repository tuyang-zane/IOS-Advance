//
//  RequestTaskMap.swift
//  iOS Example
//
//  Created by tuyang on 2026/5/20.
//  Copyright © 2026 Alamofire. All rights reserved.
//

import UIKit

// RequestTaskMap = 用来把 "Alamofire 的 Request" 和 "系统的 URLSessionTask" 一一绑定的映射表
struct GGRequestTaskMap {

    private typealias Events = (completed: Bool, metricsGathered: Bool)

    private var tasksToRequests: [URLSessionTask: GGRequest]
    private var requestsToTasks: [GGRequest: URLSessionTask]
    private var taskEvents: [URLSessionTask: Events]

    init(tasksToRequests: [URLSessionTask: GGRequest] = [:],
         requestsToTasks: [GGRequest: URLSessionTask] = [:],
         taskEvents: [URLSessionTask: (completed: Bool, metricsGathered: Bool)] = [:]) {
        self.tasksToRequests = tasksToRequests
        self.requestsToTasks = requestsToTasks
        self.taskEvents = taskEvents
    }
    
    subscript(_ request:GGRequest) -> URLSessionTask?{
        get { requestsToTasks[request] }
        set{
            // 如果 newValue = nil，代表要删除
            guard let newValue else {
                guard let task = requestsToTasks[request] else {
                    fatalError("RequestTaskMap consistency error: no task corresponding to request found.")
                }
                requestsToTasks.removeValue(forKey: request)
                tasksToRequests.removeValue(forKey: task)
                taskEvents.removeValue(forKey: task)
                return
            }
            
            requestsToTasks[request] = newValue
            tasksToRequests[newValue] = request
            taskEvents[newValue] = (completed: false, metricsGathered: false)
        }
    }
}
