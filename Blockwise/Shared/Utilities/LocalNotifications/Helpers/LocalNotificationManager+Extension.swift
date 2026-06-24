//
//  LocalNotificationManager+Extension.swift
//  ProdApp
//
//  Created by Ivan Sanna on 01/10/24.
//

import SwiftUI

/// Extension of `LocalNotificationManager` that conforms to `UNUserNotificationCenterDelegate`.
///
/// This extension provides methods for handling local notifications that are presented while
/// the app is in the foreground, as well as user interactions with notifications.
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    
    /// Handles the presentation of a notification while the app is in the foreground.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance managing notification-related activities.
    ///   - notification: The notification that will be presented.
    ///
    /// This method also updates the pending notification requests before presenting the notification.
    ///
    /// - Returns: A `UNNotificationPresentationOptions` value specifying the notification presentation style.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await getPendingRequests()
        return [.sound, .banner]
    }
    
    /// Handles the user’s response to a notification.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance that received the response.
    ///   - response: The `UNNotificationResponse` representing the user’s response to a delivered notification.
    ///
    /// This method extracts a `link_key` from the notification's `userInfo` dictionary, which is then
    /// used to determine the appropriate `LinkView` and `notificationId`. A random `UnlockAction` is
    /// selected to provide some variety, particularly if the action is intended to be randomized. Finally,
    /// a new `LinkModel` instance is created and assigned to `notificationView` after a brief delay, allowing
    /// the UI to transition smoothly.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        if let value = response.notification.request.content.userInfo["link_key"] as? String {
            
            /// The unique identifier of the notification.
            let notificationId = response.notification.request.identifier
            
            /// Attempts to create a `LinkView` from the `link_key` value.
            guard let linkView = LinkView(rawValue: value) else { return }
            
            /// Assigns a new `LinkModel` with a slight delay to allow for smooth UI handling.
            SleepTask.sleep(seconds: 0.15) {
                self.notificationView = LinkModel(
                    linkView: linkView,
                    notificationId: notificationId
                )
            }
        }
    }
}
