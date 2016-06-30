//
//  Configuration.swift
//  Pods
//
//  Created by Louis Zhu on 16/6/29.
//
//

import Foundation


public typealias Bullet = [String: AnyObject]


public class Configuration {
    public var shouldShootImmediately: Bool = false
    public var workingQueue: dispatch_queue_t = dispatch_get_main_queue()
    public var bullet: Bullet? = nil
    public var invalidateConditionBlock: (() -> Bool)? = nil
}
