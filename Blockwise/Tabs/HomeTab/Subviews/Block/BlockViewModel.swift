//
//  BlockViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/02/26.
//

import SwiftUI
import ManagedSettings

final class BlockViewModel: ObservableObject {
    @Published var dismissAll: DismissAction?
    
    @Published var block: BlockEntity?
    
    @Published var showLinkAppView: Bool = false
    
    @Published var showButtonDelayPicker: Bool = false
    @Published var showMaxDurationPicker: Bool = false
    @Published var showRechargeTimePicker: Bool = false
    
    @Published var showButtonDelayInfo: Bool = false
    @Published var showMaxDurationInfo: Bool = false
    @Published var showRechargeTimeInfo: Bool = false
    
    @Published var inputButtonDelayValue: Double = 0.0
    @Published var inputMaxDurationValue: Double = 0.0
    @Published var inputRechargeTimeValue: Double = 0.0
    
    @Published var removeSuperLinkAlert: Bool = false
    @Published var showDeleteReason: Bool = false
    
    // Timer properties
    @Published var timeRemaining: Int = 60
    @Published var isButtonEnabled: Bool = false
    
    private var timer: Timer?  // Don't need @Published for this
    
    @Published var isLimitReached: Bool = UserDefaultsManager.shared.isLimitReached()
        
    func startTimer() {
        timeRemaining = 60
        isButtonEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.isButtonEnabled = true
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()  // Clean up when ViewModel is deallocated
    }

    func removeSuperlink() throws {
        guard let block else {
            throw SimpleError.message("Could not find block")
        }
        
        block.superlinkId = nil
        try CoreDataStack.shared.saveContext()
    }
    
    @MainActor
    func deletePermanently() throws {
        guard let block else {
            throw SimpleError.message("Could not find block")
        }
        
        guard let tokenString = block.appTokenString, let token = ApplicationToken.fromRawValue(tokenString) else {
            throw SimpleError.message("Could not create token")
        }

        // Remove app from the shield
        DeviceActivityManager.shared.removeFromShield(appToken: token)
        
        // If the shield is open, the DeviceMonitor will look for BlockEntity and not found it.
        // Therefore it's safe, we have nothing more to do to handle this case.
        
        // Delete CoreData object
        try CoreDataStack.shared.deleteBlock(block)
    }
    
    func openForAnHour() {
        
    }
    
    func openForToday() async throws {
        let now = Date.now
        let calendar = Calendar.current
        
        // Get end of today (23:59:59)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            return
        }
        
        // Calculate duration from now until end of day
        let duration = max(0, endOfDay.timeIntervalSince(now))
        
        try await unlock(duration: duration, fullDay: true)
    }
    
    private func unlock(duration: TimeInterval, fullDay: Bool) async throws {
        // Remove the shield and schedule auto close
        try await scheduleAutoClose(duration: duration)
        
        // Set states to CoreData
        try saveCoreData(duration: duration, fullDay: fullDay)
    }
    
    private func scheduleAutoClose(duration: TimeInterval) async throws {
        guard let block else {
            Logger.error("No block found")
            throw SimpleError.message("No block found: 3")
        }

        // Refetch it to avoid any issue
        guard let raw = block.appTokenString, let freshToken = ApplicationToken.fromRawValue(raw) else {
            Logger.error("No app token")
            throw SimpleError.message("No token found: 2")
        }
        
        guard let identifier = block.identifier else {
            Logger.error("No identifier found")
            throw SimpleError.message("No identifier found: 1")
        }
        
        try await DeviceActivityManager.shared.open(blockId: identifier, appToken: freshToken, for: duration)
    }
    
    private func saveCoreData(duration: TimeInterval, fullDay: Bool) throws {
        guard let block else {
            Logger.error("No block found")
            throw SimpleError.message("No block found: 4")
        }
        
        // Set open states
        if fullDay {
            block.isOpenForToday = true
        } else {
            block.isOpen = true
        }
        
        block.openStartTime = .now
        block.openEndTime = .now.addingTimeInterval(duration)
        
        if fullDay {
            block.openForTodayDate = .now
        }
        
        try CoreDataStack.shared.saveContext()
    }

}
