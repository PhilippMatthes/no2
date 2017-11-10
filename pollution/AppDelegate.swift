//
//  AppDelegate.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var notificationEntry: PollutionDataEntry?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        State.shared.load()
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.appLaunched()
        
        if let controller = self.window?.rootViewController as? TabBarController {
            controller.tabBar.setTintColor(ofUnselectedItemsWithColor: UIColor.white.withAlphaComponent(0.7), andSelectedItemsWithColor: UIColor.white)
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil))
        
        return true
    }
    
    // Perform background fetch. 
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        if let stations = DiskJockey.loadObject(ofType: [Station](), withIdentifier: "stations") {
            for station in stations {
                NotificationManager.shared.createMessage(forStationName: station.name!) {
                    message, entry in
                    if let message = message {
                        if let entry = entry {
                            DispatchQueue.main.async {
                                self.notificationEntry = entry
                                NotificationManager.shared.pushNotification(withMessage: message, andStation: station.name!)
                                completionHandler(.newData)
                            }
                        } else {
                            completionHandler(.noData)
                        }
                    } else {
                        completionHandler(.noData)
                    }
                }
            }
        } else {
            completionHandler(.failed)
        }
    }
    
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        if notification.category == "viewCategory" {
            if let tabBarController = self.window?.rootViewController as? TabBarController {
                tabBarController.selectedIndex = 0
                if let viewController = tabBarController.selectedViewController as? ViewController {
                    DatabaseCaller.makeNotificationRequest(forLocation: identifier!, withLimit: 100) {
                        entries in
                        if let entry = entries.first {
                            let annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
                            viewController.selectedAnnotation = annotation
                            DispatchQueue.main.async {
                                viewController.performSegue(withIdentifier: "showDetail", sender: self)
                            }
                        }
                    }
                }
            }
        }
        completionHandler()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    


}

