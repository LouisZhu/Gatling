//
//  Gatling.swift
//  Gatling
//
//  Created by Louis Zhu on 16/6/24.
//  Copyright 2016 L'epinardsoft. All rights reserved.
//

import Foundation


//class WeakStuff<T: AnyObject> {
//    
//    weak var stuff: T?
//    
//    init(stuff: T) {
//        self.stuff = stuff
//    }
//    
//    func stillAlive() -> Bool {
//        if self.stuff == nil {
//            return false
//        }
//        
//        return true
//    }
//}


public typealias Bullet = [String: AnyObject]


@objc
public protocol GatlingTarget: NSObjectProtocol {
    func shotWithBullet(_ bullet: Bullet?, ofGatling gatling: Gatling)
}


public class Gatling: NSObject {
    
    private var timer: NSTimer?
    private var missions: [Mission] = [Mission]()
    
    
    public static let sharedGatling = Gatling()
    
    
    func timerFired(_ timer: NSTimer) {
        self.shoot()
    }
    
    
    func shoot() {
        self.missions = self.missions.filter({ (mission: Mission) -> Bool in
            return mission.target != nil
        })
        
        let now = NSDate()
        for mission in self.missions {
            if mission.timeStrategy.timeToGo(now) {
                self.performMission(mission)
            }
        }
    }
    
    
    func performMission(_ mission: Mission) {
        mission.target?.shotWithBullet(mission.bullet, ofGatling: self)
    }
    
}


// MARK: - Nested types


extension Gatling {
    
    
    class Mission {
        weak var target: GatlingTarget?
        let bullet: Bullet?
        let timeStrategy: TimeStrategy
        
        init(target: GatlingTarget, timeInterval: NSTimeInterval, bullet: Bullet?) {
            self.target = target
            self.bullet = bullet
            self.timeStrategy = TimeStrategy(timeInterval: timeInterval)
        }
    }
    
    
    class TimeStrategy {
        let startDate: NSDate
        let timeInterval: NSTimeInterval
        
        private var nextFireDate: NSDate
        
        init(timeInterval: NSTimeInterval) {
            let now = NSDate()
            self.startDate = now
            self.timeInterval = timeInterval
            self.nextFireDate = now.dateByAddingTimeInterval(timeInterval)
        }
        
        func timeToGo(_ date: NSDate) -> Bool {
            if date.timeIntervalSinceDate(self.nextFireDate) >= 0 {
                self.nextFireDate = self.nextFireDate.dateByAddingTimeInterval(self.timeInterval)
                return true
            }
            
            return false
        }
    }
    
    
    public struct Configuration {
        var shouldShootImmediately: Bool = false
        var workingQueue: dispatch_queue_t = dispatch_get_main_queue()
        var bullet: Bullet? = nil
        var invalidateConditionBlock: (() -> Bool)? = nil
    }
    
}


// MARK: - APIs


extension Gatling {
    
    
    public func loadWithTarget(_ target: GatlingTarget, timeInterval: NSTimeInterval, shootsImmediately: Bool, bullet: Bullet? = nil) {
        if self.timer == nil {
            let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(Gatling.timerFired(_:)), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes);
            self.timer = timer
        }
        
        let mission = Mission(target: target, timeInterval: timeInterval, bullet: bullet)
        self.missions.append(mission)
        if shootsImmediately {
            self.performMission(mission)
        }
    }
    
    
    public func loadWithTarget(target: GatlingTarget, timeInterval: NSTimeInterval, configuration: Configuration) {
        
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

