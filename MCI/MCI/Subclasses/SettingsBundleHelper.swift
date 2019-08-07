//
//  SettingsBundleHelper.swift
//  MCI
//
//  Created by Rafael Galdino on 04/08/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation
class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let version = "titleVersion"
        static let build = "titleBuild"
        static let switchDaily = "switchDaily"
        static let switchWeekly = "switchWeekly"
        static let dailyHours = "daily-hours"
        static let dailyMinutes = "daily-minutes"
        static let dailyAmpm = "daily-ampm"
        static let weeklyHours = "weekly-hours"
        static let weeklyMinutes = "weekly-minutes"
        static let weeklyAmpm = "weekly-ampm"
        static let weekday = "multiWeekdays"
    }
    class func checkAndExecuteSettings() {
        setVersionAndBuildNumber()
        updateNotificationSettings()
        NotificationsManager.scheduleNotifications()
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.version)
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: SettingsBundleKeys.build)
    }
    
    class func getHours(hours:Float, ampm:Float) -> Int {
        var newHours = hours
        if ampm == 1{
            newHours += 12
        }
        return Int(newHours)
    }
    
    class func updateNotificationSettings() {
        NotificationsManager.NotificationsSettings.switchDaily = UserDefaults.standard.bool(forKey: SettingsBundleKeys.switchDaily)
        NotificationsManager.NotificationsSettings.switchWeekly = UserDefaults.standard.bool(forKey: SettingsBundleKeys.switchWeekly)
        NotificationsManager.NotificationsSettings.dailyHours = getHours(hours: UserDefaults.standard.float(forKey: SettingsBundleKeys.dailyHours),
                                                                          ampm: UserDefaults.standard.float(forKey: SettingsBundleKeys.dailyAmpm))
        NotificationsManager.NotificationsSettings.dailyMinutes = Int(UserDefaults.standard.float(forKey: SettingsBundleKeys.dailyMinutes))
        NotificationsManager.NotificationsSettings.weeklyHours = getHours(hours: UserDefaults.standard.float(forKey: SettingsBundleKeys.weeklyHours),
                                                                         ampm: UserDefaults.standard.float(forKey: SettingsBundleKeys.weeklyAmpm))
        NotificationsManager.NotificationsSettings.weeklyMinutes = Int(UserDefaults.standard.float(forKey: SettingsBundleKeys.dailyMinutes))
        NotificationsManager.NotificationsSettings.weekday = UserDefaults.standard.integer(forKey: SettingsBundleKeys.weekday)
    }

}
