//
//  LocalNotificationManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import Combine
import SwiftUI
import Foundation
import ManagedSettings
import NotificationCenter
import AlarmKit

/// `LocalNotificationManager` is a singleton class responsible for managing local notifications, including authorization requests, scheduling, observing settings changes, and handling pending notifications.
///
/// This class also conforms to `UNUserNotificationCenterDelegate` to manage notification presentation and user responses.
@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
    
    /// Shared instance of `LocalNotificationManager`.
    static let shared = LocalNotificationManager()
    
    /// A set of cancellables to store observers for Combine publishers.
    private var cancellables = Set<AnyCancellable>()
    
    /// The instance of `UNUserNotificationCenter` responsible for managing notification settings and requests.
    let notificationCenter = UNUserNotificationCenter.current()
    
    /// Published property indicating whether notification authorization is granted.
    @Published var isAuthGranted: Bool = true
    
    @Published var isAlarmAuthGranted: Bool = true
    
    /// Published array of pending notification requests.
    @Published var pendingRequests: [UNNotificationRequest] = []
    
    /// Published property representing the view to be presented based on notification interactions.
    @Published var notificationView: LinkModel?
    
    /// Initializes the notification manager, sets up the delegate, and observes notification settings changes.
    override init() {
        super.init()
        notificationCenter.delegate = self
        observeSettingsChanges()
        
        Task {
            await getCurrentStatus()
            await getPendingRequests()
        }
    }
    
    /// Requests authorization for sending notifications.
    ///
    /// - Throws: An error if the authorization request fails.
    func requestAuth() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
#if MAIN_APP_TARGET
        UIApplication.shared.registerForRemoteNotifications()
#endif
        await getCurrentStatus()
    }
    
    /// Checks and updates the current notification authorization status.
    ///
    /// This method updates `isAuthGranted` to reflect whether notifications are authorized.
    func getCurrentStatus() async {
        let currentStatus = await notificationCenter.notificationSettings()
        isAuthGranted = (currentStatus.authorizationStatus == .authorized)
        Logger.debug("Current Notification Auth Status: \(isAuthGranted)")
        
        if #available(iOS 26.0, *) {
            isAlarmAuthGranted = AlarmManager.shared.authorizationState == .authorized
        } else {
            // Fallback on earlier versions
        }
    }
    
//    @available(iOS 26.0, *)
//    private func checkAlarmKitAuth() async throws {
//        switch AlarmManager.shared.authorizationState {
//        case .notDetermined:
//            let status = try await AlarmManager.shared.requestAuthorization()
//            isAlarmAuthGranted = status == .authorized
//        case .denied:
//            isAlarmAuthGranted = false
//        case .authorized:
//            isAlarmAuthGranted = true
//        @unknown default:
//            fatalError()
//        }
//    }
    
    /// Observes settings changes by monitoring `UIApplicationWillEnterForegroundNotification`.
    ///
    /// This ensures the app checks the notification settings when it enters the foreground.
    func observeSettingsChanges() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                Task {
                    await self.getCurrentStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Schedules a local notification based on the provided `LocalNotification` instance.
    ///
    /// - Parameter localNotification: A `LocalNotification` instance containing the details for scheduling the notification.
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        
        content.title = localNotification.title
        content.body = localNotification.body
        
        if localNotification.timeSensitive {
            content.interruptionLevel = .timeSensitive
        }
        
        if let subtitle = localNotification.subtitle {
            content.subtitle = subtitle
        }
        
        if let bundleImageName = localNotification.bundleImageName {
            if let url = Bundle.main.url(forResource: bundleImageName, withExtension: "") {
                if let attachment = try? UNNotificationAttachment(identifier: bundleImageName, url: url) {
                    content.attachments = [attachment]
                }
            }
        }
        
        if let userInfo = localNotification.userInfo {
            content.userInfo = userInfo
        }
        
        content.sound = .default
        
        if localNotification.scheduleType == .time {
            guard let timeInterval = localNotification.timeInterval else { return }
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: localNotification.repeats
            )
            
            let request = UNNotificationRequest(
                identifier: localNotification.identifier,
                content: content,
                trigger: trigger
            )
            
            try? await notificationCenter.add(request)
            
        } else {
            guard let dateComponents = localNotification.dateComponents else { return }
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: localNotification.repeats
            )
            
            let request = UNNotificationRequest(
                identifier: localNotification.identifier,
                content: content,
                trigger: trigger
            )
            
            try? await notificationCenter.add(request)
        }
        
        await getPendingRequests()
    }
    
    /// Fetches the pending notification requests and updates `pendingRequests`.
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
    }
    
    /// Removes a specific pending notification request.
    ///
    /// - Parameter identifier: The identifier of the notification request to be removed.
    func removePendingRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: { $0.identifier == identifier }) {
            pendingRequests.remove(at: index)
            Logger.debug("Pending notification requests: \(pendingRequests.count)")
        }
    }
    
    /// Clears all pending notification requests.
    ///
    /// This method removes all pending requests from both the notification center and the `pendingRequests` array.
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
        Logger.debug("Pending notification requests: \(pendingRequests.count)")
    }
}
