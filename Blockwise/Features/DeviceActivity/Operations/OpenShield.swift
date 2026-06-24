//
//  OpenShield.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import SwiftUI
import ManagedSettings
import DeviceActivity

extension DeviceActivityManager {
    func `open`(blockId: String, appToken: ApplicationToken, for duration: TimeInterval) async throws {
        Logger.debug("----------------------------------------------------------")
        
        guard !blockId.isEmpty else {
            Logger.error("Could not find identifier")
            return
        }

        let calendar = Calendar.current
        let currentTime = Date.now
        
        // Calculate the duration in minutes and set a minimum of 20 minutes if necessary
        let durationAsMinutes = duration / 60
        let minutesToAdd = max(20, durationAsMinutes + 1) // Minimum duration is 20 minutes
        let endTime = currentTime.addingTimeInterval(minutesToAdd * 60)
        
        let components: Set<Calendar.Component> = [
            .calendar, .timeZone,
            .era, .year, .month, .day,
            .hour, .minute, .second, .weekday
        ]

        var startComponents = calendar.dateComponents(components, from: currentTime)
        var endComponents = calendar.dateComponents(components, from: endTime)
        
        startComponents.timeZone = calendar.timeZone
        endComponents.timeZone = calendar.timeZone
        
        let warningTime = DateComponents(minute: Int(minutesToAdd - durationAsMinutes), second: 0)
        
        Logger.debug("Unlocking shield for duration: \(duration)")
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current // or explicitly set to your desired timezone

        Logger.debug("⏰ Current Time: \(formatter.string(from: currentTime))")
        Logger.debug("⏭️ End Time: \(formatter.string(from: endTime))")
        Logger.debug("Warning Time: \(warningTime)")
        
        // Create and start the activity schedule
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false,
            warningTime: warningTime
        )
        
        let activityName = DeviceActivityName("\(blockId)_\(UUID())")
        Logger.debug("DeviceActivityName: \(activityName)")
        
        do {
            try center.startMonitoring(activityName, during: schedule)
        } catch {
            Logger.error("Shield unlock failed with error: \(error.localizedDescription)")
            throw URLError(.badURL)
        }
        
        removeFromShield(appToken: appToken)
        
        Logger.debug("----------------------------------------------------------")
    }

}
