//
//  ViewController.swift
//  MCI
//
//  Created by Rafael Galdino on 18/07/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class MainViewController: UIViewController {

    @IBOutlet var labelsCollection: [UIView]!
    @IBOutlet weak var shareButton: UIButton!

    var items: [Item] = []

    let bottomSheetVC = ScrollableBottomSheetViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        ModelManager.shared().addDelegate(self)
        UNUserNotificationCenter.current().delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheetView()
        getItems()
        randomItems()
    }

    @IBAction func updateButtonTap(_ sender: Any) {
        randomItems()
    }

    @IBAction func dismissTap(_ sender: Any) {
        dismissKeyboard()
    }

    func dismissKeyboard() {
        bottomSheetVC.searchController.isActive = false
        bottomSheetVC.changeSheetState(.closed)
    }

    func resizeBottomSheetView() {
        let height = view.frame.height
        let width = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0,
                                          y: self.view.frame.maxY,
                                          width: width,
                                          height: height)
    }

    func addBottomSheetView() {
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        resizeBottomSheetView()
    }

    func randomItems() {
        if items.isEmpty { return }
        var randomItems: [Item] = []

        for label in labelsCollection {
            if let numberLabel = label.subviews[1] as? UILabel, let textLabel = label.subviews[0] as? UILabel {
                numberLabel.text = ""
                textLabel.text = ""
            }
        }

        if items.count < 6 {
            randomItems = items.shuffled()
        } else {
            for _ in 0..<5 {
                var randomItem = items.randomElement() ?? items[0]
                while randomItems.contains(randomItem) {
                    randomItem = items.randomElement() ?? items[0]
                }
                randomItems.append(randomItem)
            }
        }

        for index in 0..<randomItems.count {
            if let numberLabel = labelsCollection[index].subviews[1] as? UILabel,
                let textLabel = labelsCollection[index].subviews[0] as? UILabel {
                numberLabel.text = indexToString(randomItems[index])
                textLabel.text = randomItems[index].thing ?? ""
            }
        }

    }

    func indexToString(_ item: Item?) -> String {
        let maxIndex = String(items[0].index)
        guard let item = item else { return "00" }
        var index = "\(String(item.index))"
        while index.count < maxIndex.count {
            index = "0\(index)"
        }
        return "\(index)"
    }

    func getRandomItem() -> Item? {
        return items.randomElement()
    }

    func registerSettingsBundle() {
        let appDefaults = [String: AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    func scheduleNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            switch settings.authorizationStatus {
            case .authorized:
                notificationCenter.add(self.dailyNotifications(), withCompletionHandler: { (error) in
                    if let uError = error {
                        print("Error in registering daily notification: \(uError)")
                    }
                })
            case .denied:
                self.notificationsAlert()
            case .provisional:
                notificationCenter.add(self.dailyNotifications(), withCompletionHandler: { (error) in
                    if let uError = error {
                        print("Error in registering daily notification: \(uError)")
                    }
                })
            default:
                self.requestNotificationsPermission()
            }

        }
    }

    func dailyNotifications() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let requestIdentifier = "dailyMorningNotification"
        do {
            let randomItem = self.getRandomItem()
            content.body = self.indexToString(randomItem)
            content.title = randomItem?.thing ?? "Viver"
        }
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "dailyCategory"

        let date = DateComponents(hour: 08, minute: 30)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date,
                                                    repeats: false)
//        let trigger =   UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)

        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        return request
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        scheduleNotifications()
        return completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void) {
        scheduleNotifications()
    }

    func requestNotificationsPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { didAllow, _ in
            if !didAllow {
                self.notificationsAlert()
            } else {
                let action1 = UNNotificationAction(identifier: "action1",
                                                   title: "Ver mais",
                                                   options: [.foreground])

                let category = UNNotificationCategory(identifier: "dailyCategory",
                                                      actions: [action1],
                                                      intentIdentifiers: [],
                                                      options: [])

                notificationCenter.setNotificationCategories([category])
            }
        }
    }

    func notificationsAlert() {
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
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}

extension MainViewController: DataModifiedDelegate {
    func dataModified() {
        getItems()
        randomItems()
    }

    func getItems() {
        items = ModelManager.shared().items
    }
}
