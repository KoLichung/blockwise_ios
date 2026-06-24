//
//  ScheduleViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/02/26.
//

import SwiftUI
import FamilyControls

final class ScheduleViewModel: ObservableObject {
    @Published var dismissAll: DismissAction?
    
    @Published var schedule: ScheduleEntity?
    @Published var familySelection = FamilyActivitySelection(includeEntireCategory: true)

    // Timer properties
    @Published var timeRemaining: Int = 15
    @Published var isButtonEnabled: Bool = false
    
    @Published var showBlocks: Bool = false
    @Published var showEdit: Bool = false

    private var timer: Timer?  // Don't need @Published for this

    func startTimer() {
        timeRemaining = 15
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

    @MainActor
    func deletePermanently() throws {
        guard let schedule else {
            throw SimpleError.message("Could not find schedule")
        }
        
        let activityId = schedule.identifier ?? ""
        try CoreDataStack.shared.delete(schedule)
        
        guard let activity = DeviceActivityManager.shared.center.activities.first(where: { $0.rawValue.components(separatedBy: "_")[1] == activityId }) else {
            return
        }
        
        DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
    }
}
