//
//  Weekday.swift
//  Blockwise
//
//  Created by Ivan Sanna on 14/04/25.
//

import SwiftUI

enum Weekday: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }

    var sortIndex: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
    
    var next: Weekday {
        switch self {
        case .monday: return .tuesday
        case .tuesday: return .wednesday
        case .wednesday: return .thursday
        case .thursday: return .friday
        case .friday: return .saturday
        case .saturday: return .sunday
        case .sunday: return .monday
        }
    }
}

extension Array where Element == Weekday {
    /// Converts array of weekdays to underscore-separated string
    /// Example: [.monday, .tuesday, .sunday] -> "monday_tuesday_sunday"
    var asString: String {
        self.map { $0.rawValue }.joined(separator: "_")
    }
}

extension Weekday {
    /// Returns the Date corresponding to this weekday *for the current week*
    func dateThisWeek() -> Date? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find Monday of the current week (Monday = 2 in Gregorian; Sunday = 1)
        let weekdayIndex = calendar.component(.weekday, from: today)
        // Convert current weekday to Monday-based offset: Monday -> 0, Tuesday -> 1, ..., Sunday -> 6
        let currentOffsetFromMonday = (weekdayIndex + 5) % 7
        
        guard let monday = calendar.date(byAdding: .day, value: -currentOffsetFromMonday, to: today) else {
            return nil
        }
        
        // Map Weekday enum to offset from Monday
        let targetOffset: Int
        switch self {
        case .monday: targetOffset = 0
        case .tuesday: targetOffset = 1
        case .wednesday: targetOffset = 2
        case .thursday: targetOffset = 3
        case .friday: targetOffset = 4
        case .saturday: targetOffset = 5
        case .sunday: targetOffset = 6
        }
        
        return calendar.date(byAdding: .day, value: targetOffset, to: monday)
    }
}

extension Weekday {
    /// Checks if this weekday is earlier than today in the current week
    var isInPast: Bool {
        guard let date = self.dateThisWeek() else { return false }
        return date < Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Parsing helpers (inverse of Array<Weekday>.asString)
extension Weekday {
    /// Parses an underscore-separated string of lowercase weekday raw values into an array of Weekday.
    /// Example: "monday_tuesday_sunday" -> [.monday, .tuesday, .sunday]
    static func fromString(_ string: String) -> [Weekday] {
        guard !string.isEmpty else { return [] }
        return string
            .split(separator: "_")
            .compactMap { Weekday(rawValue: String($0)) }
    }
    
    /// Parses a single lowercase weekday raw value into a Weekday.
    /// Example: "monday" -> .monday
    static func fromRawValue(_ string: String) -> Weekday? {
        return Weekday(rawValue: string)
    }
}
