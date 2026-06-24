//
//  ActionsViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI

final class ActionsViewModel: ObservableObject {
    @Published var selectedSchedule: ScheduleEntity?
    @Published var selectedTemplate: ScheduleTemplate?

    @Published var showCreate: Bool = false
    @Published var showReload: Bool = false

    @Published var templates: [ScheduleTemplate] = []
    
    func reloadSchedules(schedules: FetchedResults<ScheduleEntity>) throws {
        // Remove all activities
        for activity in DeviceActivityManager.shared.center.activities {
            DeviceActivityManager.shared.stopMonitoringActivity(named: activity)
        }
        
        for schedule in schedules {
            try DeviceActivityManager.shared.schedule(
                days: Weekday.fromString(schedule.activeDays ?? ""),
                startTime: schedule.startTime ?? .now,
                endTime: schedule.endTime ?? .now,
                id: schedule.identifier ?? ""
            )
        }
    }
    
    private let hiddenTemplatesKey = "hiddenScheduleTemplates"
    private var hiddenTemplateIDs: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: hiddenTemplatesKey) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: hiddenTemplatesKey)
        }
    }
    
    init() {
        loadTemplates()
    }
    
    private func loadTemplates() {
        let hidden = hiddenTemplateIDs
        templates = ScheduleTemplate.templates.filter { !hidden.contains($0.stableID) }
    }
    
    /// Call this when user creates a schedule from a template
    func hideTemplate(_ template: ScheduleTemplate) {
        var hidden = hiddenTemplateIDs
        hidden.insert(template.stableID)
        hiddenTemplateIDs = hidden
        
        templates.removeAll { $0.stableID == template.stableID }
    }
    
    /// Call this when user explicitly dismisses a template
    func dismissTemplate(_ template: ScheduleTemplate) {
        hideTemplate(template)
    }
    
    /// Optional: Reset all hidden templates (useful for settings/debugging)
    func resetTemplates() {
        UserDefaults.standard.removeObject(forKey: hiddenTemplatesKey)
        loadTemplates()
    }
}

// MARK: - "For you schedules" (pre-built schedules)
struct ScheduleTemplate: Identifiable {
    // Remove UUID since we're using stableID
    var id: String { stableID }
    
    let name: String
    let emoji: String
    let startTime: Date
    let endTime: Date
    let weekdays: [Weekday]
    
    var stableID: String {
        "schedule_named_\(name)"
    }
    
    static let templates: [ScheduleTemplate] = [
        ScheduleTemplate(
            name: "Work",
            emoji: "💻",
            startTime: .now.setting(hour: 9, minute: 0),
            endTime: .now.setting(hour: 17, minute: 0),
            weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday]
        ),
        
        ScheduleTemplate(
            name: "Gym Time",
            emoji: "🏋️‍♂️",
            startTime: .now.setting(hour: 17, minute: 30),
            endTime: .now.setting(hour: 19, minute: 30),
            weekdays: [.monday, .wednesday, .friday]
        ),
        
        ScheduleTemplate(
            name: "Reading Time",
            emoji: "📚",
            startTime: .now.setting(hour: 18, minute: 0),
            endTime: .now.setting(hour: 18, minute: 45),
            weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday]
        ),
        
        ScheduleTemplate(
            name: "Good Night",
            emoji: "🌙",
            startTime: .now.setting(hour: 22, minute: 0),
            endTime: .now.setting(hour: 8, minute: 0),
            weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .sunday]
        ),
    ]
}
