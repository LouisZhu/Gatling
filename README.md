![Gatling: timer library written in Swift](https://cloud.githubusercontent.com/assets/423386/16545954/4f516910-416c-11e6-8d29-9058bc3dd58a.jpg)

# Gatling

[![CI Status](https://travis-ci.org/LouisZhu/Gatling.svg)](https://travis-ci.org/Louis Zhu/Gatling)
![Language](https://img.shields.io/badge/language-Swift%202-orange.svg)
[![Version](https://img.shields.io/cocoapods/v/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)
[![License](https://img.shields.io/cocoapods/l/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)
[![Platform](https://img.shields.io/cocoapods/p/Gatling.svg?style=flat)](http://cocoapods.org/pods/Gatling)

Gatling is an timer library written in Swift which lets you create multiple timers, multi-threaded. Every timers has its own interval, working queue, and other configurations.

## Features

- [x] Unlimited timers working at same time
- [x] Timers works at any dispatch queue as you wish
- [x] Each timer has its own interval, working queue, and other configurations
- [x] Stop and release a timer automatically if the caller was no longer exist

### More features under developing

- Pause/resume timers
- Use closure to report timer firing event
- Report more details to caller when a timer fired, such as how many times it has fired, the time interval from its start time, etc
- Swift 3 supporting
- Swift Package Manager supporting

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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
