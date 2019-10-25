# KeyboardManager

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)

Automatically move the scroll position when the keyboard is raised through UITextField or UITextView in UIScrollView

TextView supports scrolling to cursor position

Support keyboard hiding automatically when touching the screen

## Need

Swift5, RxSwift5

## Use

Only add one line to AppDelegate

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  KeyboardManager.shared()
}
```

