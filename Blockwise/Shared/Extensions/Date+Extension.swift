//
//  Date+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/10/24.
//

import SwiftUI

/// Extends `Date` to allow creating a date using a specific month and year.
extension Date {
    /// An enumeration representing the months of the year.
    enum Month: Int {
        case january = 1, february, march, april, may, june
        case july, august, september, october, november, december
    }
    
    /// Initializes a `Date` instance set to the first day of the specified month and year.
    ///
    /// If the date creation fails, this initializer defaults to the current date.
    ///
    /// - Parameters:
    ///   - month: A `Month` enum value representing the month of the desired date.
    ///   - year: An integer representing the year of the desired date.
    init(_ month: Month, _ year: Int) {
        // Get the current calendar and set to the current time zone.
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // Create date components with the specified month, year, and default day of 1.
        var components = DateComponents()
        components.year = year
        components.month = month.rawValue
        components.day = 1
        
        // Attempt to create the date; default to the current date if creation fails.
        if let date = calendar.date(from: components) {
            self = date
        } else {
            self = Date()
        }
    }
}

extension Date {
    func setting(hour: Int, minute: Int, second: Int = 0) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: second,
            of: self
        ) ?? Date.now
    }
}

extension Date {
    var localTimeZone: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}

extension Date {
    func timeString(timezone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension Date {
    enum DateComponentFormat {
        /// Shows relative text if applicable: "Today", "Yesterday", or a date string (e.g., "Aug 18, 2025")
        case relative
        
        /// Shows time ago: "13 hrs ago", "12 mins ago", "40 sec ago"
        case timeAgo
        
        /// The numeric day of the month (e.g., "18")
        case day
        
        /// The abbreviated month (e.g., "Aug")
        case month
        
        /// The complete month (e.g., "August)
        case monthFull
        
        /// The abbreviated weekday (e.g., "Mon")
        case weekday
        
        /// The full year number (e.g., "2025")
        case year
        
        /// The time in short style (e.g., "2:42 PM")
        case time
        
        /// Inserts a custom string (e.g., ",")
        case separator
    }
    
    func formatted(components: [DateComponentFormat]) -> String {
        let calendar = Calendar.current
        var parts: [String] = []
        
        for component in components {
            switch component {
            case .relative:
                if calendar.isDateInToday(self) {
                    parts.append("Today")
                } else if calendar.isDateInYesterday(self) {
                    parts.append("Yesterday")
                } else {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    parts.append(formatter.string(from: self))
                }
                
            case .timeAgo:
                let diff = Int(Date().timeIntervalSince(self))
                if diff < 60 {
                    parts.append("\(diff) sec ago")
                } else if diff < 3600 {
                    parts.append("\(diff / 60) mins ago")
                } else if diff < 86400 {
                    parts.append("\(diff / 3600) hrs ago")
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E, d MMM"
                    parts.append(formatter.string(from: self))
                }
                
            case .day:
                let day = calendar.component(.day, from: self)
                parts.append("\(day)")
                
            case .month:
                let formatter = DateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("MMM")
                parts.append(formatter.string(from: self))
                
            case .monthFull:
                let formatter = DateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("MMMM")
                parts.append(formatter.string(from: self))
                
            case .weekday:
                let formatter = DateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("E")
                parts.append(formatter.string(from: self))
                
            case .year:
                let year = calendar.component(.year, from: self)
                parts.append("\(year)")
                
            case .time:
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                parts.append(formatter.string(from: self))
                
            case .separator:
                // Append separator without extra spaces
                parts.append(", ")
            }
        }
        
        // Combine parts: add space **between normal components** but not around separators
        var result = ""
        for (i, part) in parts.enumerated() {
            if case .separator = components[i] {
                result += part
            } else {
                if !result.isEmpty, !result.hasSuffix(" "), !result.hasSuffix(",") {
                    result += " "
                }
                result += part
            }
        }
        
        return result
    }
}

extension Date {
    /// Returns the weekday as a lowercase string, locale-independent
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.string(from: self).lowercased()
    }
}

extension Date {
    
    /// Returns the real clock distance in seconds between two times.
    /// If end is earlier than start, it assumes end is next day.
    func distanceTo(end: Date, calendar: Calendar = .current) -> Double {
        
        let startComponents = calendar.dateComponents([.hour, .minute], from: self)
        let endComponents = calendar.dateComponents([.hour, .minute], from: end)
        
        guard
            let startHour = startComponents.hour,
            let startMinute = startComponents.minute,
            let endHour = endComponents.hour,
            let endMinute = endComponents.minute
        else { return 0 }
        
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        var difference = endTotalMinutes - startTotalMinutes
        
        // If negative → crossed midnight
        if difference < 0 {
            difference += 24 * 60
        }
        
        return Double(difference)
    }
}

