//
//  NotificationService.swift
//  TapToTrackNotificationService
//
//  Created by tor modin on 2025-04-10.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let type = request.content.userInfo["type"] as? String {
            savePushToQueue(type: type)
        }

        // Skicka vidare notisen så den visas normalt
        contentHandler(bestAttemptContent ?? request.content)
    }

    private func savePushToQueue(type: String) {
        let suite = UserDefaults(suiteName: "group.com.dittnamn.TapToTrack")
        var pending = suite?.stringArray(forKey: "pendingPushes") ?? []
        pending.append(type)
        suite?.set(pending, forKey: "pendingPushes")
        print("📥 (Extension) Queued push: \(type)")
    }
}
