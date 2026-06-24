//
//  DeviceActivityMonitorExtension.swift
//  DeviceMonitor
//
//  Created by Ivan Sanna on 26/10/24.
//

import CoreData
import FamilyControls
import DeviceActivity
import ManagedSettings

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()
    private let scheduleStore = ManagedSettingsStore(named: .init("schedule_store"))
    private let focusStore = ManagedSettingsStore(named: .init("focus_store"))

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        handleIntervalDidStart(for: activity)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        handleIntervalDidEnd(for: activity)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        handleIntervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
    
    // MARK: - handleIntervalWillEndWarning
    /// Handles the end-of-warning state for a given `DeviceActivityName`, re-locking associated applications and updating related data.
    ///
    /// - Parameter activity: The `DeviceActivityName` containing activity information, where the first component of its raw value is used to identify the associated `BlockEntity`.
    private func handleIntervalWillEndWarning(for activity: DeviceActivityName) {
        // Split the activity in order to find:
        // $0 -> block.identifier
        // $1 -> UUID()
        let components = activity.rawValue.components(separatedBy: "_")
        
        // Safety check - should never fail but it's safer to check
        guard components.count >= 2 else { return }

        // Extract the block.identifier
        let blockId = components[0]
        
        // Define the predicate for the Core Data fetch request
        let predicate = NSPredicate(format: "identifier == %@", blockId)

        // Fetch the BlockEntity from Core Data
        let blocks = CoreDataStack.shared.fetchEntities(
            for: BlockEntity.self,
            predicate: predicate,
            fetchLimit: 1
        )
        
        // Ensure a valid restriction was fetched, otherwise send notification for debugging
        guard let block = blocks.first else {
            Task {
                let notification = LocalNotification(
                    identifier: UUID().uuidString,
                    title: "Error: Block Not Found",
                    body: "The block was not found in from CoreData.",
                    timeInterval: 0.1,
                    repeats: false
                )
                await LocalNotificationManager.shared.schedule(localNotification: notification)
            }
            return
        }
        
        guard let tokenString = block.appTokenString else { return }
        guard let appToken = ApplicationToken.fromRawValue(tokenString) else { return }
                
        // Re-lock the app by adding it back to the shield
        store.shield.applications?.insert(appToken)
        
        block.isOpen = false
        block.isOpenForToday = false
        try? CoreDataStack.shared.saveContext()
    }
    
    // MARK: - handleIntervalDidStart
    /// Handles the start interval state for a given `DeviceActivityName`
    ///
    /// - Parameter activity: The `DeviceActivityName` containing activity information, where the second component of its raw value is used to identify the associated `ScheduleEntity`.
    private func handleIntervalDidStart(for activity: DeviceActivityName) {
        // Split the activity in order to find:
        // $0 -> "schedule"
        // $1 -> schedule.identifier
        // $2 -> UUID()
        let components = activity.rawValue.components(separatedBy: "_")
        
        // Safety check - should never fail but it's safer to check
        guard components.count >= 3 else { return }
        
        // Extract the first components, make sure it's "schedule", otherwise, return immediately
        guard components[0] == "schedule" else { return }

        // Extract the schedule.identifier
        let scheduleId = components[1]
        
        // Define the predicate for the Core Data fetch request
        let predicate = NSPredicate(format: "identifier == %@", scheduleId)

        // Fetch the ScheduleEntity from Core Data
        let schedules = CoreDataStack.shared.fetchEntities(
            for: ScheduleEntity.self,
            predicate: predicate,
            fetchLimit: 1
        )
                
        // Ensure a valid schedule was fetched, otherwise send notification for debugging
        guard let schedule = schedules.first else {
            sendErrorNotification(
                title: "Error: Schedule Not Found",
                body: "Schedule with identifier '\(scheduleId)' not found in CoreData"
            )
            return
        }
        
        // Check if today is an active day
        // Note: schedule.activeDays is a string : "monday_tuesday_etc..."
        guard let activeDaysString = schedule.activeDays else {
            sendErrorNotification(
                title: "Error: No Active Days",
                body: "Schedule '\(scheduleId)' has no activeDays set"
            )
            return
        }
        let activeDays = activeDaysString.components(separatedBy: "_")
        let today = Date.now.weekday
        
        guard activeDays.contains(today) else {
            // DEBUG
//            sendErrorNotification(
//                title: "Error: Schedule: \(schedule.name ?? "unknown")",
//                body: "Active days does not contains today: \(today)"
//            )
            return
        }
        
        guard let selectionKey = schedule.selectionKey else {
            sendErrorNotification(
                title: "Error: No Selection Key",
                body: "Schedule '\(scheduleId)' has no selectionKey"
            )
            return
        }
        
        guard let familyActivitySelection = UserDefaultsManager.shared.get(forKey: selectionKey, as: FamilyActivitySelection.self) else {
            sendErrorNotification(
                title: "Error: Selection Not Found",
                body: "FamilyActivitySelection with key '\(selectionKey)' not found"
            )
            return
        }
        
        scheduleStore.shield.applications = familyActivitySelection.applicationTokens
        
        // Set shield
        let mirror = ScheduleMirror(
            name: schedule.name ?? "",
            emoji: schedule.icon ?? "",
            startTime: schedule.startTime ?? .now,
            endTime: schedule.endTime ?? .now
        )
        UserDefaultsManager.shared.set(mirror, forKey: "schedule_mirror_shield")
    }
    
    // MARK: - handleIntervalDidEnd
    /// Handles the end interval state for a given `DeviceActivityName`
    ///
    /// - Parameter activity: The `DeviceActivityName` containing activity information, where the second component of its raw value is used to identify the associated `ScheduleEntity`.
    private func handleIntervalDidEnd(for activity: DeviceActivityName) {
        
        let components = activity.rawValue.components(separatedBy: "_")
        
        guard components.count >= 2 else { return }
        
        if components[0] == "focus" {
            // Clear the settings for the focus session
            focusStore.clearAllSettings()
            UserDefaultsManager.shared.set(false, forKey: "is_focus_active")
            return
        }
        
        // Split the activity in order to find:
        // $0 -> "schedule"
        // $1 -> schedule.identifier
        // $2 -> UUID()
        // Safety check - should never fail but it's safer to check
        guard components.count >= 3 else { return }
        
        // Extract the first components, make sure it's "schedule", otherwise, return immediately
        guard components[0] == "schedule" else { return }

        // This is safe because the UI/logic prevents any schedule overlap
        scheduleStore.clearAllSettings()
    }
    
    /// Sends a debug notification with error information
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification body describing the error
    private func sendErrorNotification(title: String, body: String) {
        Task {
            let notification = LocalNotification(
                identifier: UUID().uuidString,
                title: title,
                body: body,
                timeInterval: 0.1,
                repeats: false
            )
            await LocalNotificationManager.shared.schedule(localNotification: notification)
        }
    }
}

