//
//  TimeStrategy.swift
//  Pods
//
//  Created by Louis Zhu on 16/6/27.
//
//

import Foundation


struct TimeBaseInfo {
    static let timebase_info: mach_timebase_info_data_t = {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return info
    }()
    
    static var denom: UInt32 {
        return timebase_info.denom
    }
    
    static var numer: UInt32 {
        return timebase_info.numer
    }
}


func gatling_time_absolute_to_nanoseconds(absoluteTime: UInt64) -> UInt64 {
    return absoluteTime * UInt64(TimeBaseInfo.numer) / UInt64(TimeBaseInfo.denom)
}


func gatling_time_nanoseconds_to_absolute(nanoseconds: UInt64) -> UInt64 {
    return nanoseconds * UInt64(TimeBaseInfo.denom) / UInt64(TimeBaseInfo.numer)
}


public func gatling_dispatch_when(when: UInt64, _ queue: dispatch_queue_t, _ block: dispatch_block_t) {
    let now = mach_absolute_time()
    if when < now {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), queue, block)
        return
    }
    let delta = gatling_time_absolute_to_nanoseconds(when - now)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delta)), queue, block)
}


class TimeStrategy {
    
    let startTime: UInt64
    let timeInterval: NSTimeInterval
    
    private(set) var nextFireTime: UInt64
    
    
    init(timeInterval: NSTimeInterval) {
        let now = mach_absolute_time()
        self.startTime = now
        self.timeInterval = timeInterval
        
        self.nextFireTime = now
        self.updateNextFireTime()
    }
    
    
    func updateNextFireTime() {
        let delta = gatling_time_nanoseconds_to_absolute(UInt64(self.timeInterval * Double(NSEC_PER_SEC)))
        self.nextFireTime = self.nextFireTime + delta
    }
    
    
}
