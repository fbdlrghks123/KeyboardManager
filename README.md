# KeyboardManager

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)

Automatically move the scroll position when the keyboard is raised through UITextField or UITextView in UIScrollView

TextView supports scrolling to cursor position

Support keyboard hiding automatically when touching the screen

## Requirements

|                       | Language | Minimum iOS Target | Minimum Xcode Version |
| --------------------- | -------- | ------------------ | --------------------- |
| SimpleKeyboardManager | Swift5   | iOS 10.0           | Xcode 11              |



## Installation

#### Installation with CocoaPods

***SimpleKeyboardManager:*** SimpleKeyboardManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile: ([#9](https://github.com/hackiftekhar/IQKeyboardManager/issues/9))

```ruby
pod 'SimpleKeyboardManager'
```



#### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `SimpleKeyboardManager` into your Xcode project using Carthage, add the following line to your `Cartfile`:

```
github "fbdlrghks123/SimpleKeyboardManager"
```

Run `carthage` to build the frameworks and drag the appropriate framework (`KeyboardManager_iOS.framework`) into your Xcode project based on your need. Make sure to add only one framework and not both.



#### Installation with Source Code

Only add one line to AppDelegate

```swift
import KeyboardManager // Cocoapods Use
import KeyboardManager_iOS // Carthage Use


func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     KeyboardManager.shared()
}
```



## GIF Animation

![example.gif](https://github.com/fbdlrghks123/SimpleKeyboardManager/blob/master/ScreenShot/example.gif?raw=true)



LICENSE
---

Distributed under the MIT License.