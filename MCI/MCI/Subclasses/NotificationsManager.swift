//
//  NotificationsManager.swift
//  MCI
//
//  Created by Rafael Galdino on 04/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationsManager {
    public struct NotificationsSettings {
        static var switchDaily: Bool = false
        static var switchWeekly: Bool = false
        static var dailyHours: Int = 8
        static var dailyMinutes: Int = 30
        static var weeklyHours: Int = 8
        static var weeklyMinutes: Int = 30
        static var weekday: Int = 1
    }

    class func scheduleNotifications() {
        if !(ModelManager.shared().items.isEmpty) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    if NotificationsSettings.switchDaily {
                        notificationCenter.add(self.dailyNotification(), withCompletionHandler: { (error) in
                            if let uError = error {
                                print("Error in registering daily notification: \(uError)")
                            }
                        })
                    } else {
                        notificationCenter.removeDeliveredNotifications(withIdentifiers: ["dailyNotification"])
                    }
                    if NotificationsSettings.switchWeekly {
                        notificationCenter.add(self.weeklyNotification(), withCompletionHandler: { (error) in
                            if let uError = error {
                                print("Error in registering weekly notification: \(uError)")
                            }
                        })
                    } else {
                        notificationCenter.removeDeliveredNotifications(withIdentifiers: ["weeklyNotification"])
                    }
                case .denied:
                    self.notificationsAlert()
                default:
                    self.requestNotificationsPermission()
                }
            }
        }
    }

    class func dailyNotification() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let requestIdentifier = "dailyNotification"
        do {
            let item = randomItem()
            content.body = item.0
            content.title = item.1
        }
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "dailyCategory"
        let date = DateComponents(hour: NotificationsSettings.dailyHours,
                                  minute: NotificationsSettings.dailyMinutes)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date,
                                                    repeats: false)

        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        print("Daily Scheduled for \(date)")
        return request
    }

    class func weeklyNotification() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let requestIdentifier = "weeklyNotification"
        let item = randomItem()
        content.body = item.0
        content.title = item.1
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "weeklyCategory"
        let date = DateComponents(hour: NotificationsSettings.weeklyHours,
                                  minute: NotificationsSettings.weeklyMinutes,
                                  weekday: NotificationsSettings.weekday)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date,
                                                    repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        print("Weekly Scheduled for \(date)")
        return request
    }

    class func requestNotificationsPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { (didAllow, _) in
            if !didAllow {
                self.notificationsAlert()
            } else {
                let action1 = UNNotificationAction(identifier: "action1",
                                                   title: "Ver mais",
                                                   options: [.foreground])
                let dailyCategory = UNNotificationCategory(identifier: "dailyCategory",
                                                      actions: [action1],
                                                      intentIdentifiers: [],
                                                      options: [])
                let weeklyCategory = UNNotificationCategory(identifier: "weeklyCategory",
                                                      actions: [action1],
                                                      intentIdentifiers: [],
                                                      options: [])
                notificationCenter.setNotificationCategories([dailyCategory, weeklyCategory])
            }
        }
    }

    class func notificationsAlert() {
        let notificationsAlertTitle = "Notificações"
        let notificationsAlertBody = "Uma das principais funcionalidades "
        + "deste aplicativo envolve o envio de notificações. "
        + "Você gostaria de habilitar as notificações deste aplicativo?"
        let alertController = UIAlertController(title: notificationsAlertTitle,
                                                message: notificationsAlertBody,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        let settingsAction = UIAlertAction(title: "Sim", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
    }
    class func randomItem() -> (String, String) {
        let items = ModelManager.shared().items
        guard let randomItem = items.randomElement() else {
            return ("00", "Viver")
        }
        let maxIndex = String(items[0].index)
        let thing = randomItem.thing ?? ""
        var index = "\(String(randomItem.index))"
        while index.count < maxIndex.count {
            index = "0\(index)"
        }
        return (index, thing)
    }
}
