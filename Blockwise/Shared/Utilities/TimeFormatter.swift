//
//  TimeFormatter.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/04/25.
//

import SwiftUI

enum TimeFormatter {
    enum TimeFormatterStyle {
        case short
        case spaced
        case long
        case clock
        case hoursOnly
        case minutesOnly
    }
    
    static func display(_ interval: TimeInterval, style: TimeFormatterStyle) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        switch style {
        case .short:
            var parts: [String] = []
            if hours > 0 {
                parts.append("\(hours)h")
            }
            if minutes > 0 || hours == 0 {
                parts.append("\(minutes)m")
            }
            return parts.joined(separator: " ")
            
        case .spaced:
            var parts: [String] = []
            
            if hours > 0 {
                parts.append("\(hours) \(hours == 1 ? "hour" : "hours")")
            }
            
            if minutes > 0 {
                parts.append("\(minutes) min")
            } else if seconds > 0 {
                // Show seconds if there are no minutes but there are seconds
                parts.append("\(seconds) sec")
            }
            
            // Fallback: if exactly 0 total seconds
            if parts.isEmpty {
                parts.append("0 min")
            }
            
            return parts.joined(separator: " ")
            
        case .long:
            var parts: [String] = []
            if hours > 0 {
                parts.append("\(hours) \(hours == 1 ? "hour" : "hours")")
            }
            if minutes > 0 || hours == 0 {
                parts.append("\(minutes) \(minutes == 1 ? "minute" : "minutes")")
            }
            return parts.joined(separator: " ")
            
        case .clock:
            if hours > 0 {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
            
        case .hoursOnly:
            return "\(hours)"
            
        case .minutesOnly:
            return "\(minutes)"
        }
    }
}
