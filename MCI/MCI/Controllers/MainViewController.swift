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
    
    var items:[Item] = []
    
    let bottomSheetVC = ScrollableBottomSheetViewController()
    
    //    var didRotate: (Notification) -> Void = {notification in
    //        switch UIDevice.current.orientation {
    //        case .landscapeLeft, .landscapeRight:
    ////            MainViewController.isLandscaped = true
    //        default:
    ////            MainViewController.isLandscaped = false
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        //        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
        //                                               object: nil,
        //                                               queue: .main,
        //                                               using: didRotate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheetView()
        retrieveData()
        scheduleNotifications()
        randomItems()
    }
    
    @IBAction func updateButtonTap(_ sender: Any) {
        retrieveData()
        randomItems()
    }
    
    func resizeBottomSheetView(){
        let height = view.frame.height
        let width = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0,
                                          y: self.view.frame.maxY,
                                          width: width,
                                          height: height)
    }
    
    func addBottomSheetView(){
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        resizeBottomSheetView()
    }
    
    func randomItems(){
        if items.isEmpty{return}
        var thing: String = ""
        var index: String = ""
        let maxIndex = String(items[0].index)
        for i in 0...4{
            thing = ""
            index = ""
            if (items.count - 1) > i{
                let randomItem = items.randomElement()
                thing = randomItem?.thing ?? ""
                index = "\(String(randomItem?.index ?? 0))"
                while index.count < maxIndex.count{
                    index = "0\(index)"
                }
            }
            (labelsCollection[i].subviews[1] as! UILabel).text = index
            (labelsCollection[i].subviews[0] as! UILabel).text = thing
        }
    }
    
    func indexToString(_ item : Item?) -> String{
        if items.isEmpty {
            return "00"
        }
        let maxIndex = String(items[0].index)
        guard let item = item else {return "00"}
        var index = "\(String(item.index))"
        while index.count < maxIndex.count{
            index = "0\(index)"
        }
        return "\(index)"
    }
    
    func getRandomItem() -> Item? {
        self.retrieveData()
        return items.randomElement()
    }
    
    func retrieveData() {
        items = bottomSheetVC.items
    }
}

extension MainViewController: UNUserNotificationCenterDelegate{
    
    func scheduleNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings {
            (settings) in
            switch settings.authorizationStatus{
            case .authorized:
                notificationCenter.add(self.dailyNotifications(), withCompletionHandler: { (error) in
                    if let uError = error{
                        print("Error in registering daily notification: \(uError)")
                    }
                })
            case .denied:
                self.notificationsAlert()
            case .provisional:
                notificationCenter.add(self.dailyNotifications(), withCompletionHandler: { (error) in
                    if let uError = error{
                        print("Error in registering daily notification: \(uError)")
                    }
                })
            default:
                self.requestNotificationsPermission()
            }
            
        }
    }
    
    func dailyNotifications() -> UNNotificationRequest{
        let content = UNMutableNotificationContent()
        let requestIdentifier = "dailyMorningNotification"
        do{
            let randomItem = self.getRandomItem()
            content.body = self.indexToString(randomItem)
            content.title = randomItem?.thing ?? "Viver"
        }
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "dailyCategory"
        
        let date = DateComponents(hour: 08, minute: 30)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date,
                                                    repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        return request
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        return completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        scheduleNotifications()
    }
    
    
    func requestNotificationsPermission(){
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert,.sound,.badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                self.notificationsAlert()
            }else{
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
    
    func notificationsAlert(){
        let alertController = UIAlertController(title: "Notificações",
                                                message: "Uma das principais funcionalidades deste aplicativo envolve o envio de notificações. Você gostaria de habilitar as notificações deste aplicativo?",
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
