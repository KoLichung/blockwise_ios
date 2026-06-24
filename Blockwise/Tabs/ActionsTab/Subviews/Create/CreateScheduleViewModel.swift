//
//  CreateScheduleViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI
import FamilyControls

final class CreateScheduleViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var emoji: String = "☘️"
    @Published var startTime: Date = .now.setting(hour: 15, minute: 0)
    @Published var endTime: Date = .now.setting(hour: 19, minute: 0)
    
    @Published var familySelection = FamilyActivitySelection(includeEntireCategory: true)
    
    @Published var daysActive: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    @Published var showStartTimePicker: Bool = false
    @Published var showEndTimePicker: Bool = false
    @Published var showFamilyPicker: Bool = false

    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    func addRemove(_ weekday: Weekday) {
        if let index = daysActive.firstIndex(of: weekday) {
            // Weekday is already in the array, remove it
            daysActive.remove(at: index)
        } else {
            // Weekday is not in the array, add it and sort
            daysActive.append(weekday)
            daysActive.sort { $0.sortIndex < $1.sortIndex }
        }
    }
    
    func createSchedule(schedules: FetchedResults<ScheduleEntity>) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ScheduleError.noName
        }

        guard !daysActive.isEmpty else {
            throw ScheduleError.noDaysSelected
        }
        
        Logger.debug("Distance: \(startTime.distanceTo(end: endTime)) >= 30")
        
        guard startTime.distanceTo(end: endTime) >= (30) else {
            Logger.debug("error here: tooShort")
            throw ScheduleError.tooShort
        }
        
        Logger.debug("Distance: \(startTime.distanceTo(end: endTime)) <= \((12 * 60))")
        
        guard startTime.distanceTo(end: endTime) <= (12 * 60) else {
            Logger.debug("error here: exceedsMaxDuration")
            throw ScheduleError.exceedsMaxDuration
        }

        guard !familySelection.applicationTokens.isEmpty else {
            throw ScheduleError.noApps
        }
        
        Logger.debug("=======================================================================")

        // Check for overlaps with existing schedules
        Logger.debug("📋 Checking for overlaps with \(schedules.count) existing schedules")
        Logger.debug("🆕 New schedule: '\(emoji) \(name)' | Days: \(daysActive.map { $0.rawValue }) | Time: \(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))")
        
        for schedule in schedules {
            guard let days = schedule.activeDays else {
                Logger.debug("⚠️ Skipping schedule with no active days")
                continue
            }
            guard let existingStart = schedule.startTime,
                  let existingEnd = schedule.endTime else {
                Logger.debug("⚠️ Skipping schedule with missing start/end time")
                continue
            }
            
            let existingName = schedule.name ?? "Unnamed"
            let existingEmoji = schedule.icon ?? ""
            
            Logger.debug("🔍 Checking against: '\(existingEmoji) \(existingName)' | Days: \(days) | Time: \(existingStart.formatted(date: .omitted, time: .shortened)) - \(existingEnd.formatted(date: .omitted, time: .shortened))")
            
            // First check: Do the days overlap?
            let existingDays = Weekday.fromString(days)
            let hasCommonDays = !Set(daysActive).isDisjoint(with: Set(existingDays))
            
            if !hasCommonDays {
                Logger.debug("✅ No day overlap - schedules don't conflict")
                continue
            }
            
            Logger.debug("📅 Days DO overlap: \(Set(daysActive).intersection(Set(existingDays)).map { $0.rawValue })")
            
            // Second check: Do the time windows overlap?
            if timeWindowsOverlap(
                start1: startTime,
                end1: endTime,
                start2: existingStart,
                end2: existingEnd
            ) {
                Logger.debug("❌ OVERLAP DETECTED! Time windows conflict")
                Logger.debug("=======================================================================")
                throw ScheduleError.overlapping(scheduleName: existingName, scheduleEmoji: existingEmoji)
            } else {
                Logger.debug("✅ Time windows don't overlap - schedules don't conflict")
            }
        }
        
        // Can create
        Logger.debug("✨ CAN CREATE - No overlaps found!")
        try CoreDataStack.shared.createSchedule(
            asset: emoji,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            days: daysActive,
            startTime: startTime,
            endTime: endTime,
            apps: familySelection
        )
        Logger.debug("=======================================================================")
    }
    
    /**
     Determines if two time windows overlap, accounting for midnight crossings.
     
     This function handles complex cases where schedules can cross midnight:
     
     **Example 1: Simple overlap (no midnight crossing)**
     - Schedule A: 2 PM - 6 PM
     - Schedule B: 4 PM - 8 PM
     - Result: OVERLAP (4 PM - 6 PM)
     
     **Example 2: No overlap (no midnight crossing)**
     - Schedule A: 2 PM - 6 PM
     - Schedule B: 7 PM - 10 PM
     - Result: NO OVERLAP
     
     **Example 3: Midnight crossing overlap**
     - Schedule A: 10 PM - 2 AM (crosses midnight)
     - Schedule B: 1 AM - 5 AM
     - Result: OVERLAP (1 AM - 2 AM)
     
     **Example 4: Both cross midnight and overlap**
     - Schedule A: 11 PM - 1 AM (crosses midnight)
     - Schedule B: 10 PM - 2 AM (crosses midnight)
     - Result: OVERLAP (entire window of A is within B)
     
     **Example 5: One crosses midnight, other doesn't, but they overlap**
     - Schedule A: 11 PM - 2 AM (crosses midnight)
     - Schedule B: 6 PM - 11:30 PM
     - Result: OVERLAP (11 PM - 11:30 PM on the starting day)
     
     **Example 6: One crosses midnight, wraps to overlap the other**
     - Schedule A: 11 PM - 3 AM (crosses midnight)
     - Schedule B: 2 AM - 6 AM
     - Result: OVERLAP (2 AM - 3 AM on the next day)
     
     **The Algorithm:**
     1. Normalize times to minutes since midnight (0-1439)
     2. Detect if each schedule crosses midnight (end < start in minutes)
     3. Check overlap considering four cases:
        - Neither crosses midnight: simple range overlap
        - Schedule 1 crosses: check if schedule 2 overlaps either side of midnight
        - Schedule 2 crosses: check if schedule 1 overlaps either side of midnight
        - Both cross: they always overlap (both span midnight)
     
     - Parameters:
        - start1: Start time of the first schedule
        - end1: End time of the first schedule
        - start2: Start time of the second schedule
        - end2: End time of the second schedule
     
     - Returns: `true` if the time windows overlap, `false` otherwise
     */
    private func timeWindowsOverlap(start1: Date, end1: Date, start2: Date, end2: Date) -> Bool {
        // Convert dates to minutes since midnight for easier comparison
        let start1Minutes = start1.minutesSinceMidnight
        let end1Minutes = end1.minutesSinceMidnight
        let start2Minutes = start2.minutesSinceMidnight
        let end2Minutes = end2.minutesSinceMidnight
        
        Logger.debug("⏰ Time comparison:")
        Logger.debug("   Schedule 1: \(start1Minutes) min (\(start1.formatted(date: .omitted, time: .shortened))) → \(end1Minutes) min (\(end1.formatted(date: .omitted, time: .shortened)))")
        Logger.debug("   Schedule 2: \(start2Minutes) min (\(start2.formatted(date: .omitted, time: .shortened))) → \(end2Minutes) min (\(end2.formatted(date: .omitted, time: .shortened)))")
        
        // Detect midnight crossings
        // If end time is less than start time, the schedule crosses midnight
        let schedule1CrossesMidnight = end1Minutes < start1Minutes
        let schedule2CrossesMidnight = end2Minutes < start2Minutes
        
        if schedule1CrossesMidnight {
            Logger.debug("🌙 Schedule 1 crosses midnight (e.g., 10 PM → 2 AM)")
        }
        if schedule2CrossesMidnight {
            Logger.debug("🌙 Schedule 2 crosses midnight (e.g., 10 PM → 2 AM)")
        }
        
        // Case 1: Neither schedule crosses midnight
        // Simple range overlap: [start1, end1] overlaps [start2, end2]
        if !schedule1CrossesMidnight && !schedule2CrossesMidnight {
            Logger.debug("📊 Case 1: Neither crosses midnight - checking simple range overlap")
            let overlaps = start1Minutes < end2Minutes && start2Minutes < end1Minutes
            Logger.debug("   Result: \(overlaps ? "OVERLAP" : "no overlap")")
            return overlaps
        }
        
        // Case 2: Only schedule 1 crosses midnight
        // Schedule 1 is active in two ranges: [start1, 1440) and [0, end1]
        // Check if schedule 2 overlaps either range
        if schedule1CrossesMidnight && !schedule2CrossesMidnight {
            Logger.debug("📊 Case 2: Schedule 1 crosses midnight - checking both sides")
            
            // Check overlap with the "before midnight" part of schedule 1: [start1, 1440)
            let overlapBeforeMidnight = start2Minutes < 1440 && start1Minutes < end2Minutes
            Logger.debug("   Before midnight [start1=\(start1Minutes), 1440): \(overlapBeforeMidnight ? "OVERLAP" : "no overlap")")
            
            // Check overlap with the "after midnight" part of schedule 1: [0, end1]
            let overlapAfterMidnight = start2Minutes < end1Minutes
            Logger.debug("   After midnight [0, end1=\(end1Minutes)]: \(overlapAfterMidnight ? "OVERLAP" : "no overlap")")
            
            let overlaps = overlapBeforeMidnight || overlapAfterMidnight
            Logger.debug("   Final result: \(overlaps ? "OVERLAP" : "no overlap")")
            return overlaps
        }
        
        // Case 3: Only schedule 2 crosses midnight
        // Schedule 2 is active in two ranges: [start2, 1440) and [0, end2]
        // Check if schedule 1 overlaps either range
        if !schedule1CrossesMidnight && schedule2CrossesMidnight {
            Logger.debug("📊 Case 3: Schedule 2 crosses midnight - checking both sides")
            
            // Check overlap with the "before midnight" part of schedule 2: [start2, 1440)
            let overlapBeforeMidnight = start1Minutes < 1440 && start2Minutes < end1Minutes
            Logger.debug("   Before midnight [start2=\(start2Minutes), 1440): \(overlapBeforeMidnight ? "OVERLAP" : "no overlap")")
            
            // Check overlap with the "after midnight" part of schedule 2: [0, end2]
            let overlapAfterMidnight = start1Minutes < end2Minutes
            Logger.debug("   After midnight [0, end2=\(end2Minutes)]: \(overlapAfterMidnight ? "OVERLAP" : "no overlap")")
            
            let overlaps = overlapBeforeMidnight || overlapAfterMidnight
            Logger.debug("   Final result: \(overlaps ? "OVERLAP" : "no overlap")")
            return overlaps
        }
        
        // Case 4: Both schedules cross midnight
        // Both are active across midnight, so they ALWAYS overlap
        // (They both span the midnight boundary)
        Logger.debug("📊 Case 4: Both cross midnight - automatic OVERLAP")
        return true
    }
}

// MARK: - Helper Extension
extension Date {
    /// Returns the number of minutes since midnight (0-1439)
    var minutesSinceMidnight: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

// MARK: - Error Types
enum ScheduleError: Error {
    case overlapping(scheduleName: String, scheduleEmoji: String)
    case exceedsMaxDuration
    case tooShort
    case noDaysSelected
    case noName
    case noApps
    
    var title: String {
        switch self {
        case .overlapping:
            return "Schedule Overlap"
        case .exceedsMaxDuration:
            return "Duration Too Long"
        case .tooShort:
            return "Duration Too Short"
        case .noDaysSelected:
            return "No Days Selected"
        case .noName:
            return "Name Required"
        case .noApps:
            return "No Apps Selected"
        }
    }
    
    func message(for scheduleName: String) -> String {
        switch self {
        case .overlapping(let name, let emoji):
            return "'\(scheduleName)' overlaps with '\(emoji) \(name)'. Please adjust the times or days."
        case .exceedsMaxDuration:
            return "Schedule duration cannot exceed 12 hours."
        case .tooShort:
            return "Schedule duration must be at least 30 minutes."
        case .noDaysSelected:
            return "Please select at least one day for this schedule."
        case .noName:
            return "Please enter a name for this schedule."
        case .noApps:
            return "Please select at least one app to block."
        }
    }
}
