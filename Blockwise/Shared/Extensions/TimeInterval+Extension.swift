//
//  TimeInterval+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/08/25.
//

import Foundation

extension TimeInterval {
    // MARK: - Computed Properties for Extraction
    
    /// Extract hours from TimeInterval
    var hours: Int {
        return Int(self / 3600)
    }
    
    /// Extract minutes from TimeInterval (remaining after hours)
    var minutes: Int {
        return Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    /// Extract seconds from TimeInterval (remaining after hours and minutes)
    var seconds: Int {
        return Int(self.truncatingRemainder(dividingBy: 60))
    }
    
    /// Get total minutes (ignoring hour boundaries)
    var totalMinutes: Int {
        return Int(self / 60)
    }
    
    /// Get total seconds
    var totalSeconds: Int {
        return Int(self)
    }

    // MARK: - Formatted String Representations
    
    /// Returns a formatted string like "2h 30m" or "1h 15m 30s"
    /// - Parameter includeSeconds: Whether to include seconds in the output
    /// - Returns: Formatted duration string
    func formattedDuration(includeSeconds: Bool = false) -> String {
        let h = hours
        let m = minutes
        let s = seconds
        
        var components: [String] = []
        
        if h > 0 {
            components.append("\(h)h")
        }
        if m > 0 {
            components.append("\(m)m")
        }
        if includeSeconds && s > 0 {
            components.append("\(s)s")
        }
        
        return components.isEmpty ? "0m" : components.joined(separator: " ")
    }
}
