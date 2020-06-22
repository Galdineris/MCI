//
//  HelpViewController.swift
//  MCI
//
//  Created by Rafael Galdino on 21/06/20.
//  Copyright © 2020 Rafael Galdino. All rights reserved.
//

import Foundation
import UIKit

class HelpViewController: UIViewController {
    @IBOutlet weak var viewButtonPadding: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewButtonPadding.layer.cornerRadius = 5
    }

    @IBAction func openSettings(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }

    @IBAction func dismiss(_ sender: Any) {
        checkForNotifications()
        self.dismiss(animated: true, completion: nil)
    }

    func checkForNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { didAllow, _ in
            if didAllow {
                let notificationAlertSeeMore = NSLocalizedString("SeeMore", comment: "Alert See More Option")
                let action1 = UNNotificationAction(identifier: "action1",
                                                   title: notificationAlertSeeMore,
                                                   options: [.foreground])

                let category = UNNotificationCategory(identifier: "dailyCategory",
                                                      actions: [action1],
                                                      intentIdentifiers: [],
                                                      options: [])

                notificationCenter.setNotificationCategories([category])
            }
        }
    }
}
