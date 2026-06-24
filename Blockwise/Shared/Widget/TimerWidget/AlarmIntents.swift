//
//  AlarmIntents.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/09/25.
//

import Foundation
import AppIntents
import AlarmKit

@available(iOS 26.0, *)
struct AlarmIntents: LiveActivityIntent {
    static var title: LocalizedStringResource = "Alarm Action"
    static var isDiscoverable: Bool = false
    
    @Parameter
    var id: String
    
    @Parameter
    var isCancel: Bool
    
    @Parameter
    var isResume: Bool
    
    init(id: UUID, isCancel: Bool = false, isResume: Bool = false) {
        self.id = id.uuidString
        self.isCancel = isCancel
        self.isResume = isResume
    }
    
    init() {
        
    }
    
    func perform() async throws -> some IntentResult {
        
        if let alarmID = UUID(uuidString: id) {
            if isCancel {
                // Cancel alarm
                try AlarmManager.shared.cancel(id: alarmID)
            } else {
                if isResume {
                    // Resume alarm
                    try AlarmManager.shared.resume(id: alarmID)
                } else {
                    // Pause alarm
                    try AlarmManager.shared.pause(id: alarmID)
                }
            }
        }
        
        return .result()
    }
}

