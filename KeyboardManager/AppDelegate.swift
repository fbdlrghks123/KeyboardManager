//
//  AppDelegate.swift
//  Keyboard
//
//  Created by ryuickhwan on 2019/10/22.
//  Copyright © 2019 ryuickhwan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        KeyboardManager.shared()
        return true
    }


}

