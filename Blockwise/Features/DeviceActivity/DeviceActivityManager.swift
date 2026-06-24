//
//  DeviceActivityManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import SwiftUI
import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

/// A singleton manager for handling device activity monitoring and settings.
///
/// This class manages the `DeviceActivityCenter` and `ManagedSettingsStore` to control
/// device activity shields and related settings.
final class DeviceActivityManager {
    static let shared = DeviceActivityManager()
    private init() {}
        
    // The center responsible for device activity monitoring.
    let center = DeviceActivityCenter()
    
    // The store for managing settings related to device activity.
    let store = ManagedSettingsStore()
    
    // The store for managing settings related to device activity schedules.
    let scheduleStore = ManagedSettingsStore(named: .init("schedule_store"))
    
    // The store for managing settings related to focus session.
    let focusStore = ManagedSettingsStore(named: .init("focus_store"))

}

extension DeviceActivityManager {
    func isActivityMonitored(name: DeviceActivityName) -> Bool {
        center.activities.contains(name)
    }
    
    func stopMonitoringActivity(named deviceActivity: DeviceActivityName) {
        center.stopMonitoring([deviceActivity])
    }
}

extension DeviceActivityManager {
    func deactivateAllBlocks(_ blocks: FetchedResults<BlockEntity>) {
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ DEACTIVATE ALL BLOCKS - START")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("")
        
        Logger.debug("📊 Total blocks to deactivate: \(blocks.count)")
        Logger.debug("")
        
        guard !blocks.isEmpty else {
            Logger.debug("ℹ️  No blocks to deactivate")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        var successCount = 0
        var skipCount = 0
        
        for (index, block) in blocks.enumerated() {
            let blockIdentifier = block.identifier ?? "unknown"
            Logger.debug("Block \(index + 1)/\(blocks.count): \(blockIdentifier)")
            
            guard let appTokenString = block.appTokenString else {
                Logger.debug("   ⏭️  Skipped: No appTokenString")
                Logger.debug("")
                skipCount += 1
                continue
            }
            
            guard let appToken = ApplicationToken.fromRawValue(appTokenString) else {
                Logger.debug("   ⏭️  Skipped: Invalid appToken")
                Logger.debug("")
                skipCount += 1
                continue
            }
            
            removeFromShield(appToken: appToken)
            block.isDeactivated = true
            
            Logger.debug("   ✅ Shield removed")
            Logger.debug("   └─ isDeactivated: true")
            Logger.debug("")
            successCount += 1
        }
        
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("SUMMARY")
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("   ├─ Total: \(blocks.count)")
        Logger.debug("   ├─ Deactivated: \(successCount)")
        Logger.debug("   └─ Skipped: \(skipCount)")
        Logger.debug("")
        
        Logger.debug("💾 Saving Core Data context...")
        
        do {
            try CoreDataStack.shared.saveContext()
            Logger.debug("✅ Core Data context saved successfully")
        } catch {
            Logger.error("❌ ERROR: Failed to save after deactivating blocks")
            Logger.error("   └─ Error: \(error.localizedDescription)")
        }
        Logger.debug("")
        
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ DEACTIVATE ALL BLOCKS - COMPLETE ✅")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
    }
    
    func activateAllBlocks(_ blocks: FetchedResults<BlockEntity>) {
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ ACTIVATE ALL BLOCKS - START")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("")
        
        Logger.debug("📊 Total blocks to activate: \(blocks.count)")
        Logger.debug("")
        
        guard !blocks.isEmpty else {
            Logger.debug("ℹ️  No blocks to activate")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        var successCount = 0
        var skipCount = 0
        var alreadyOpenCount = 0
        
        for (index, block) in blocks.enumerated() {
            let blockIdentifier = block.identifier ?? "unknown"
            Logger.debug("Block \(index + 1)/\(blocks.count): \(blockIdentifier)")
            
            guard let appTokenString = block.appTokenString else {
                Logger.debug("   ⏭️  Skipped: No appTokenString")
                Logger.debug("")
                skipCount += 1
                continue
            }
            
            guard let appToken = ApplicationToken.fromRawValue(appTokenString) else {
                Logger.debug("   ⏭️  Skipped: Invalid appToken")
                Logger.debug("")
                skipCount += 1
                continue
            }
            
            if !block.isOpen, !block.isOpenForToday {
                addToShield(appToken: appToken)
                Logger.debug("   ✅ Shield applied")
                Logger.debug("   └─ isDeactivated: false")
                Logger.debug("")
                successCount += 1
            } else {
                Logger.debug("   ⏭️  Skipped: Block is currently open")
                Logger.debug("")
                alreadyOpenCount += 1
            }
            
            block.isDeactivated = false
        }
        
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("SUMMARY")
        Logger.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Logger.debug("   ├─ Total: \(blocks.count)")
        Logger.debug("   ├─ Activated: \(successCount)")
        Logger.debug("   ├─ Already open: \(alreadyOpenCount)")
        Logger.debug("   └─ Skipped: \(skipCount)")
        Logger.debug("")
        
        Logger.debug("💾 Saving Core Data context...")
        
        do {
            try CoreDataStack.shared.saveContext()
            Logger.debug("✅ Core Data context saved successfully")
        } catch {
            Logger.error("❌ ERROR: Failed to save after activating blocks")
            Logger.error("   └─ Error: \(error.localizedDescription)")
        }
        Logger.debug("")
        
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ ACTIVATE ALL BLOCKS - COMPLETE ✅")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
    }
    
    func deactivateAllSchedules(_ schedules: FetchedResults<ScheduleEntity>) {
        for schedule in schedules {
            guard let id = schedule.identifier else {
                Logger.error("❌ ERROR: Failed to find ID for schedule")
                return
            }
            
            if let activity = center.activities.first(where: { $0.rawValue.components(separatedBy: "_")[1] == id }) {
                // Activity found
                stopMonitoringActivity(named: activity)
            }
        }
    }
    
    func activateAllSchedules(_ schedules: FetchedResults<ScheduleEntity>) throws {
        for schedule in schedules {
            guard let id = schedule.identifier else {
                Logger.error("❌ ERROR: Failed to find ID for schedule")
                return
            }
            
            guard let startTime = schedule.startTime, let endTime = schedule.endTime else {
                return
            }
            
            guard let days = schedule.activeDays else {
                return
            }
            
            try DeviceActivityManager.shared.schedule(
                days: Weekday.fromString(days),
                startTime: startTime,
                endTime: endTime,
                id: id
            )
        }
    }
}

extension DeviceActivityManager {
    func isCurrentlyShielded(token appToken: ApplicationToken?) -> Bool {
        if let appToken {
            return store.shield.applications?.contains(appToken) ?? false
        } else {
            return false
        }
    }
    
    func restoreShield(appToken: ApplicationToken) {
        addToShield(appToken: appToken)
        Logger.success("Shield Restored.")
    }
    
    // As long as this function returns FALSE, everything is fine.
    func shouldBeShielded(blockEntity: BlockEntity, appToken: ApplicationToken?) -> Bool {
        guard let appToken else {
            Logger.error("Could not find appToken")
            return true
        }
        
        if let lastRecord = blockEntity.records.last, let timestamp = lastRecord.timestamp {
            let endTime = timestamp.addingTimeInterval(lastRecord.duration)
            
            Logger.debug("------------------------------------------------------")
            
            Logger.debug("End Time: \(endTime.localTimeZone)")
            Logger.debug("Now: \(Date().localTimeZone)")
            
            Logger.debug("EndTime < Now: \(endTime < Date())")
            
            Logger.debug("------------------------------------------------------")
            
            // If the endTime has passed, the shield should be locked.
            if endTime < Date() {
                // check if the shield is correctly locked.
                let isLocked = isCurrentlyShielded(token: appToken)
                
                if isLocked {
                    Logger.debug("App is currently locked as it should be.")
                    return false
                } else {
                    Logger.debug("App is currently NOT locked while it should be.")
                    return true
                }
            }
        }
        
        // It will return false if no record is found,
        // meaning the app has never been opened through BLOCKR.
        Logger.debug("Returning from shouldBeShielded(...) as no record was found.")
        return false
    }
    
    // Prefer Set<ApplicationToken> to match usage elsewhere
    func blockAllApps(except: Set<ApplicationToken>, blocks: FetchedResults<BlockEntity>) {
        deactivateAllBlocks(blocks)
        store.shield.applicationCategories = .all(except: except)
    }
    
    func unblockAllApps(blocks: FetchedResults<BlockEntity>) {
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy<Application>.none
        activateAllBlocks(blocks)
    }
}

extension DeviceActivityManager {
    // Schedules
    func schedule(days: [Weekday], startTime: Date, endTime: Date, id: String) throws {
        let calendar = Calendar.current
        
        let intervalStart = calendar.dateComponents([.hour, .minute], from: startTime)
        let intervalEnd = calendar.dateComponents([.hour, .minute], from: endTime)

        let newSchedule = DeviceActivitySchedule(
            intervalStart: intervalStart,
            intervalEnd: intervalEnd,
            repeats: true,
            warningTime: nil
        )
        
        // This ID will be linked to the ScheduleEntity
        let scheduleActivityName = DeviceActivityName("schedule_\(id)_\(UUID())")
        
        do {
            try center.startMonitoring(scheduleActivityName, during: newSchedule)
        } catch {
            Logger.error(error.localizedDescription)
            throw SimpleError.message(error.localizedDescription)
        }
    }
    
    // For specific app
    func startFocusSession(for duration: TimeInterval, selection: FamilyActivitySelection) throws {
        // Apply to the shield in this func
        // We are only interested in intervalDidEnd, we don't need the start if we apply the block now manually

        let calendar = Calendar.current
        let endTime = Date.now.addingTimeInterval(duration)
        
        let intervalStart = calendar.dateComponents([.hour, .minute], from: .now)
        let intervalEnd = calendar.dateComponents([.hour, .minute], from: endTime)

        let newSchedule = DeviceActivitySchedule(
            intervalStart: intervalStart,
            intervalEnd: intervalEnd,
            repeats: false,
            warningTime: nil
        )

        let scheduleActivityName = DeviceActivityName("focus_\(UUID())")
        
        do {
            try center.startMonitoring(scheduleActivityName, during: newSchedule)
            
            // Apply shield to specific store
            focusStore.shield.applications = selection.applicationTokens
        } catch {
            Logger.error(error.localizedDescription)
            throw SimpleError.message(error.localizedDescription)
        }
    }
    
    // For all apps with exceptions
    func startFocusSession(for duration: TimeInterval, exceptions: FamilyActivitySelection) throws {
        // Apply to the shield in this func
        // We are only interested in intervalDidEnd, we don't need the start if we apply the block now manually

        let calendar = Calendar.current
        let endTime = Date.now.addingTimeInterval(duration)
        
        let intervalStart = calendar.dateComponents([.hour, .minute], from: .now)
        let intervalEnd = calendar.dateComponents([.hour, .minute], from: endTime)

        let newSchedule = DeviceActivitySchedule(
            intervalStart: intervalStart,
            intervalEnd: intervalEnd,
            repeats: false,
            warningTime: nil
        )

        let scheduleActivityName = DeviceActivityName("focus_\(UUID())")
        
        do {
            try center.startMonitoring(scheduleActivityName, during: newSchedule)
            
            // Apply shield to specific store
            focusStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: exceptions.applicationTokens)
        } catch {
            Logger.error(error.localizedDescription)
            throw SimpleError.message(error.localizedDescription)
        }
    }

}

// MARK: - Schedule helper
struct ScheduleMirror: Identifiable, Codable {
    let id = UUID()
    
    let name: String
    let emoji: String
    let startTime: Date
    let endTime: Date
}

