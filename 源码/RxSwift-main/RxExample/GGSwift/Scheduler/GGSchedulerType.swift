//
//  GGSchedulerType.swift
//  RxExample-iOS
//
//  Created by tuyang on 2026/5/15.
//  Copyright © 2026 Krunoslav Zaher. All rights reserved.
//

import UIKit


typealias GGTimeInterval  = DispatchTimeInterval

typealias GGRxTime = Date


///表示调度工作单元的对象。
protocol GGSchedulerType: GGImmediateSchedulerType {

    var now: GGRxTime {
        get
    }
    
    //调度要执行的操作。
    func scheduleRelative<StateType>(_ state: StateType, dueTime: GGTimeInterval, action: @escaping (StateType) -> GGDisposable) -> GGDisposable

    // 安排一个周期性的工作。
    func schedulePeriodic<StateType>(_ state: StateType, startAfter: GGTimeInterval, period: GGTimeInterval, action: @escaping (StateType) -> StateType) -> GGDisposable

}

//extension GGSchedulerType{
//    
//    func schedulePeriodic<StateType>(_ state: StateType, startAfter: GGTimeInterval, period: GGTimeInterval, action: @escaping (StateType) -> StateType) -> GGDisposable{
//        let schedule = GGSchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
//        return schedule.start()
//    }
//    
//    func scheduleRecursive<State>(_ state: State, dueTime: GGTimeInterval, action: @escaping (State, GGAnyRecursiveScheduler<State>) -> Void) -> GGDisposable {
//        let scheduler = GGAnyRecursiveScheduler(scheduler: self, action: action)
//
//        scheduler.schedule(state, dueTime: dueTime)
//        return GGDisposables.create(with: scheduler.dispose)
//    }
//
//}



protocol GGImmediateSchedulerType {
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> GGDisposable) -> GGDisposable
}



enum GGSchedulePeriodicRecursiveCommand {
    case tick
    case dispatchStart
}

//class GGSchedulePeriodicRecursive<State> {
//    typealias RecursiveAction = (State) -> State
//    private let scheduler: GGSchedulerType
//    private let startAfter: GGTimeInterval
//    private let period: GGTimeInterval
//    private let action: RecursiveAction
//    private var state: State
//    private let pendingTickCount = GGAtomicInt(0)
//    
//    init(scheduler: GGSchedulerType, startAfter: GGTimeInterval, period: GGTimeInterval, action:@escaping RecursiveAction, state: State) {
//        self.scheduler = scheduler
//        self.startAfter = startAfter
//        self.period = period
//        self.action = action
//        self.state = state
//    }
//
//    func start() -> GGDisposable {
//        scheduler.scheduleRelative(GGSchedulePeriodicRecursiveCommand.tick, dueTime: startAfter, action: tick)
//    }
//    
//    func tick(_ command: GGSchedulePeriodicRecursiveCommand, scheduler: GGRecursiveScheduler) {
//        <#function body#>
//    }
//}


//enum GGScheduleState {
//    case initial
//    case added(GGCompositeDisposable.GGDisposeKey)
//    case done
//}
//
//final class GGAnyRecursiveScheduler<State> {
//    typealias Action = (State, GGAnyRecursiveScheduler<State>) -> Void
//    private let lock = GGRecursiveLock()
//    private var scheduler: GGSchedulerType
//    private var action: Action?
//    
//    init(scheduler: GGSchedulerType, action: Action? = nil) {
//        self.scheduler = scheduler
//        self.action = action
//    }
//    
//    func schedule(_ state: State, dueTime: GGTimeInterval) {
//        var scheduleState: GGScheduleState = .initial
//        
//        let d = scheduler.scheduleRelative(state, dueTime: dueTime) { state -> GGDisposable in
//            
//        }
//        
//    }
//}

typealias GGRecursiveLock = NSRecursiveLock
