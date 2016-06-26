//
//  ViewController.swift
//  Gatling
//
//  Created by Louis Zhu on 06/24/2016.
//  Copyright (c) 2016 Louis Zhu. All rights reserved.
//

import UIKit
import Gatling


class ViewController: UIViewController, GatlingTarget {
    var a = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Gatling.sharedGatling.loadWithTarget(self, timeInterval: 0.5, shootsImmediately: true, bullet: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func shotWithBullet(bullet: Bullet?, ofGatling gatling: Gatling) {
        NSLog("cc")
        
        if a < 10 {
            a++
        }
        else {
            Gatling.sharedGatling.stopShootingTarget(self)
        }
    }

}

