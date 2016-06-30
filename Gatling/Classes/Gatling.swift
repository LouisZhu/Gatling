//
//  Gatling.swift
//
//  Copyright (c) 2016 Louis Zhu (http://github.com/LouisZhu)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import Foundation


/**
 Convenience function to get current dispatch queue's label
 
 - returns: current dispatch queue's label
 */
func gatling_dispatch_current_queue_label() -> String? {
    let label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)
    let string = String.fromCString(label)
    return string
}


func gatling_log(message: String) {
    #if DEBUG
        let label = gatling_dispatch_current_queue_label()
        print("In queue <\(label)>, \(message)")
    #endif
}


@objc
public protocol GatlingTarget: NSObjectProtocol {
    func shotWithBullet(_ bullet: Bullet?, ofGatling gatling: Gatling)
}


private let schedulingQueueLabel = "com.lepinardsoft.gatling.queue.scheduling"


public class Gatling: NSObject {
    
    private var missions: [Mission] = [Mission]()
    
    private var _scheduledMissionLock = NSLock()
    private var _scheduledMission: Mission?
    private var scheduledMission: Mission? {
        get {
            _scheduledMissionLock.lock()
            let mission = _scheduledMission
            _scheduledMissionLock.unlock()
            return mission
        }
        set {
            _scheduledMissionLock.lock()
            _scheduledMission = newValue
            _scheduledMissionLock.unlock()
        }
    }
    
    public static let sharedGatling = Gatling()
    
    
    private static let schedulingQueue = dispatch_queue_create(schedulingQueueLabel, DISPATCH_QUEUE_SERIAL)
    /**
     ALWAYS use this method to do mission scheduling works, for thread safety purpose.
     
     - parameter schedulingWork: the actual work.
     */
    func scheduling(schedulingWork: () -> Void) {
        dispatch_async(Gatling.schedulingQueue, schedulingWork)
    }
    
    
    /**
     Add a new mission to Gatling, then schedule it.
     
     - parameter mission: the mission to add.
     */
    func addMission(_ mission: Mission) {
        assert(gatling_dispatch_current_queue_label() == schedulingQueueLabel, "NOT IN SCHEDULING QUEUE")
        self.missions.append(mission)
        self.scheduleMission(mission)
    }
    
    func performMission(_ mission: Mission) {
        mission.target?.shotWithBullet(mission.configuration.bullet, ofGatling: self)
    }
    
    func tryToScheduleNextMission() {
        assert(gatling_dispatch_current_queue_label() == schedulingQueueLabel, "NOT IN SCHEDULING QUEUE")
        if self.scheduledMission != nil {
            return
        }
        
        if self.missions.count == 0 {
            return
        }
        
        guard let firstMission = self.missions.first else {
            return
        }
        
        let earliestMission = self.missions.reduce(firstMission) { (aMission, anotherMission) -> Mission in
            return (aMission.timeStrategy.nextFireTime < anotherMission.timeStrategy.nextFireTime) ? aMission : anotherMission
        }
        
        self.scheduleMission(earliestMission)
    }
    
    func scheduleMission(_ mission: Mission) {
        assert(gatling_dispatch_current_queue_label() == schedulingQueueLabel, "NOT IN SCHEDULING QUEUE")
        let nextFireTime = mission.timeStrategy.nextFireTime
        func schedule() {
            self.scheduledMission = nil
            gatling_dispatch_when(nextFireTime, mission.configuration.workingQueue, {
                guard let scheduledMission = self.scheduledMission else {
                    gatling_log("no scheduled mission, trying to schedule next")
                    self.scheduling {
                        self.tryToScheduleNextMission()
                    }
                    return
                }
                
                if mission !== scheduledMission {
                    gatling_log("i am not the scheduled mission, abort the work")
                    return
                }
                
                self.performMission(mission)
                self.scheduling({ 
                    mission.timeStrategy.updateNextFireTime()
                    self.scheduledMission = nil
                    self.tryToScheduleNextMission()
                })
            })
            self.scheduledMission = mission
        }
        
        guard let scheduledMission = self.scheduledMission else {
            schedule()
            return
        }
        
        if nextFireTime < scheduledMission.timeStrategy.nextFireTime {
            schedule()
            return
        }
    }
    
}


// MARK: - APIs


extension Gatling {
    
    public func loadWithTarget(target: GatlingTarget, timeInterval: NSTimeInterval, configurationHandler: (inout Configuration) -> Void) {
        var configuration = Configuration()
        configurationHandler(&configuration)
        let mission = Mission(target: target, timeInterval: timeInterval, configuration: configuration)
        self.scheduling {
            self.addMission(mission)
        }
        if configuration.shouldShootImmediately {
            dispatch_async(configuration.workingQueue, { [unowned self] in
                self.performMission(mission)
            })
        }
    }
    
    
    public func stopShootingTarget(_ target: GatlingTarget) {
        self.missions = self.missions.filter({ (mission: Mission) -> Bool in
            guard let missionTarget = mission.target else {
                return false
            }
            
            // TODO: use a safe identifier
            if unsafeAddressOf(missionTarget) != unsafeAddressOf(target) {
                return true
            }
            
            return false
        })
    }
    
    
}

