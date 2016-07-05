![Gatling: timer library written in Swift](https://cloud.githubusercontent.com/assets/423386/16545954/4f516910-416c-11e6-8d29-9058bc3dd58a.jpg)

# Gatling

[![CI Status](https://travis-ci.org/LouisZhu/Gatling.svg)](https://travis-ci.org/Louis Zhu/Gatling)
![Language](https://img.shields.io/badge/language-Swift%202-orange.svg)
[![Version](https://img.shields.io/cocoapods/v/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)
[![License](https://img.shields.io/cocoapods/l/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)
[![Platform](https://img.shields.io/cocoapods/p/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)

Gatling is an timer library written in Swift which lets you create multiple timers, multithreaded. Every timers has its own interval, working queue, and other configurations.

## Features

- [x] Unlimited timers working at same time
- [x] Timers works at any dispatch queue as you wish
- [x] Each timer has its own interval, working queue, and other configurations
- [x] Use closure to report timer firing event
- [x] Stop and release a timer automatically if the caller was no longer exist

### More features under developing

- Pause/resume timers
- Report more details to caller when a timer fired, such as how many times it has fired, the time interval from its start time, etc
- Swift 3 supporting
- Carthage supporting

## How to use

### Start a timer (load gatling)

```swift
Gatling.loadWithTarget(self, timeInterval: 2.0)
```

### The timer firing (gatling shooting) event

Normally, Gatling invokes a 'callback' method to inform the caller that the timer is firing (the gatling is shooting). You can simply implement the method to receive the event.

```swift
extension MyClass: GatlingTarget {
    
    func shotWithBullet(bullet: Bullet?) {
        print("Ahhhh, I'm being shot by gatling")
    }
    
}
```

### Configure the timer

Beside the simplest timer mentioned above, you can configure your timer for more details. Including

- `shouldShootImmediately: Bool`: Indicates if the timers should fire immediately. If `false` it doesn't, just acts like the `NSTimer`; if `true`, the timer will perform an extra firing immediately after the 'loading' method was invoked.
- `workingQueue: dispatch_queue_t`: In which dispatch queue the callback will execute. Yes gatling is a multithreaded timer so you can specify any queue as you wish.
- `bullet: Bullet?`: The user info for the timer, treat it as `userInfo` of `NSTimer`. Gatling will pass it back to you in the callback method.

```swift
        Gatling.loadWithTarget(self, timeInterval: 1.5) { (configuration) in
            configuration.shouldShootImmediately = true
            configuration.workingQueue = dispatch_queue_create("com.mycompany.queue.working", nil)
            configuration.bullet = ["Identifier": "some identifier"]
        }
```

### Callback closure

You can use a callback closure to receive the timer's firing event. Specify it in the `Configuraion`.

```swift
        Gatling.loadWithTarget(self, timeInterval: 1.5) { (configuration) in
            configuration.onShoot = { bullet in
                print("Ahhhh, I'm being shot by gatling")
            }
        }
```

NOTE: if you have specified a callback closure the 'callback method' will not be invoked.

## About the precision

Gatling is designed to be a easy way to use multiple timers for most cocoa developers. So it is NOT a high precision timer.

- High precision in not needed for regular usage of timers, such as scroll the paged-advertisement-banner periodically, or fetch new data in background periodically.
- High precision timers consume compute cycles and battery.

Gatling uses GCD as the underlying technology. So it's better to keep the timer's working queue clean and simple to avoid blocking the queue. The best practice is to use an individual queue for every individual timer.

Gatling uses mach absolute time to offer the highest precision as possible. For more information, please refer <https://developer.apple.com/library/mac/qa/qa1398/_index.html>

For more information about high precision timers, or you do need a high precision timer, please refer <https://developer.apple.com/library/ios/technotes/tn2169/_index.html>

## Installation

Gatling is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Gatling"
```

## Author

Louis Zhu, zhuxiaofan@gmail.com

## License

Gatling is available under the MIT license. See the LICENSE file for more info.
