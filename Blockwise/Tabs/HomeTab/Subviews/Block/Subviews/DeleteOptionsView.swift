//
//  DeleteOptionsView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

struct DeleteOptionsView: View {
    @EnvironmentObject var vm: BlockViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    let selectedReason: DeleteReason
    
    @State private var showStreakWarning: Bool = false
    @State private var showUnavailableAlert: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var actionType: ActionType?
    
    enum ActionType {
        case deletePermanently
        case openForToday
        case openForAnHour
    }
    
    // Helper to check if "Open for today" is available
    private var canOpenForToday: Bool {
        guard let lastDailyOpenDate = vm.block?.openForTodayDate else {
            return true // Never used before
        }
        
        let calendar = Calendar.current
        let daysSinceLastOpen = calendar.dateComponents([.day], from: lastDailyOpenDate, to: Date()).day ?? 0
        
        return daysSinceLastOpen >= 7
    }
    
    private var daysUntilAvailable: Int {
        guard let lastDailyOpenDate = vm.block?.openForTodayDate else {
            return 0
        }
        
        let calendar = Calendar.current
        let daysSinceLastOpen = calendar.dateComponents([.day], from: lastDailyOpenDate, to: Date()).day ?? 0
        
        return max(0, 7 - daysSinceLastOpen)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                openForTodayButton
                keepBlockButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .overlay(alignment: .bottom) {
            Button {
                actionType = .deletePermanently
                showDeleteConfirmation = true
                Haptics.warningFeedback()
            } label: {
                Text("Delete permanently")
                    .font(.grotesk(.body, weight: .medium))
            }
            .tint(.red)
            .padding()
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .navigationTitle("Choose what works best")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete this block?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Haptics.feedback(style: .rigid)
                // Check if limit is reached to show second alert
                if vm.isLimitReached {
                    showStreakWarning = true
                } else {
                    performDeletePermanently()
                }
            }
        } message: {
            Text("Are you sure you want to delete this block permanently?")
        }
        .alert("You'll lose your streak", isPresented: $showStreakWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Continue Anyway", role: .destructive) {
                Haptics.feedback(style: .rigid)
                performAction()
            }
        } message: {
            Text("Deleting or opening a block after reaching your daily limit will reset your streak. Are you sure?")
        }
        .alert("Not Available Yet", isPresented: $showUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can use this option only once per week. It will be available again in \(daysUntilAvailable) day\(daysUntilAvailable == 1 ? "" : "s").")
        }
    }
    
    private func performDeletePermanently() {
        do {
            try vm.deletePermanently()
            toastManager.info("Block deleted")
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error(error.localizedDescription)
        }
        dismiss()
    }
    
    private func performAction() {
        if vm.isLimitReached {
            userViewModel.breakStreak()
        }

        switch actionType {
        case .deletePermanently:
            performDeletePermanently()
        case .openForToday:
            Task {
                do {
                    try await vm.openForToday()
                    
                    if let superlinkId = vm.block?.superlinkId,
                       let superlink = Superlink.find(by: superlinkId) {
                        try await Task.sleep(nanoseconds: 650_000_000)
                        try superlink.open {
                            toastManager.error("Could not open URL: \(superlink.urlScheme)")
                        }
                    }

                } catch {
                    Logger.error(error.localizedDescription)
                    toastManager.error(error.localizedDescription)
                }
            }
        case .openForAnHour:
            vm.openForAnHour()
        case .none:
            break
        }
        dismiss()
    }
    
    @ViewBuilder
    var openForTodayButton: some View {
        Button {
            if !canOpenForToday {
                showUnavailableAlert = true
                Haptics.warningFeedback()
                return
            }
            
            if vm.isLimitReached {
                actionType = .openForToday
                showStreakWarning = true
                Haptics.warningFeedback()
            } else {
                Task {
                    do {
                        try await vm.openForToday()
                        
                        if let superlinkId = vm.block?.superlinkId,
                           let superlink = Superlink.find(by: superlinkId) {
                            try await Task.sleep(nanoseconds: 650_000_000)
                            try superlink.open {
                                toastManager.error("Could not open URL: \(superlink.urlScheme)")
                            }
                        }

                    } catch {
                        Logger.error(error.localizedDescription)
                        toastManager.error(error.localizedDescription)
                    }
                }

                dismiss()
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Open for today")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(canOpenForToday ? .textC : .secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .trailing) {
                    if !canOpenForToday {
                        Text("\(daysUntilAvailable)d")
                            .font(.grotesk(.callout, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 28)
                    .opacity(canOpenForToday ? 1.0 : 0.5)
            }
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    var openForAnHourButton: some View {
        Button {
            if vm.isLimitReached {
                actionType = .openForAnHour
                showStreakWarning = true
                Haptics.warningFeedback()
            } else {
                vm.openForAnHour()
                dismiss()
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Open for 1 hour")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.textC)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 28)
            }
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    var keepBlockButton: some View {
        Button {
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Keep block")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.textC)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 28)
            }
        }
        .tint(.primary)
    }

    private func dismiss() {
        if let dismissAll = vm.dismissAll {
            dismissAll()
        }
    }
}

#Preview {
    NavigationStack {
        DeleteOptionsView(selectedReason: .dontNeedAnymore)
            .environmentObject(BlockViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ToastManager())
    }
}
