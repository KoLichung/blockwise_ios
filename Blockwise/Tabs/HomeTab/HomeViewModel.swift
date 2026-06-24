//
//  HomeViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI
import ManagedSettings
import DeviceActivity
import AlarmKit
import ActivityKit

struct SelectedDate: Identifiable {
    let id = UUID()
    let date: Date
}

final class HomeViewModel: ObservableObject {
    @Published var selectedBlock: BlockEntity?
    @Published var selectedDate: SelectedDate?
    
    @Published var showStreakView: Bool = false
    @Published var showCreateView: Bool = false

    // MARK: Functions
    func handleSceneUpdated(block: BlockEntity, oldValue: ScenePhase, newValue: ScenePhase) {
        guard block.isOpen else {
            Logger.debug("Block is not open, skip scene updates")
            return
        }
        
        guard (oldValue == .inactive || oldValue == .background) && newValue == .active else { return }
        
        // Force close to update UI
        if let endTime = block.openEndTime, endTime <= Date.now {
            block.isOpen = false
            block.openEndTime = nil
            
            do {
                try CoreDataStack.shared.saveContext()
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    func restoreBlock(block: BlockEntity, token: ApplicationToken) {
        block.isOpen = false
        block.isOpenForToday = false
        block.openEndTime = nil
        DeviceActivityManager.shared.restoreShield(appToken: token)
    }
    
    func closeEarly(block: BlockEntity, token: ApplicationToken) {
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ CLOSE EARLY - START")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("")

        // ─────────────────────────────────────────────────────────────────────
        // STEP 1: Find Last Record
        // ─────────────────────────────────────────────────────────────────────
        
        let sortedRecords = block.records.sorted {
            ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast)
        }
        
        Logger.debug("📊 Total records found: \(sortedRecords.count)")
        Logger.debug("")
        
        guard let lastRecord = sortedRecords.last else {
            Logger.error("❌ ERROR: Could not find most recent record")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        Logger.debug("✅ Last record found")
        Logger.debug("   └─ Duration: \(lastRecord.duration.formattedDuration())")
        Logger.debug("   └─ Timestamp: \(String(describing: lastRecord.timestamp?.localTimeZone))")
        Logger.debug("   └─ Cross Day: \(lastRecord.crossDay)")
        Logger.debug("")
        
        let previousRecord = sortedRecords.dropLast().last
        if let previousRecord = previousRecord {
            Logger.debug("✅ Previous record found")
            Logger.debug("   └─ Duration: \(previousRecord.duration.formattedDuration())")
            Logger.debug("   └─ Cross Day: \(previousRecord.crossDay)")
        } else {
            Logger.debug("ℹ️  No previous record exists")
        }
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 2: Calculate Total Unlock Duration
        // ─────────────────────────────────────────────────────────────────────
        
        var totalUnlockDuration: TimeInterval = 0
        
        if lastRecord.crossDay == true && previousRecord?.crossDay == true {
            totalUnlockDuration = lastRecord.duration + (previousRecord?.duration ?? 0)
            Logger.debug("🌙 MIDNIGHT CROSSING DETECTED")
            Logger.debug("   ├─ Last record duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   ├─ Previous record duration: \((previousRecord?.duration ?? 0).formattedDuration())")
            Logger.debug("   └─ Total unlock duration: \(totalUnlockDuration.formattedDuration())")
        } else {
            totalUnlockDuration = lastRecord.duration
            Logger.debug("☀️ NO MIDNIGHT CROSSING")
            Logger.debug("   └─ Total unlock duration: \(totalUnlockDuration.formattedDuration())")
        }
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 3: Validate Block Data
        // ─────────────────────────────────────────────────────────────────────
        
        guard let startTime = block.openStartTime else {
            Logger.error("❌ ERROR: Block openStartTime is nil")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        guard let identifier = block.identifier else {
            Logger.error("❌ ERROR: Block identifier is nil")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        Logger.debug("✅ Block validation passed")
        Logger.debug("   ├─ Identifier: \(identifier)")
        Logger.debug("   └─ Start time: \(startTime.localTimeZone)")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 4: Apply Shield Manually
        // ─────────────────────────────────────────────────────────────────────
        
        DeviceActivityManager.shared.addToShield(appToken: token)
        Logger.debug("🛡️  Shield manually applied to application")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 5: Stop Device Activity Monitoring
        // ─────────────────────────────────────────────────────────────────────
        
        let activities: [DeviceActivityName] = DeviceActivityManager.shared.center.activities
        Logger.debug("🔍 Searching for matching activity to stop...")
        Logger.debug("   └─ Total active activities: \(activities.count)")
        Logger.debug("")
        
        for activity in activities {
            let components = activity.rawValue.components(separatedBy: "_")
            
            guard components.count >= 2 else {
                Logger.debug("   ⚠️  Skipping malformed activity: \(activity.rawValue)")
                continue
            }

            let blockId = components[0]
            
            if blockId == identifier {
                Logger.debug("   ✅ Match found: \(activity.rawValue)")
                DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
                Logger.debug("   └─ Activity monitoring stopped")
            } else {
                Logger.debug("   ⏭️  No match: \(activity.rawValue)")
            }
        }
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 6: Stop Live Activity & Notifications
        // ─────────────────────────────────────────────────────────────────────
        
        stopLiveActivity(block: block)
        Logger.debug("🔕 Live activity and notifications stopped")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 7: Calculate New Duration
        // ─────────────────────────────────────────────────────────────────────
        
        let distance = startTime.distance(to: Date.now)
        let newDuration = distance.roundedToNearestMinute()
        
        Logger.debug("⏱️  DURATION CALCULATIONS")
        Logger.debug("   ├─ Start time: \(startTime.localTimeZone)")
        Logger.debug("   ├─ End time: \(Date.now.localTimeZone)")
        Logger.debug("   ├─ Actual distance: \(distance.formattedDuration())")
        Logger.debug("   ├─ Rounded distance: \(newDuration.formattedDuration())")
        Logger.debug("   └─ Total unlock duration: \(totalUnlockDuration.formattedDuration())")
        Logger.debug("")
        
        let discardedDuration = totalUnlockDuration - newDuration
        let discardedDurationForRecharge = totalUnlockDuration - distance
        
        Logger.debug("🗑️  DISCARDED TIME")
        Logger.debug("   ├─ For records: \(discardedDuration.formattedDuration())")
        Logger.debug("   └─ For recharge: \(discardedDurationForRecharge.formattedDuration())")
        Logger.debug("")
        
        Logger.debug("🧮 VALIDATION CHECK")
        Logger.debug("   └─ Last duration - discarded: \((lastRecord.duration - discardedDuration).formattedDuration())")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 8: Update Records Based on Scenario
        // ─────────────────────────────────────────────────────────────────────
        
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("RECORD UPDATE LOGIC")
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("")
        
        if lastRecord.crossDay == true, lastRecord.duration - discardedDuration <= 0 {
            
            Logger.debug("📍 SCENARIO A: Midnight crossing + discarded duration exceeds last record")
            Logger.debug("")
            
            guard let previousRecord else {
                Logger.error("❌ ERROR: No previous record found (expected for midnight crossing)")
                Logger.debug("═════════════════════════════════════════════════════════════════════")
                return
            }
            
            let timeToRemoveToPreviousRecord: TimeInterval = abs(lastRecord.duration - discardedDuration)
            
            Logger.debug("   ├─ Last record duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   ├─ Discarded duration: \(discardedDuration.formattedDuration())")
            Logger.debug("   ├─ Overflow to remove: \(timeToRemoveToPreviousRecord.formattedDuration())")
            Logger.debug("   ├─ Previous record OLD duration: \(previousRecord.duration.formattedDuration())")
            Logger.debug("")
            
            previousRecord.duration -= timeToRemoveToPreviousRecord
            
            Logger.debug("   ├─ Previous record NEW duration: \(previousRecord.duration.formattedDuration())")
            Logger.debug("   ├─ ❌ Deleting last record (0 usage)")
            Logger.debug("   └─ 📉 Decrementing tomorrow's open count")
            Logger.debug("")
            
            try? CoreDataStack.shared.delete(lastRecord)
            
            UserDefaultsManager.shared.decrementOpenCount(for: token, on: .tomorrow)
            UserDefaultsManager.shared.addTimeUsed(for: token, duration: -timeToRemoveToPreviousRecord, on: .now)

        } else if lastRecord.crossDay == true {
            
            Logger.debug("📍 SCENARIO B: Midnight crossing + discarded duration within last record")
            Logger.debug("")
            
            guard let previousRecord else {
                Logger.error("❌ ERROR: No previous record found (expected for midnight crossing)")
                Logger.debug("")
                Logger.debug("═════════════════════════════════════════════════════════════════════")
                return
            }
            
            let durationToRemove: TimeInterval = abs(newDuration - previousRecord.duration)
            
            Logger.debug("   ├─ Last record OLD duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   ├─ Duration to remove: \(durationToRemove.formattedDuration())")
            Logger.debug("")
            
            lastRecord.duration -= durationToRemove
            
            Logger.debug("   ├─ Last record NEW duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   └─ 📉 Updating time used for today")
            Logger.debug("")
            
            UserDefaultsManager.shared.addTimeUsed(for: token, duration: -durationToRemove, on: .now)
            
        } else {
            
            Logger.debug("📍 SCENARIO C: No midnight crossing")
            Logger.debug("")
            
            let durationToRemove: TimeInterval = abs(newDuration - lastRecord.duration)
            
            Logger.debug("   ├─ Last record OLD duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   ├─ New duration: \(newDuration.formattedDuration())")
            Logger.debug("   ├─ Duration to remove: \(durationToRemove.formattedDuration())")
            Logger.debug("")
            
            lastRecord.duration = newDuration
            
            Logger.debug("   ├─ Last record NEW duration: \(lastRecord.duration.formattedDuration())")
            Logger.debug("   └─ 📉 Updating time used for today")
            Logger.debug("")
            
            UserDefaultsManager.shared.addTimeUsed(for: token, duration: -durationToRemove, on: .now)
            
            if durationToRemove >= 60 {
                Logger.debug("   └─ ⚠️  Duration removed >= 60s, resetting limit reached flag")
                Logger.debug("")
                UserDefaultsManager.shared.setLimitReached(value: false)
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // STEP 9: Update Block Entity
        // ─────────────────────────────────────────────────────────────────────
        
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("BLOCK ENTITY UPDATE")
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("")
        
        block.isOpen = false
        block.isOpenForToday = false
        block.openEndTime = nil
        
        Logger.debug("✅ Block flags updated")
        Logger.debug("   ├─ isOpen: false")
        Logger.debug("   ├─ isOpenForToday: false")
        Logger.debug("   └─ openEndTime: nil")
        Logger.debug("")
        
        if block.cooldown > 0 {
            Logger.debug("❄️  COOLDOWN ACTIVE (\(block.cooldown.formattedDuration()))")
            Logger.debug("")
            
            let newNextAvailableDate = block.nextAvailableDate?.addingTimeInterval(-discardedDurationForRecharge)
            
            Logger.debug("   ├─ Old next available: \(String(describing: block.nextAvailableDate?.localTimeZone))")
            Logger.debug("   ├─ Time refunded: \(discardedDurationForRecharge.formattedDuration())")
            Logger.debug("   └─ New next available: \(String(describing: newNextAvailableDate?.localTimeZone))")
            Logger.debug("")

            if let newNextAvailableDate = newNextAvailableDate {
                let distance = newNextAvailableDate.timeIntervalSinceNow
                let isInFuture = distance > 0
                let minutes = Int(abs(distance) / 60)
                let seconds = Int(abs(distance).truncatingRemainder(dividingBy: 60))
                
                Logger.debug("   🕐 TIME UNTIL AVAILABLE")
                Logger.debug("      ├─ Status: \(isInFuture ? "🔒 In Future" : "✅ Available Now")")
                Logger.debug("      ├─ Distance: \(isInFuture ? "+" : "-")\(minutes)m \(seconds)s")
                Logger.debug("      └─ Raw seconds: \(distance)s")
                Logger.debug("")
            }
            
            UserDefaultsManager.shared.setNextAvailability(for: token, date: newNextAvailableDate ?? .now)
            block.nextAvailableDate = newNextAvailableDate
            
            Logger.debug("   ✅ Next availability updated in UserDefaults & CoreData")
            Logger.debug("")
        } else {
            Logger.debug("ℹ️  No cooldown configured (cooldown = 0)")
            Logger.debug("")
        }
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 10: Save Core Data Context
        // ─────────────────────────────────────────────────────────────────────
        
        do {
            try CoreDataStack.shared.saveContext()
            Logger.debug("✅ Core Data context saved successfully")
        } catch {
            Logger.error("❌ ERROR saving Core Data context: \(error.localizedDescription)")
        }
        Logger.debug("")
                
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ CLOSE EARLY - COMPLETE ✅")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
    }
    private func stopLiveActivity(block: BlockEntity) {
        Logger.debug("---------------------------------------------------------------------")
        Logger.debug("→ Entering 'stopLiveActivity' function")
        Logger.debug("")

        guard let identifier = block.identifier else {
            Logger.error("→ Leaving 'stopLiveActivity' function, we couldn't find block identifier")
            Logger.debug("---------------------------------------------------------------------")
            return
        }
        
        if #available(iOS 26.0, *) {
            do {
                let alarms = try AlarmManager.shared.alarms
                
                for alarm in alarms {
                    if alarm.id.uuidString == identifier {
                        Logger.debug("✅ Found matching alarm for identifier: \(identifier)")
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
        
        Logger.debug("Done")
        Logger.debug("---------------------------------------------------------------------")
    }
}
