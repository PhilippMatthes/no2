//
//  NotificationManager.swift
//  pollution
//
//  Created by Philipp Matthes on 08.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class NotificationManager {
    
    static let shared = NotificationManager()
    
    var sentNotifications = [Notification]()
    
    private init() {
        loadSentNotifications()
    }
    
    func loadSentNotifications() {
        if let notifications = DiskJockey.loadObject(ofType: [Notification](), withIdentifier: "notifications") {
            self.sentNotifications = notifications
        }
    }
    
    func createMessage(forStationName stationName: String, completionHandler: @escaping (_ message: String?, _ entry: PollutionDataEntry?) -> ()) {
        DatabaseCaller.makeNotificationRequest(forLocation: stationName, withLimit: 100) {
            entries in
            if let entry = entries.first {
                
                let date = entry.getMostRecentMeasurement()!.date!
                let notification = Notification(stationName: stationName, date: date)
                
                if notification.occursIn(list: self.sentNotifications) {
                    completionHandler(nil, nil)
                }
                else {
                    let location = CLLocation(latitude: entry.latitude!, longitude: entry.longitude!)
                    CoordinateWizard.fetchCountryAndCity(location: location) {
                        country, city in
                        var output = "\(NSLocalizedString("currentAirQualityFor", comment: "")) \(city) (\(country)) \n\n"
                        for key in Constants.units {
                            if let measurement = entry.getMostRecentMeasurement(forType: key) {
                                let percentage = measurement.value! / Constants.maxValues[key]!
                                let roundedPercentage = Double(round(percentage*1000)/10)
                                output += "\(measurement.value!) \(measurement.unit!) (\(measurement.type!.capitalized)) - \(roundedPercentage) %%\n"
                            }
                        }
                        
                        self.sentNotifications.append(notification)
                        DiskJockey.save(object: self.sentNotifications, withIdentifier: "notifications")
                        
                        completionHandler(output, entry)
                    }
                }
            } else {
                completionHandler(nil, nil)
            }
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
