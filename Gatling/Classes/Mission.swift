//
//  Mission.swift
//  Pods
//
//  Created by Louis Zhu on 16/6/29.
//
//

import Foundation


class Mission {
    weak var target: GatlingTarget?
    let configuration: Configuration
    let timeStrategy: TimeStrategy
    
    var timer: dispatch_source_t?
    
    init(target: GatlingTarget, timeInterval: NSTimeInterval, configuration: Configuration) {
        self.target = target
        self.configuration = configuration
        self.timeStrategy = TimeStrategy(timeInterval: timeInterval)
    }
    
}
