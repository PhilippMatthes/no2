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
    
    var notificationEntry: PollutionDataEntry?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil))
        
        return true
    }
    
    // Perform background fetch. 
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let stations = DiskJockey.getStations() {
            for station in stations {
                if let message = createMessage(forStationName: station.name!) {
                    pushNotification(withMessage: message, andStation: station.name!)
                    completionHandler(.newData)
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
                    let entries = DatabaseCaller.makeNotificationRequest(forLocation: identifier!, withLimit: 100)
                    if let entry = entries.first {
                        let annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
                        viewController.selectedAnnotation = annotation
                        viewController.performSegue(withIdentifier: "showDetail", sender: self)
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
    
    func createMessage(forStationName stationName: String) -> String? {
        let entries = DatabaseCaller.makeNotificationRequest(forLocation: stationName, withLimit: 100)
        if let entry = entries.first {
            
            notificationEntry = entry
            
            var output = "Air quality for \(entry.location!)"
            if let date = entry.getMostRecentMeasurement()?.date?.dropFirst(11) {
                output += " (last updated: \(date))\n\n"
            }
            else {
                output += ":\n\n"
            }
            for key in Constants.units {
                if let measurement = entry.getMostRecentMeasurement(forType: key) {
                    let percentage = measurement.value! / Constants.maxValues[key]!
                    let roundedPercentage = Double(round(percentage*1000)/10)
                    output += "\(measurement.value!) \(measurement.unit!) (\(measurement.type!.capitalized)) - \(roundedPercentage) %% of RM\n"
                }
            }
            output += "\nRM: Recommended Maximum"
            return output
        } else {
            return nil
        }
        
    }
    
    func pushNotification(withMessage message: String, andStation station: String) {
        let viewAction = UIMutableUserNotificationAction()
        viewAction.identifier = station
        viewAction.title = "\(station)"
        viewAction.activationMode = UIUserNotificationActivationMode.background
        viewAction.isAuthenticationRequired = true
        viewAction.isDestructive = false
        viewAction.activationMode = .foreground
        
        let viewCategory = UIMutableUserNotificationCategory()
        viewCategory.identifier = "viewCategory"
        
        viewCategory.setActions([viewAction], for: UIUserNotificationActionContext.default)
        viewCategory.setActions([viewAction], for: UIUserNotificationActionContext.minimal)
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge], categories: NSSet(object: viewCategory) as? Set<UIUserNotificationCategory>)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        let notification = UILocalNotification()
        notification.alertAction = "View detailled information in the App"
        notification.alertBody = message
        notification.alertTitle = station
        notification.category = "viewCategory"
        notification.fireDate = Date()
        UIApplication.shared.scheduleLocalNotification(notification)
    }


}

