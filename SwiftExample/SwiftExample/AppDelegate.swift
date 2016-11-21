//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by Krzysztof Zabłocki on 03/11/15.
//  Copyright © 2015 pixle. All rights reserved.
//

import UIKit
import KZPlayground

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = KZPPlaygroundViewController.new()
        window?.makeKeyAndVisible()
        return true
    }
}
