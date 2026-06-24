//
//  FocusViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI
import FamilyControls

enum BlockingType: String, CaseIterable {
    case allApps = "All Apps"
    case specificApps = "Specific Apps"
}

final class FocusViewModel: ObservableObject {
    @AppStorage(AppStorageKeys.Focus.startTime.key) var startTime: Date = .now
    @AppStorage(AppStorageKeys.Focus.showFocus.key) var showFocus: Bool = false
    @AppStorage(AppStorageKeys.Focus.duration.key) var duration: TimeInterval = 1800 // 30 minutes default
    @AppStorage("blocking_type") var blockingType: BlockingType = .allApps
    
    @Published var blockedApps = FamilyActivitySelection(includeEntireCategory: true)
    @Published var allowedApps = FamilyActivitySelection(includeEntireCategory: true)
    
    @Published var hardMode: Bool = false
    
    @Published var showSetup: Bool = false
    @Published var showBlockingTypePicker: Bool = false
    @Published var showDurationPicker: Bool = false
    
    @Published var showBlockListPicker: Bool = false
    @Published var showAllowListPicker: Bool = false
    
    @Published var showBlockList: Bool = false
    @Published var showAllowList: Bool = false
    
    @Published var inputDuration: Int = 30 // minutes
    
    init() {
        blockedApps = UserDefaultsManager.shared
            .get(forKey: "focus_block_list", as: FamilyActivitySelection.self) ?? FamilyActivitySelection(includeEntireCategory: true)
        allowedApps = UserDefaultsManager.shared
            .get(forKey: "focus_allow_list", as: FamilyActivitySelection.self) ?? FamilyActivitySelection(includeEntireCategory: true)
    }
    
    func startSession(selection: FamilyActivitySelection) throws {
        // Schedule block
        try DeviceActivityManager.shared.startFocusSession(for: duration, selection: selection)
        
        startTime = .now
        showFocus = true
        duration = Double(inputDuration) * 60
        
        UserDefaultsManager.shared.set(true, forKey: "is_focus_active")
    }
    
    func startSession(allExcept exceptions: FamilyActivitySelection) throws {
        // Schedule block
        try DeviceActivityManager.shared.startFocusSession(for: duration, exceptions: exceptions)
        
        startTime = .now
        showFocus = true
        duration = Double(inputDuration) * 60
        
        UserDefaultsManager.shared.set(true, forKey: "is_focus_active")
    }

    func stopSession() {
        showFocus = false
        
        for activity in DeviceActivityManager.shared.center.activities {
            if activity.rawValue.components(separatedBy: "_").first == "focus" {
                Logger.debug("Focus activity found: \(activity.rawValue)")
                DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
            }
        }
        
        DeviceActivityManager.shared.focusStore.clearAllSettings()
        
        UserDefaultsManager.shared.set(false, forKey: "is_focus_active")
    }
}
