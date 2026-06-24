//
//  Extension+Date.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/12/25.
//

import Foundation

extension Date {
    static var yesterday: Date {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        return calendar.startOfDay(for: yesterday)
    }
    
    static var tomorrow: Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
        return calendar.startOfDay(for: tomorrow)
    }
}
