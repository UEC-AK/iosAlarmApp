//
//  NotificationManager.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//

import Foundation
import UserNotifications

class NotificationManager {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func scheduleAlarmNotification() {
        // アラーム通知をスケジュールする
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "アラームの時間です."

        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.hour, .minute], from: appState.selectedTime)

        var dateComponents = DateComponents()
        dateComponents.hour = selectedComponents.hour
        dateComponents.minute = selectedComponents.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: "alarmNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling alarm notification: \(error.localizedDescription)")
            } else {
                print("Alarm Notification scheduled successfully")
            }
        }
    }

    func scheduleSnoozeNotification() {
        // スヌーズ通知をスケジュールする
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "アラームの時間です."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "alarmNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling snooze notification: \(error.localizedDescription)")
            } else {
                print("Snooze notification scheduled successfully")
            }
        }
    }

}

