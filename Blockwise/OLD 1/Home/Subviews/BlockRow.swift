//
//  BlockRow.swift
//  Blockwise
//
//  Created by Ivan Sanna on 05/08/25.
//

import SwiftUI
import ManagedSettings
import DeviceActivity
import ActivityKit
import AlarmKit

struct BlockRow: View {
    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var toastManager: ToastManager
    
    let block: BlockEntity
    let totalUsageToday: TimeInterval
    
    var todaysRecords: [RecordEntity] { block.records.filtered(by: .now) }
    var todaysOpens: Int { todaysRecords.count }
    var todaysUsage: TimeInterval { todaysRecords.reduce(.zero) { $0 + $1.duration } }
    var progressToTotalUsage: CGFloat { totalUsageToday == 0 ? 0 : min(1, max(todaysUsage / totalUsageToday, 0)) }
    
    var appToken: ApplicationToken? {
        ApplicationToken.fromRawValue(block.appTokenString ?? "")
    }
    
    var isShieldApplied: Bool { DeviceActivityManager.shared.isCurrentlyShielded(token: appToken) }
    
//    var isProblematic: Bool {
//        Logger.debug("---------------------------------------------------------------")
//        
//        guard let endTime = block.openEndTime else {
//            Logger.error("End Time not found in isProblematic")
//            return false
//        }
//        Logger.debug("Is Shield Applied: \(isShieldApplied)")
//        Logger.debug("EndTime: \(endTime.localTimeZone)")
//        Logger.debug("Now: \(Date.now.localTimeZone)")
//        Logger.debug("Calculation:")
//        Logger.debug("!isShieldApplied: \(!isShieldApplied)")
//        Logger.debug("endTime < Date.now: \(endTime < Date.now)")
//        Logger.debug("Result: \(!isShieldApplied && endTime < Date.now)")
//        Logger.debug("---------------------------------------------------------------")
//        return !isShieldApplied && endTime < Date.now
//    }
    
    var isAppOpen: Bool {
        if let endTime = block.openEndTime {
            return Date.now <= endTime
        }
        return false
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                if let tokenString = block.appTokenString, let appToken = ApplicationToken.fromRawValue(tokenString) {
                    AppTokenRow(token: appToken)
                } else {
                    Text("Unable to find blocked app.")
                }
            }
            
//            ZStack(alignment: .leading) {
//                Text("\(openFeedback(opens: todaysOpens))")
//                    .foregroundStyle(.textC.opacity(0.5))
//                    .opacity(isAppOpen ? 0 : 1)
//                
//                if let endTime = block.openEndTime, Date.now <= endTime {
//                    Group {
//                        Text("Closes in ") +
//                        Text(timerInterval: Date.now...endTime) +
//                        Text("s")
//                    }
//                    .foregroundStyle(.orange)
//                    .opacity(isAppOpen ? 1 : 0)
//                }
//            }
//            .font(.grotesk(.footnote, weight: .medium))
//            .padding(.leading, 14 + 40)
            
            if let endTime = block.openEndTime, Date.now <= endTime {
                Button {
                    closeEarly()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .frame(height: 40)
                        .overlay {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.subheadline.weight(.medium))
                                
                                Text("Close Now")
                            }
                            .font(.grotesk(.body, weight: .semibold))
                            .foregroundStyle(.secondary)
                        }
                }
                .padding(.leading, 14 + 40)
            }
            
//                    if isProblematic {
//                        Button {
//                            resolveError()
//                        } label: {
//                            RoundedRectangle(cornerRadius: 10)
//                                .foregroundStyle(.orange)
//                                .frame(height: 40)
//                                .opacity(0.15)
//                                .overlay {
//                                    Text("Resolve Now")
//                                        .font(.grotesk(.body, weight: .semibold))
//                                        .foregroundStyle(.orange)
//                                }
//                        }
//                        .padding(.leading, 14 + 40)
//                    }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(Theme.foregroundC)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            handleScenePhaseChange(oldValue, newValue)
        }

    }
    
    @ViewBuilder
    private func AppTokenRow(token appToken: ApplicationToken) -> some View {
        Label(appToken)
            .labelStyle(.iconOnly)
            .scaleEffect(2.0)
            .frame(square: 40)
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(appToken)
                    .labelStyle(.titleOnly)
                    .scaleEffect(0.9, anchor: .leading)
                
                Spacer()
                
                UsageData()
            }
            
            ZStack(alignment: .leading) {
                Text("\(openFeedback(opens: todaysOpens))")
                    .foregroundStyle(.textC.opacity(0.5))
                    .opacity(isAppOpen ? 0 : 1)
                
                if let endTime = block.openEndTime, Date.now <= endTime {
                    Group {
                        Text("Closes in ") +
                        Text(timerInterval: Date.now...endTime) +
                        Text("s")
                    }
                    .foregroundStyle(.orange)
                    .opacity(isAppOpen ? 1 : 0)
                }
            }
            .font(.grotesk(.footnote, weight: .medium))
        }
    }
    
    @ViewBuilder
    private func ProgressBar() -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.secondary.opacity(progressToTotalUsage == 0 ? 0.15 : 0.0))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: width * progressToTotalUsage)
                        .foregroundStyle(isAppOpen ? .orange : Color.blueAccent)
                }
        }
        .frame(height: 5)
    }
    
    @ViewBuilder
    private func UsageData() -> some View {
        Text(TimeFormatter.display(todaysUsage, style: .spaced))
            .font(.grotesk(.caption, weight: .regular))
            .foregroundStyle(.secondary)
    }
    
    func closeEarly() {
        Logger.debug("---------------------------------------------------------------------")
        
        let sortedRecords = block.records.sorted {
            ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast)
        }

        guard let lastRecord = sortedRecords.last else {
            Logger.error("Could not find most recent record")
            return
        }
        
        Logger.debug("Last Record Entity Object: \(lastRecord.duration)")

        let previousRecord = sortedRecords.dropLast().last
        
        Logger.debug("Previous Record Entity Object: \(String(describing: previousRecord?.duration))")

        var totalUnlockDuration: TimeInterval = 0
        
        // Check if it crossed midnight
        if lastRecord.crossDay == true && previousRecord?.crossDay == true {
            totalUnlockDuration = lastRecord.duration + (previousRecord?.duration ?? 0)
            Logger.debug("☾Record crossed midnight")
        } else {
            totalUnlockDuration = lastRecord.duration
            Logger.debug("☀️Record did not cross midnight")
        }

        guard let startTime = block.openStartTime else {
            Logger.error("Could not find openStartTime")
            return
        }
        
        guard let appToken else {
            Logger.error("Could not find appToken")
            return
        }
        
        guard let identifier = block.identifier else {
            Logger.error("Could not find identifier")
            return
        }
                
        // 1 - Put the shield back on manually
        DeviceActivityManager.shared.addToShield(appToken: appToken)
        
        Logger.debug("\n🛡️ [SHIELD] Added app to the Shield\n")
        
        // 2 - Make sure the DeviceActivityManager does not trigger
        let activities: [DeviceActivityName] = DeviceActivityManager.shared.center.activities
        for activity in activities {
            let components = activity.rawValue.components(separatedBy: "_")
            
            // Safety check - should never fail but it's safer to check
            guard components.count >= 2 else { return }

            // Extract the block.identifier
            let blockId = components[0]
            
            if blockId == identifier {
                Logger.debug("Identifier found")
                DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
            }
        }
        
        // 3 - End live activity / stop notifications
        endLiveActivityOrAlarm()
        
        // 4 - Update the records
        let distance = startTime.distance(to: Date.now)
        let newDuration = distance.roundedToNearestMinute()
        
        Logger.debug("⏱️ Total Unlock Duration duration = \(totalUnlockDuration.formattedDuration())\n")
        Logger.debug("⏱️ New duration = \(distance.formattedDuration())\n")
        Logger.debug("⏱️ New duration ROUNDED = \(newDuration.formattedDuration())\n")
        
        let discardedDuration = totalUnlockDuration - newDuration
        
        Logger.debug("😱 Discarded Duration: \(discardedDuration.formattedDuration())")
        
        Logger.debug("[CALCULATION] Last Duration - discardedDuration: \(lastRecord.duration - discardedDuration)")
        
        // If discardedDuration <= 0, it means that we are in front of a splitted record ( becuase of midnight )
        // if discardedDuration is greated than the entire duration of the splitted record, we delete that record, and remove the duration remaining from the previous record ( which will be the first half of the splitted record )
                
        if lastRecord.crossDay == true, lastRecord.duration - discardedDuration <= 0 {
            
            Logger.debug("Discarded duration was <= 0")
                        
            // If discarded duration is < 0 there should always be a previous record
            guard let previousRecord else {
                Logger.error("no previousRecord")
                return
            }
            
            let timeToRemoveToPreviousRecord: TimeInterval = abs(lastRecord.duration - discardedDuration)
                        
            // Update the previous record.
            previousRecord.duration -= timeToRemoveToPreviousRecord
            Logger.debug("Removed \(timeToRemoveToPreviousRecord.formattedDuration()) from previous record")
            
            // Delete the lastRecord.
            try? CoreDataStack.shared.delete(lastRecord) // because it has 0 usage
            Logger.debug("Deleting last record")
        } else if lastRecord.crossDay == true {
            Logger.debug("Discarded duration was > 0, but we still cross midnight")
            guard let previousRecord else {
                Logger.error("no previousRecord")
                return
            }
            let durationToRemove: TimeInterval = abs(newDuration - previousRecord.duration)
            
            lastRecord.duration -= durationToRemove
        } else {
            lastRecord.duration = newDuration
            Logger.debug("Assigning new duration to last record")
        }
        
        Logger.debug("New Duration is: \(newDuration.formattedDuration())")
        
//        // 4.5 - Update the time count for the Shield
//        let difference = newDuration - lastDuration // it should be a negative number
//        Logger.debug("Time difference: \(difference)")
//        UserDefaultsManager.shared.updateTimeUsed(forApplication: appToken, addDuration: difference)
        
        // 5 - Update blockEntity
        block.isOpen = false
        block.openEndTime = nil
        
        // 6 - Save changes
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            Logger.error(error.localizedDescription)
        }
        
        Haptics.feedback(style: .soft)
        
        Logger.debug("---------------------------------------------------------------------")
    }
    
    func resolveError() {
        guard let appToken else { return }
        DeviceActivityManager.shared.restoreShield(appToken: appToken)

        Haptics.successFeedback()
        toastManager.info("Shield Restored Successfully!")
    }
    
    func openFeedback(opens: Int) -> String {
        if opens < 1 {
            return "Never opened today"
        } else {
            return "Opened \(opens) times"
        }
    }
    
    private func handleScenePhaseChange(_ oldValue: ScenePhase, _ newValue: ScenePhase) {
        guard block.isOpen else {
            Logger.debug("Block is not open, skipping scene phase update")
            return
        }
        
        guard (oldValue == .inactive || oldValue == .background) && newValue == .active else {
            return
        }
        
        Logger.debug("🍩Updating scene phase")
        
        if let endTime = block.openEndTime, endTime < Date.now {
            pushClose()
            Logger.debug("👌Closing early")
        } else {
            Logger.debug("❌Could not find endTime")
        }

    }
    
    func pushClose() {
//        guard let lastRecord = block.records.max(by: { ($0.timestamp ?? Date.now) < ($1.timestamp ?? Date.now) }) else {
//            Logger.error("Could not find most recent record")
//            return
//        }
//        
//        guard let startTime = block.openStartTime else {
//            Logger.error("Could not find openStartTime")
//            return
//        }
//        
//        guard let appToken else {
//            Logger.error("Could not find appToken")
//            return
//        }
//        
//        guard let identifier = block.identifier else {
//            Logger.error("Could not find identifier")
//            return
//        }
        
//        let lastDuration: TimeInterval = lastRecord.duration
        
        // 1 - Put the shield back on manually
//        DeviceActivityManager.shared.addToShield(appToken: appToken)
        
        // 2 - Make sure the DeviceActivityManager does not trigger
//        let activities: [DeviceActivityName] = DeviceActivityManager.shared.center.activities
//        for activity in activities {
//            let components = activity.rawValue.components(separatedBy: "_")
//            
//            // Safety check - should never fail but it's safer to check
//            guard components.count >= 2 else { return }
//
//            // Extract the block.identifier
//            let blockId = components[0]
//            
//            if blockId == identifier {
//                Logger.debug("Identifier found")
//                
//                DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
//            }
//        }
        
        // 3 - End live activity / stop notifications
        
        // 4 - Update the records
//        let newDuration = startTime.distance(to: Date.now)
//        Logger.debug("Last Record: \(String(describing: lastRecord.timestamp?.localTimeZone))")
//        Logger.debug("Last Duration was: \(lastRecord.duration)")
//        
//        lastRecord.duration = newDuration
//        
//        Logger.debug("New Duration is: \(newDuration)")
//        
//        // 4.5 - Update the time count for the Shield
//        let difference = newDuration - lastDuration // it should be a negative number
//        Logger.debug("Time difference: \(difference)")
//        UserDefaultsManager.shared.updateTimeUsed(forApplication: appToken, addDuration: difference)
        
        // 3 - End live activity / stop notifications
        endLiveActivityOrAlarm()

        // 5 - Update blockEntity
        block.isOpen = false
        block.openEndTime = nil
        
        // 6 - Save changes
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            Logger.error(error.localizedDescription)
        }
        
//        Haptics.feedback(style: .soft)
    }

    private func endLiveActivityOrAlarm() {
        guard let identifier = block.identifier else {
            Logger.error("Could not find identifier")
            return
        }
        
        if #available(iOS 26.0, *) {
            do {
                let alarms = try AlarmManager.shared.alarms
                
                for alarm in alarms {
                    if alarm.id.uuidString == identifier {
                        Logger.debug("✅ Found matching alarm for identifier: \(identifier)")
                        // perform your cleanup logic here
                        try AlarmManager.shared.cancel(id: alarm.id)
                    }
                }
            } catch {
                Logger.error(error.localizedDescription)
            }
        }

        for activity in Activity<TimerAttributes>.activities {
            if activity.content.state.entityId == identifier {
                Task {
                    await activity.end(activity.content, dismissalPolicy: .immediate)
                }
            }
        }
    }

}

extension TimeInterval {
    /// Rounds to the nearest whole minute
    func roundedToNearestMinute() -> TimeInterval {
        let minutes = self / 60
        let roundedMinutes = minutes.rounded() // .toNearestOrAwayFromZero
        return roundedMinutes * 60
    }
}
