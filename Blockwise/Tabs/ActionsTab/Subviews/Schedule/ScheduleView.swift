//
//  ScheduleView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/02/26.
//

import SwiftUI
import FamilyControls

struct ScheduleView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var toastManager: ToastManager
    
    @StateObject private var vm = ScheduleViewModel()
    
    @State private var warningAlert: Bool = false
    @State private var showAlert: Bool = false
    @State private var showEditAlert: Bool = false

    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    let schedule: ScheduleEntity?
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 18) {
                        VStack(spacing: 24) {
                            Text(schedule?.icon ?? "☘️")
                                .font(.system(size: 56))
                            
                            VStack(spacing: 10) {
                                Text(schedule?.name ?? "My Schedule")
                                    .font(.grotesk(size: 26, weight: .semibold))
                                
                                Text("\(formatDaysShort(string: schedule?.activeDays ?? "")), \(window(startTime: schedule?.startTime ?? Date.now, endTime: schedule?.endTime ?? Date.now))")
                                    .font(.grotesk(.subheadline, weight: .regular))
                                    .foregroundStyle(.textC)
                                    .opacity(0.6)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 28)
                        }
                        
                        Button {
                            vm.showBlocks = true
                        } label: {
                            blockList
                        }
                        .tint(.primary)
                    }
                    
                    deleteButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Okay", role: .cancel) {
                    
                }
                .tint(.primary)
            } message: {
                Text(alertMessage)
            }
            .alert(alertTitle, isPresented: $warningAlert) {                
                Button("Delete", role: .destructive) {
                    do {
                        try vm.deletePermanently()
                        dismiss()
                        toastManager.info("Schedule deleted")
                    } catch {
                        Logger.error(error.localizedDescription)
                        showAlert = true
                        alertTitle = "Something went wrong"
                        alertMessage = "Failed to delete schedule: \(error.localizedDescription)"
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
        .sheet(isPresented: $vm.showBlocks) {
            BlockList()
        }
        .onAppear(perform: setup)
        .onDisappear(perform: vm.stopTimer)
    }
    
    private func setup() {
        let key = schedule?.selectionKey ?? ""
        vm.familySelection = UserDefaultsManager.shared.get(forKey: key, as: FamilyActivitySelection.self) ?? FamilyActivitySelection()

        vm.schedule = schedule
        vm.dismissAll = dismiss
        
        vm.startTimer()
    }
    
    private func window(startTime: Date, endTime: Date) -> String {
        "\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
    }
    
    private func formatDaysShort(string: String) -> String {
        let array = string.components(separatedBy: "_")
        
        // Check for everyday (7 days)
        if array.count == 7 {
            return "Everyday"
        }
        
        // Check for weekends
        if array.count == 2, array.contains("saturday") && array.contains("sunday") {
            return "Weekends"
        }
        
        // Check for weekdays
        if array.count == 5, !array.contains("saturday") && !array.contains("sunday") {
            return "Weekdays"
        }
        
        // Check for single day
        if array.count == 1, let day = array.first {
            return "\(day.capitalized)s"
        }
        
        // For specific multiple days, show abbreviated format
        let dayMap: [String: String] = [
            "monday": "Mon",
            "tuesday": "Tue",
            "wednesday": "Wed",
            "thursday": "Thu",
            "friday": "Fri",
            "saturday": "Sat",
            "sunday": "Sun"
        ]
        
        let shortDays = array.compactMap { dayMap[$0.lowercased()] }
        
        return shortDays.joined(separator: ", ")
    }
    
    @ViewBuilder
    private var blockList: some View {
        HStack(spacing: 0) {
            Text("Block List")
                .font(.grotesk(.title3, weight: .semibold))
                .foregroundStyle(.textC)
            
            Spacer()
            
            Text("\(vm.familySelection.applications.count) apps")
                .font(.grotesk(.body, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .padding(.trailing, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Image(systemName: "chevron.right")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .foregroundStyle(Theme.foregroundC)
                .border(cornerRadius: 28)
        }
    }
    
    @ViewBuilder
    var deleteButton: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                guard vm.isButtonEnabled else { return }
                Haptics.warningFeedback()
                
                warningAlert = true
                alertTitle = "Are you sure?"
                alertMessage = "This schedule will be permanently removed."
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Delete \(!vm.isButtonEnabled ? "available in \(vm.timeRemaining)s" :"schedule")")
                            .font(.grotesk(.title3, weight: .semibold))
                            .contentTransition(.numericText())
                            .animation(.smooth, value: vm.timeRemaining)
                            .animation(.smooth, value: vm.isButtonEnabled)

                    }
                    .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .foregroundStyle(.red.opacity(0.1))
                        .border(cornerRadius: 28, color: .red.opacity(0.15))
                }
            }
            .tint(.primary)
            
        }

    }
    
    @ViewBuilder
    private func BlockList() -> some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(vm.familySelection.applicationTokens.enumerated()), id: \.offset) { (i, token) in
                        HStack(spacing: 14) {
                            Label(token)
                                .labelStyle(.iconOnly)
                                .scaleEffect(1.75)
                            
                            Label(token)
                                .labelStyle(.titleOnly)
                                .scaleEffect(0.9, anchor: .leading)
                        }
                    }
                } header: {
                    Text("\(vm.familySelection.applications.count) apps")
                        .font(.grotesk(.body, weight: .regular))
                }
                .listRowBackground(Theme.foregroundC)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationTitle("Block List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Logger.debug("Is schedule active: \(isScheduleActive(schedule: schedule!))")
                        
                        guard let schedule, !isScheduleActive(schedule: schedule) else {
                            Haptics.warningFeedback()
                            showEditAlert = true
                            alertTitle = "Edit is currently disabled"
                            alertMessage = "You can't edit the schedule while it's active. Try again later."
                            return
                        }
                        
                        vm.showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .tint(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showBlocks = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $vm.showEdit) {
                EditAppSelection()
                    .environmentObject(vm)
            }
            .alert(alertTitle, isPresented: $showEditAlert) {
                Button("Okay", role: .cancel) {
                    
                }
                .tint(.primary)
            } message: {
                Text(alertMessage)
            }
        }
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
    ScheduleView(schedule: nil)
        .environmentObject(ToastManager())
}
