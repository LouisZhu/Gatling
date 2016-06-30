//
//  TimeStrategy.swift
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
