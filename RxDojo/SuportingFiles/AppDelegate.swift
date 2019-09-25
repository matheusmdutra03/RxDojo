//
//  AppDelegate.swift
//  RxDojo
//
//  Created by Matheus Dutra on 22/09/19.
//  Copyright © 2019 Matheus Dutra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.bounds = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: TransferenceDetailController())
        return true
    }
}

