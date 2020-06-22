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
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            UserDefaults.standard.set(version, forKey: SettingsBundleKeys.version)
            UserDefaults.standard.set(build, forKey: SettingsBundleKeys.build)
        }
    }

    class func getHours(hours: Float, ampm: Float) -> Int {
        var newHours = hours
        if ampm == 1 {
            newHours += 12
        }
        return Int(newHours)
    }

    class func updateNotificationSettings() {
        let settings = NotificationsManager.NotificationsSettings.self
        let userStandard = UserDefaults.standard.self

        settings.switchDaily = userStandard.bool(forKey: SettingsBundleKeys.switchDaily)
        settings.switchWeekly = userStandard.bool(forKey: SettingsBundleKeys.switchWeekly)

        settings.dailyHours = getHours(hours: userStandard.float(forKey: SettingsBundleKeys.dailyHours),
                                       ampm: userStandard.float(forKey: SettingsBundleKeys.dailyAmpm))
        settings.dailyMinutes = Int(userStandard.float(forKey: SettingsBundleKeys.dailyMinutes))

        settings.weeklyHours = getHours(hours: userStandard.float(forKey: SettingsBundleKeys.weeklyHours),
                                        ampm: userStandard.float(forKey: SettingsBundleKeys.weeklyAmpm))
        settings.weeklyMinutes = Int(userStandard.float(forKey: SettingsBundleKeys.dailyMinutes))
        settings.weekday = userStandard.integer(forKey: SettingsBundleKeys.weekday)
    }

}
