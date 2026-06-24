//
//  ActionsTabView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI
import FamilyControls

struct ActionsTabView: View {
    @StateObject private var actionsViewModel = ActionsViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScheduleEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var schedules: FetchedResults<ScheduleEntity>
    
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    if !schedules.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(schedules) { schedule in
                                Button {
                                    actionsViewModel.selectedSchedule = schedule
                                } label: {
                                    ScheduleRow(schedule: schedule)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                Text("Have an issue?")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Button {
                                    actionsViewModel.showReload = true
                                    Haptics.feedback(style: .light)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                        
                                        Text("Reload Schedules")
                                            .font(.grotesk(.body, weight: .medium))
                                    }
                                }
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    if !actionsViewModel.templates.isEmpty {
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("For you")
                                    .font(.grotesk(.title3, weight: .semibold))
                                    .foregroundStyle(.textC)
                                
                                Text("Schedule time away from distractions")
                                    .font(.grotesk(size: 14, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(actionsViewModel.templates) { template in
                                    Button {
                                        Haptics.feedback(style: .light)
                                        actionsViewModel.showCreate = true
                                        actionsViewModel.selectedTemplate = template
                                    } label: {
                                        ScheduleTemplateRow(template: template)
                                    }
                                    .tint(.primary)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.feedback(style: .light)
                        actionsViewModel.showCreate = true
                        actionsViewModel.selectedTemplate = nil
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Schedules")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(item: $actionsViewModel.selectedSchedule) { schedule in
                ScheduleView(schedule: schedule)
            }
            .sheet(isPresented: $actionsViewModel.showCreate) {
                CreateScheduleView(
                    schedules: schedules,
                    template: actionsViewModel.selectedTemplate
                )
                .environmentObject(actionsViewModel)
            }
            .alert("Reload Schedules", isPresented: $actionsViewModel.showReload) {
                Button("Reload Now") {
                    do {
                        try actionsViewModel.reloadSchedules(schedules: schedules)
                        toastManager.info("Schedules reloaded!")
                    } catch {
                        toastManager.error(error.localizedDescription)
                    }
                }
                
                Button("Dismiss", role: .cancel) {
                    Logger.debug("Active schedules: \(DeviceActivityManager.shared.center.activities.count)")
                }
                    .tint(.primary)
            } message: {
                Text("Your schedules sync with Screen Time to block apps correctly.\n\nSometimes this sync fails. You can manually reload to fix any issues.")
            }
        }
        .onChange(of: schedules.count) {
            if schedules.isEmpty {
                actionsViewModel.resetTemplates()
            }
        }
    }
    
    @ViewBuilder
    private func ScheduleRow(schedule: ScheduleEntity) -> some View {
        let selection = UserDefaultsManager.shared.get(forKey: schedule.selectionKey ?? "", as: FamilyActivitySelection.self)
        let appSelection = selection?.applicationTokens
//        let isActive = isScheduleActive(schedule: schedule)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Text(schedule.icon ?? "☘️")
                    .font(.system(size: 38))
                    .frame(square: 38)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.name ?? "unknown")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.textC)
                    
                    Text("\(days(string: schedule.activeDays ?? "monday")), \(window(startTime: schedule.startTime ?? .now, endTime: schedule.endTime ?? .now))")
                        .font(.grotesk(.footnote, weight: .regular))
                        .foregroundStyle(.textC)
                        .opacity(0.6)
                }
            }
            
            if let appSelection {
                ZStack {
                    ForEach(Array(appSelection.prefix(3).enumerated()), id: \.offset) { (index, appToken) in
                        Label(appToken)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.5)
                            .padding(2)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .offset(x: CGFloat(index) * 24)
                    }

                    if appSelection.count > 3 {
                        Text("+\(appSelection.count - 3)")
                            .font(.grotesk(.subheadline, weight: .medium))
                            .foregroundStyle(Color.secondary)
                            .offset(x: CGFloat(3.5) * 24)
                    }
                }
                .padding(.leading, 16 + 38)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Image(systemName: "chevron.right")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(Color.secondary.opacity(0.5))
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .foregroundStyle(Theme.foregroundC)
                .border(cornerRadius: 32)
        }
    }
    
    @ViewBuilder
    private func ScheduleTemplateRow(template: ScheduleTemplate) -> some View {
        HStack(spacing: 16) {
            Text(template.emoji)
                .font(.system(size: 38))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.grotesk(.title3, weight: .semibold))
                    .foregroundStyle(.textC)
                
                Text("\(days(string: template.weekdays.asString)), \(window(startTime: template.startTime, endTime: template.endTime))")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.textC)
                    .opacity(0.6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Circle()
                .frame(square: 48)
                .foregroundStyle(.secondary.opacity(0.1))
                .border(cornerRadius: 100)
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.textC.opacity(0.5))
                }
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .foregroundStyle(Theme.foregroundC)
                .border(cornerRadius: 32)
        }
    }
    
    private func days(string: String) -> String {
        let array = string.components(separatedBy: "_")
        
        if array.count == 2, array.contains(Weekday.sunday.rawValue) && array.contains(Weekday.saturday.rawValue) {
            return "Weekends"
        }
        
        if array.count == 5, !array.contains(Weekday.sunday.rawValue) && !array.contains(Weekday.saturday.rawValue) {
            return "Weekdays"
        }
        
        if array.count == 7 {
            return "Everyday"
        }
        
        if array.count == 1 {
            return "\(array.first ?? "")s".capitalized
        }
        
        return "\(array.count) days"
    }
    
    private func window(startTime: Date, endTime: Date) -> String {
        "\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
    }
    
    private func isScheduleActive(schedule: ScheduleEntity) -> Bool {
        guard let startTime = schedule.startTime,
              let endTime = schedule.endTime,
              let activeDays = schedule.activeDays else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        
        // Check if today is an active day
        let activeDaysArray = activeDays.components(separatedBy: "_")
        let weekdayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let todayName = weekdayNames[currentWeekday - 1]
        
        guard activeDaysArray.contains(todayName) else {
            return false
        }
        
        // Get current time components
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        // Get schedule time components
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let startTimeInMinutes = startHour * 60 + startMinute
        
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        let endTimeInMinutes = endHour * 60 + endMinute
        
        // Handle overnight schedules (e.g., 22:00 to 02:00)
        if endTimeInMinutes < startTimeInMinutes {
            // Schedule crosses midnight
            // Active if: current time >= start OR current time < end
            return currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes < endTimeInMinutes
        } else {
            // Normal same-day schedule
            return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes < endTimeInMinutes
        }
    }
}

#Preview {
    RootView(tabSelection: 1)
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
}
