//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var memes = [Meme]()
    var shouldReloadCollectionView: Bool! // Reload collection view if user deletes item(s) from table view

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarHidden = true
        (window?.rootViewController as! UITabBarController).tabBar.tintColor = UIColor.orangeColor() // Change tab bar tint color to orange
        
        // Update user defaults to remember app has launched (more than) once
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let hasLauchedBeforeKey = "HasLaunchedBefore"
        if let hasLaunchedBefore = userDefaults.objectForKey(hasLauchedBeforeKey) as? Bool {
            if !hasLaunchedBefore {
                userDefaults.setObject(true, forKey: hasLauchedBeforeKey)
                userDefaults.synchronize()
            }
        }
        else {
            userDefaults.setObject(false, forKey: hasLauchedBeforeKey)
            userDefaults.synchronize()
        }
        
        shouldReloadCollectionView = false
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

