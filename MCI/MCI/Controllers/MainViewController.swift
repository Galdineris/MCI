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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        randomItems()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheetView()
        }
    
    @IBAction func updateButtonTap(_ sender: Any) {
        retrieveData()
        randomItems()
    }
    
    
    
    
    
    
    
    
    
    
    
    func addBottomSheetView(){
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        let height = view.frame.height
        let width = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
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
    
    
    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "index",
                                                              ascending: false)]
        do {
            let result = try managedContext.fetch(fetchRequest)
            items = []
            for data in result as! [NSManagedObject] {
                items.append(data as! Item)
            }
        } catch let error as NSError{
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
    }
    
    
    
}

//        let current = UNUserNotificationCenter.current()
//        current.getNotificationSettings(completionHandler: { (settings) in
//            if settings.authorizationStatus == .notDetermined {
//                // Notification permission has not been asked yet, go for it!
//            } else if settings.authorizationStatus == .denied {
//                // Notification permission was previously denied, go to settings & privacy to re-enable
//            } else if settings.authorizationStatus == .authorized {
//                // Notification permission was already granted
//            }
//        })

//func notificationsAlert(){
//
//    let alertController = UIAlertController(title: "Notificações",
//                                            message: "Uma das funcionalidades deste aplicativo envolve o envio de notificações. Você gostaria de habilitar as notificações deste aplicativo?",
//                                            preferredStyle: .alert)
//
//    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//    alertController.addAction(cancelAction)
//    let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (_) -> Void in
//
//        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//            return
//        }
//
//        if UIApplication.shared.canOpenURL(settingsUrl) {
//            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                print("Settings opened: \(success)") // Prints true
//            })
//        }
//    }
//    alertController.addAction(settingsAction)
//    self.present(alertController,
//                 animated: true,
//                 completion: nil)
//}
