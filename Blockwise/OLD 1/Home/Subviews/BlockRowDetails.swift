//
//  BlockRowDetails.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/08/25.
//

import SwiftUI
import ManagedSettings
import Lottie

struct BlockRowDetails: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    let block: BlockEntity?
    
    @State private var isRestoring: Bool = false
    @State private var showDeleteConfirm: Bool = false
    
    @State private var deleteWarning: Bool = false
    
    var appToken: ApplicationToken? {
        guard let block else { return nil }
        guard let tokenString = block.appTokenString else { return nil }
        return ApplicationToken.fromRawValue(tokenString)
    }
    
    var todaysRecord: [RecordEntity] {
        block?.records.filtered(by: .now) ?? []
    }
    
    var totalUsage: TimeInterval {
        todaysRecord.reduce(.zero) { $0 + $1.duration }
    }
    
    var totalOpens: Int {
        todaysRecord.count
    }
    
    @State private var cooldown: Int = 0
    
    @State private var alertDelete: Bool = false
    
    @State private var advancedSettingsView: Bool = false
    
    // Properly scoped; was illegally declared inside a function before.
    private var isCooldown: Bool {
        guard let next = block?.nextAvailableDate else { return false }
        return next > .now && next.timeIntervalSinceNow > 10
        // We also check if the distance from now is greater that 10 seconds
        // this way we avoid the screen jumping to cooldown view as soon as the user taps to unlock
    }
    
    var body: some View {
        NavigationStack {
            List {
                if let appToken {
                    Section {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 10) {
                                Label(appToken)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(2.35)
                                    .frame(square: 56)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Label(appToken)
                                        .labelStyle(.titleOnly)
                                        .scaleEffect(0.95, anchor: .leading)
                                    
                                    Text("\(TimeFormatter.display(totalUsage, style: .spaced)) • ^[\(totalOpens) open](inflect: true)")
                                        .font(.grotesk(.footnote, weight: .regular))
                                        .opacity(0.65)
                                }
                            }
                        }
                    }
                    .listRowBackground(Theme.foregroundC)
                }
                
                Section {
                    Button {
                        advancedSettingsView = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.subheadline.weight(.medium))
                            
                            Text("Advanced Settings")
                                .font(.grotesk(.body, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.textC)
                    }
                }
                .listRowBackground(Theme.foregroundC)

                Section {
                    Button {
                        do {
                            try restoreBlocking()
                        } catch {
                            dismiss()
                            Logger.error(error.localizedDescription)
                            toastManager.error(error.localizedDescription)
                        }
                    } label: {
                        ZStack {
                            if isRestoring {
                                ProgressView()
                                    .tint(.orange)
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.subheadline.weight(.medium))
                                    
                                    Text("Restore Blocking")
                                        .font(.grotesk(.body, weight: .semibold))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.orange)
                    }
                } footer: {
                    Text("If you feeling something is not working as expected, click here to restore your blocking.")
                        .font(.grotesk(.footnote, weight: .regular))
                        .lineSpacing(2.0)
                }
                .listRowBackground(Color.orange.opacity(0.15))

                Section {
                    Button {
                        if totalUsage > 0 {
                            deleteWarning = true
                            Haptics.errorFeedback()
                        } else {
                            alertDelete = true
                            Haptics.warningFeedback()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.subheadline.weight(.medium))
                            
                            Text("Delete Block")
                                .font(.grotesk(.body, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.red)
                    }
                } footer: {
                    Text("**NOTE**: You can only delete a block when it's usage for the day is zero.")
                        .font(.grotesk(.footnote, weight: .regular))
                        .lineSpacing(2.0)
                }
                .listRowBackground(Color.red.opacity(0.15))

            }
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 14)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Options")
//            .toolbar(edge: .trailing) {
//                Button {
//                    dismiss()
//                    Haptics.feedback(style: .rigid)
//                } label: {
//                    Image(systemName: "xmark")
//                }
//                .tint(.primary)
//            }
            .alert("Delete Block?", isPresented: $alertDelete) {
                Button("Delete", role: .destructive) {
                    do {
                        try deleteBlock()
                    } catch {
                        dismiss()
                        Logger.error(error.localizedDescription)
                        toastManager.error(error.localizedDescription)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this block?")
            }
            .sheet(isPresented: $deleteWarning) {
                DeleteWarningView()
                    .presentationDetents([.height(550)])
            }
            .sheet(isPresented: $advancedSettingsView) {
                AdvancedView()
            }

        }
    }
    
    @ViewBuilder
    private func AdvancedView() -> some View {
        let minutes: [Int] = Array(0...10) + [15, 20, 25, 30, 35, 40, 45, 50, 55, 60]

        NavigationStack {
            List {
                Section {
                    Picker(selection: $cooldown) {
                        ForEach(minutes, id: \.self) { min in
                            Text(min == 0 ? "No cooldown" : "\(min) min")
                                .font(.grotesk(.body, weight: .regular))
                                .tag(min)
                        }
                    } label: {
                        Text("Cooldown")
                            .font(.grotesk())
                    }

                }
                .listRowBackground(Theme.foregroundC)
            }
            .navigationTitle("Advanced Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 14)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
//            .toolbar(edge: .trailing) {
//                Button {
//                    advancedSettingsView = false
//                    Haptics.feedback(style: .rigid)
//                } label: {
//                    Image(systemName: "xmark")
//                }
//                .tint(.primary)
//            }
            .onAppear {
                // Convert stored seconds -> minutes for UI
                cooldown = Int((block?.cooldown ?? 0) / 60)
            }
            .onChange(of: cooldown) { _, newValue in
                guard let block else { return }
                // Convert minutes -> seconds for storage
                block.cooldown = TimeInterval(newValue * 60)
                do {
                    try CoreDataStack.shared.saveContext()
                    Haptics.feedback(style: .soft)
                } catch {
                    Logger.error(error.localizedDescription)
                    toastManager.error("Failed to save cooldown")
                }
            }
        }
    }
    
    @ViewBuilder
    private func DeleteWarningView() -> some View {

        VStack(alignment: .center, spacing: 32) {
            LottieView(animation: .named("raised-hand"))
                .looping()
                .frame(square: 100)
            
            VStack(alignment: .leading, spacing: 32) {
                Text("You can't delete this block today.")
                    .font(.grotesk(.title, weight: .semibold))
                
                Text("To keep things fair, blocks can only be removed if they’ve had zero use during the day.")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4.0)
                
                Text("Today's usage: \(TimeFormatter.display(totalUsage, style: .spaced))")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .lineSpacing(4.0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Go back") {
                dismiss()
            }
            .foregroundStyle(Color.primaryBlue)
        }
        .padding([.bottom, .horizontal], 32)
        .padding(.top)
        .background(Color.tertiaryBlue, ignoresSafeAreaEdges: .all)
    }
    
    private func restoreBlocking() throws {
        guard let appToken else { return }
        guard let block else { return }
        
        Haptics.feedback(style: .soft)
        isRestoring = true
        
        // Make sure the block isn't open or this would cause problems.
        
        // If the block as an error, it's likely due to the Manager not triggering the intervalDidEnd so isOpen at this point is still TRUE.
        
        // So how do we know if there is actually a problem ?
        
        // Check if the shield is applied
        let isShieldApplied: Bool = DeviceActivityManager.shared.isCurrentlyShielded(token: appToken)

        // If the shield is on, there wouldn't be any issue
        
        guard !isShieldApplied else {
            completeRestore()
            Logger.debug("[RESTORE] Shield is applied, no errors to restore.")
            return
        }
        
        // We need to check if endTime is passed. If it is, and the shield is still open, we do have a problem to solve.
        guard let endTime = block.openEndTime else {
            completeRestore()
            return
        }
        
        guard Date.now > endTime else {
            completeRestore()
            Logger.debug("[RESTORE] The shield is currently opened but endTime hasn't passed, no errors to restore.\nEndTime: \(endTime.localTimeZone)\nCurrent Time: \(Date.now.localTimeZone)")
            return
        }
        
        Logger.debug("[RESTORE] Error found. Restoring...")
                
        block.isOpen = false
        try CoreDataStack.shared.saveContext()
        
        DeviceActivityManager.shared.restoreShield(appToken: appToken)

        completeRestore()
    }
    
    private func completeRestore() {
        SleepTask.sleep(seconds: 0.5) {
            Haptics.successFeedback()
                        
            toastManager.info("Block Restored")
            dismiss()
            
            SleepTask.sleep(seconds: 0.15) {
                isRestoring = false
            }
        }
    }
    
    private func deleteBlock() throws {
        guard let appToken else { return }
        guard let block else { return }
        
        Haptics.feedback(style: .soft)

        // Remove from the shield
        DeviceActivityManager.shared.removeFromShield(appToken: appToken)
        
        // If the shield is open, the DeviceMonitor will look for BlockEntity and not found it.
        // Therefore it's we have nothing more to do to handle this case.
        
        // Delete the Core Data object
        try CoreDataStack.shared.deleteBlock(block)
        
        // Reset the streak
//        vm.breakStreak()
        
        dismiss()
        
        toastManager.info("Block Deleted.")
    }
}

#Preview {
    BlockRowDetails(block: nil)
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            BlockRowDetails(block: nil)
        }
}
