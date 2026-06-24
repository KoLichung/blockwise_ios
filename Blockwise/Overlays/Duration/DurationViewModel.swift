//
//  DurationViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/02/26.
//

import SwiftUI
import ManagedSettings
import AlarmKit

final class DurationViewModel: ObservableObject {
    @Published var token: ApplicationToken?
    @Published var block: BlockEntity?
    
    @Published var isLimit: Bool = false
    
    @Published var duration: Int = 5 // 5 minutes default
    
    // Timer properties
    @Published var timeRemaining: Int = 10
    @Published var isButtonEnabled: Bool = false
    
    private var timer: Timer?  // Don't need @Published for this
    
    // MARK: - Functions
    func loadBlock(blocks: FetchedResults<BlockEntity>) throws {
        // Step 1: Get the stored token from UserDefaults
        guard let storedToken = UserDefaultsManager.shared.loadAppToken() else {
            Logger.error("No app token")
            throw SimpleError.message("Something went wrong. We couldn't find your token.")
        }
        
        // Step 2: Find matching block from FetchedResults
        guard let matchingBlock = blocks.first(where: { $0.appTokenString == storedToken.string }) else {
            Logger.error("Block not found for token: \(storedToken.string ?? "nil")")
            throw SimpleError.message("Something went wrong. We couldn't find your block.")
        }

        // Step 3: Success, assign values
        token = storedToken
        block = matchingBlock
        Logger.debug("Successfully loaded token and block")
    }
    
    @MainActor
    func unlock(usage: TimeInterval, goal: TimeInterval) async throws {
        try await scheduleAutoClose()
        try saveCoreData()
        try await setAlarm()

        let interval = TimeInterval(duration * 60)
        if interval + usage >= goal {
            UserDefaultsManager.shared.setLimitReached(value: true)
            UserDefaultsManager.shared.set(goal, forKey: "screenTimeGoal")
        }

        UserDefaultsManager.shared.setToken(token: nil, value: false)
    }

    @MainActor
    func unlockLimitReached(breaksStreak: Bool) async throws {
        // Remove the shield and schedule auto close
        try await scheduleAutoClose()
        // Set states to CoreData
        try saveCoreDataLimitReached(breaksStreak: breaksStreak)
        
        // Set Live Activity + Alarm
        try await setAlarm()
                
        // Reset token
        UserDefaultsManager.shared.setToken(token: nil, value: false)
    }

    
    private func scheduleAutoClose() async throws {
        guard let block else {
            Logger.error("No block found")
            throw SimpleError.message("No block found: 3")
        }

        // Transform in seconds
        let interval = TimeInterval(duration * 60)

        // Refetch it to avoid any issue
        guard let raw = block.appTokenString, let freshToken = ApplicationToken.fromRawValue(raw) else {
            Logger.error("No app token")
            throw SimpleError.message("No token found: 2")
        }
        
        guard let identifier = block.identifier else {
            Logger.error("No identifier found")
            throw SimpleError.message("No identifier found: 1")
        }
        
        try await DeviceActivityManager.shared.open(blockId: identifier, appToken: freshToken, for: interval)
    }
    
    private func saveCoreData() throws {
        guard let block else {
            Logger.error("No block found")
            throw SimpleError.message("No block found: 4")
        }
        
        // Transform in seconds
        let interval = TimeInterval(duration * 60)

        // Create the record
        try CoreDataStack.shared.createRecord(
            for: block,
            duration: interval
        )
        
        // Set open states
        block.isOpen = true
        block.openStartTime = .now
        block.openEndTime = .now.addingTimeInterval(interval)
        
        // Update nextAvailableDate
        // *If there is a cooldown
        if block.cooldown > 0 {
            guard let token else { return }
            
            let nextAvailableDate: Date = .now.addingTimeInterval(block.cooldown + interval)
            block.nextAvailableDate = nextAvailableDate
            UserDefaultsManager.shared.setNextAvailability(for: token, date: nextAvailableDate)
        }
        
        try CoreDataStack.shared.saveContext()
    }
    
    private func saveCoreDataLimitReached(breaksStreak: Bool) throws {
        guard let block else {
            Logger.error("No block found")
            throw SimpleError.message("No block found: 4")
        }
        
        // Transform in seconds
        let interval = TimeInterval(duration * 60)

        if breaksStreak {
            // Create the record
            try CoreDataStack.shared.createRecord(
                for: block,
                duration: interval
            )
        }
        
        // Set open states
        block.isOpen = true
        block.openStartTime = .now
        block.openEndTime = .now.addingTimeInterval(interval)
        
        // Update nextAvailableDate
        // *If there is a cooldown
        if block.cooldown > 0 {
            guard let token else { return }
            
            let nextAvailableDate: Date = .now.addingTimeInterval(block.cooldown + interval)
            block.nextAvailableDate = nextAvailableDate
            UserDefaultsManager.shared.setNextAvailability(for: token, date: nextAvailableDate)
        }
        
        try CoreDataStack.shared.saveContext()
    }

    
    private func setAlarm() async throws {
        // Live Activity + Alarm
        if #available(iOS 26.0, *) {
            guard let block else {
                Logger.error("No block found")
                throw SimpleError.message("No block found: 5")
            }

            // Transform in seconds
            let interval = TimeInterval(duration * 60) - 1 // some delay

            guard let identifier = block.identifier else {
                Logger.error("No identifier found")
                throw SimpleError.message("No identifier found: 2")
            }
            
            // Transform to UUID
            guard let id = UUID(uuidString: identifier) else {
                Logger.error("Cannot create UUID")
                throw SimpleError.message("Cannot create UUID: 1")
            }

            // Countdown
            let alarmCountdown = Alarm.CountdownDuration(
                preAlert: interval,
                postAlert: nil
            )

            // Alert
            let alert = AlarmPresentation.Alert(
                title: "Time's up!",
                stopButton: .init(text: "Stop", textColor: .red, systemImageName: "xmark")
            )

            let countdownPresentation = AlarmPresentation.Countdown(title: "App open")
            
            // Presentation
            let presentation = AlarmPresentation(
                alert: alert,
                countdown: countdownPresentation
            )
            
            // Attributes
            /// AlarmAttributes requires the creation of a struct that conforms to the AlarmMetaData protocol.
            /// This will provide additional data to the Alarm UI for the LiveActivity and Dynamic Island, among other functionalitites.
            let attributes = AlarmAttributes<CountdownAttributes>(
                presentation: presentation,
                metadata: .init(),
                tintColor: .blue
            )
            
            // Configuration
            let config = AlarmManager.AlarmConfiguration(
                countdownDuration: alarmCountdown,
                attributes: attributes
            )
            
            // Add alarm to the System
            let _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
        }
    }
    
    // Timer functions
    func startTimer() {
        timeRemaining = Int(block?.buttonDelay ?? 0)
        
        guard timeRemaining > 0 else {
            isButtonEnabled = true
            return
        }
        
        isButtonEnabled = false

        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.isButtonEnabled = true
                self.stopTimer()
            }
        }

        // ✅ This makes it fire during scrolling / UITracking
        RunLoop.main.add(t, forMode: .common)

        timer = t
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()  // Clean up when ViewModel is deallocated
    }
    
}
