//
//  AppDelegate.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil))
        
        return true
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let message = createMessage(forStation: "DESN061") {
            pushNotification(withMessage: message)
            completionHandler(.newData)
        }
        else {
            completionHandler(.failed)
        }
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
    
    func createMessage(forStation station: String) -> String? {
        let entries = DatabaseCaller.makeNotificationRequest(forLocation: station, withLimit: 10)
        if let entry = entries.first {
            var output = "Air quality for \(entry.city!):"
            for measurement in entry.measurements! {
                output += " \(String(measurement.value!)) \(String(measurement.unit!)) \(String(measurement.type!))"
            }
            return output
        } else {
            return nil
        }
        
    }
    
    func pushNotification(withMessage message: String) {
        
        let notification = UILocalNotification()
        notification.alertAction = "View detailled information in the App"
        notification.alertBody = message
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
        UIApplication.shared.scheduleLocalNotification(notification)
    }


}

