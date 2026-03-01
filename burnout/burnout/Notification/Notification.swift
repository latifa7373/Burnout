//
//  Notification.swift
//  burnout
//
//  Created by Elham Alhemidi on 24/08/1447 AH.
//

import Foundation
import UserNotifications

enum NotificationManager {
    private static let dailyReminderId = "dailyCheckInReminder"

    static func requestAndScheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                scheduleDailyReminder(at: time)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        scheduleDailyReminder(at: time)
                    }
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    static func scheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)

        let content = UNMutableNotificationContent()
        content.title = "Daily check-in"
        content.body = "Take a minute to check in."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderId, content: content, trigger: trigger)
        center.add(request)
    }

    static func rescheduleFromStoredTimeIfPossible() {
        guard let savedTime = loadStoredWorkEndTime() else { return }
        requestAndScheduleDailyReminder(at: savedTime)
    }

    private static func loadStoredWorkEndTime() -> Date? {
        let defaults = UserDefaults.standard

        if let date = defaults.object(forKey: "workEndTime") as? Date {
            return date
        }

        if let timeString = defaults.string(forKey: "workEndTime") {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.date(from: timeString)
        }

        return nil
    }
}
