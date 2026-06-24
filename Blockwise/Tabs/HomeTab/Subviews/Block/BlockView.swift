//
//  BlockView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/02/26.
//

import SwiftUI
import ManagedSettings

struct BlockView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var userViewModel: UserViewModel
    
    @StateObject private var vm = BlockViewModel()
    
    let block: BlockEntity?
    
    var screenTimeGoal: TimeInterval {
        userViewModel.user?.goal(for: .now) ?? 3600 // 1 hour if any error
    }
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 18) {
                        Button {
                            vm.showButtonDelayPicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Button delay")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text(block?.buttonDelay == 0 ? "No delay" : TimeFormatter.display(block?.buttonDelay ?? 0, style: .spaced))
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText(value: block?.buttonDelay ?? 0))
                                        .animation(.smooth, value: block?.buttonDelay ?? 0)
                                }
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
                        .tint(.primary)

                        Button {
                            vm.showMaxDurationPicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Max. Duration")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text("Up to \(TimeFormatter.display(block?.maxDuration ?? 0, style: .spaced))")
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText(value: block?.maxDuration ?? 0))
                                        .animation(.smooth, value: block?.maxDuration ?? 0)
                                }
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
                        .tint(.primary)

                        Button {
                            if let endTime = block?.openEndTime, Date.now <= endTime {
                                // Block is currently open
                                showAlert = true
                                alertTitle = "Block is Open"
                                alertMessage = "You can't change recharge time while the app is open. Close it first or wait for it to close automatically."
                            } else if let nextAvailableDate = block?.nextAvailableDate, Date.now < nextAvailableDate {
                                // Block is recharging
                                showAlert = true
                                alertTitle = "Block is Recharging"
                                alertMessage = "You can't change recharge time while the block is recharging. Wait for it to become available."
                            } else {
                                vm.showRechargeTimePicker = true
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Recharge time")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text((block?.cooldown ?? 0) > 0 ? TimeFormatter.display(block?.cooldown ?? 0, style: .spaced) : "No recharge")
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText(value: block?.cooldown ?? 0))
                                        .animation(.smooth, value: block?.cooldown ?? 0)
                                }
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
                        .tint(.primary)
                    }
                    
                    superlinkButton
                    
                    deleteButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(isPresented: $vm.showButtonDelayPicker) {
                ButtonDelayPicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $vm.showMaxDurationPicker) {
                MaxDurationPicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $vm.showRechargeTimePicker) {
                RechargeTimePicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $vm.showLinkAppView) {
                SuperlinkListView()
                    .environmentObject(vm)
            }
            .sheet(isPresented: $vm.showDeleteReason) {
                DeleteReasonView()
                    .environmentObject(vm)
            }
            .toolbar {
                                
                ToolbarItem(placement: .title) {
                    if let appToken {
                        Label(appToken)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.5)
                        
                        Label(appToken)
                            .labelStyle(.titleOnly)
                            .scaleEffect(0.9)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $vm.removeSuperLinkAlert) {
                Button("Cancel", role: .cancel) {
                    
                }
                .tint(.primary)
                
                Button("Yes") {
                    do {
                        try vm.removeSuperlink()
                    } catch {
                        Logger.error(error.localizedDescription)
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Okay", role: .cancel) {
                    
                }
                .tint(.primary)
            } message: {
                Text(alertMessage)
            }

        }
        .onAppear(perform: setup)
        .onDisappear(perform: vm.stopTimer)
    }
    
    private func setup() {
        vm.block = block
        vm.dismissAll = dismiss
        
        vm.startTimer()
    }
    
    // Computed properties
    var appToken: ApplicationToken? {
        guard let block else { return nil }
        guard let tokenString = block.appTokenString else { return nil }
        return ApplicationToken.fromRawValue(tokenString)
    }
    
    @ViewBuilder
    var deleteButton: some View {
        
        if let block, block.isOpen {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Delete disabled")
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
                .opacity(0.5)
                
                Text("Block deletion is disabled while app is open.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .lineSpacing(4.0)
            }
        } else if let nextAvailableDate = block?.nextAvailableDate, Date.now < nextAvailableDate {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Delete disabled")
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
                .opacity(0.5)
                
                Text("Block deletion is disabled while block is recharging.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .lineSpacing(4.0)
            }

        } else {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    guard vm.isButtonEnabled else { return }
                    vm.showDeleteReason = true
                    Haptics.feedback(style: .light)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 14) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .semibold))

                            Text("Delete \(!vm.isButtonEnabled ? "available in \(vm.timeRemaining)s" :"block")")
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
    }
    
    @ViewBuilder
    var superlinkButton: some View {
        if let superlinkId = block?.superlinkId, let superlink = Superlink.find(by: superlinkId) {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    vm.removeSuperLinkAlert = true
                    alertTitle = "Remove Superlink?"
                    alertMessage = "This block will no longer be linked to \(superlink.name)"
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            let checkSize: CGFloat = 32.0
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .textC,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 12,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)
                            
                            Text("Superlinked")
                                .font(.grotesk(.title3, weight: .semibold))
                                .foregroundStyle(.textC)
                        }
                    }
                    .padding(.trailing, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Image(superlink.asset)
                            .resizable()
                            .scaledToFit()
                            .appIconStyle(size: 36)
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .foregroundStyle(.secondary.opacity(0.1))
                            }
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 28)
                    }
                }
                .tint(.primary)
                
                Text("Superlinked with \(superlink.name). Tap to remove.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .lineSpacing(4.0)
            }
        } else {
            // Set superlink
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    vm.showLinkAppView = true
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Superlink app")
                            .font(.grotesk(.title3, weight: .semibold))
                            .foregroundStyle(.textC)
                    }
                    .padding(.trailing, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.secondary.opacity(0.75))
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .foregroundStyle(.secondary.opacity(0.15))
                            }
                    }
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 28)
                    }
                }
                .tint(.primary)
                
                Text("Superlink allows you to be automatically redirected to the blocked app after tapping “Open for X minutes“.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .lineSpacing(4.0)
            }
        }
    }
    
    @ViewBuilder
    private func ButtonDelayPicker() -> some View {
        let currentValue: Double = block?.buttonDelay ?? 0
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Button Delay Picker", selection: $vm.inputButtonDelayValue) {
                    ForEach(Array(stride(from: 0, through: 60, by: 5)), id: \.self) { value in
                        let tagValue = Double(value)

                        if value == 0 {
                            Text("No delay")
                                .font(.grotesk(size: 18.5, weight: .regular))
                                .tag(tagValue)
                        } else {
                            Text(TimeFormatter.display(Double(value), style: .spaced))
                                .font(.grotesk(size: 18.5, weight: .regular))
                                .tag(tagValue)
                        }
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Apply changes") {
                    guard let block else {
                        dismiss()
                        toastManager.error("Something went wrong")
                        return
                    }
                    
                    block.buttonDelay = vm.inputButtonDelayValue
                    
                    do {
                        try CoreDataStack.shared.saveContext()
                    } catch {
                        Logger.error(error.localizedDescription)
                        toastManager.error(error.localizedDescription)
                    }
                    
                    vm.showButtonDelayPicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Button delay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.showButtonDelayInfo = true
                    } label: {
                        Image(systemName: "info")
                    }
                    .tint(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showButtonDelayPicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .onAppear {
                vm.inputButtonDelayValue = currentValue
            }
        }
        .sheet(isPresented: $vm.showButtonDelayInfo) {
            ButtonDelayInfoView()
        }
    }
    
    @ViewBuilder
    private func MaxDurationPicker() -> some View {
        let currentValue: Double = block?.maxDuration ?? 0
        let screenTimeGoalInMinutes: Int = Int(screenTimeGoal) / 60
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Max. Duration Picker", selection: $vm.inputMaxDurationValue) {
                    ForEach(Array(stride(from: 5, through: screenTimeGoalInMinutes, by: 5)), id: \.self) { value in
                        let valueInMinutes = Double(value * 60)

                        Text("Up to \(TimeFormatter.display(valueInMinutes, style: .spaced))")
                            .font(.grotesk(size: 18.5, weight: .regular))
                            .tag(valueInMinutes)
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Apply changes") {
                    guard let block else {
                        dismiss()
                        toastManager.error("Something went wrong")
                        return
                    }
                    
                    block.maxDuration = vm.inputMaxDurationValue
                    
                    do {
                        try CoreDataStack.shared.saveContext()
                    } catch {
                        Logger.error(error.localizedDescription)
                        toastManager.error(error.localizedDescription)
                    }
                    
                    vm.showMaxDurationPicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Max. Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.showMaxDurationInfo = true
                    } label: {
                        Image(systemName: "info")
                    }
                    .tint(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showMaxDurationPicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .onAppear {
                vm.inputMaxDurationValue = currentValue
            }
        }
        .sheet(isPresented: $vm.showMaxDurationInfo) {
            MaxDurationInfoView()
        }
    }

    @ViewBuilder
    private func RechargeTimePicker() -> some View {
        let currentValue: Double = block?.cooldown ?? 0
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Recharge Time Picker", selection: $vm.inputRechargeTimeValue) {
                    ForEach((Array(stride(from: 0, through: 60, by: 5)) + [1, 2, 3]).sorted(), id: \.self) { value in
                        let valueInMinutes = Double(value * 60)

                        if value == 0 {
                            Text("No recharge")
                                .font(.grotesk(size: 18.5, weight: .regular))
                                .tag(valueInMinutes)
                        } else {
                            Text(TimeFormatter.display(Double(valueInMinutes), style: .spaced))
                                .font(.grotesk(size: 18.5, weight: .regular))
                                .tag(valueInMinutes)
                        }
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Apply changes") {
                    guard let block else {
                        dismiss()
                        toastManager.error("Something went wrong")
                        return
                    }
                    
                    block.cooldown = vm.inputRechargeTimeValue
                    
                    do {
                        try CoreDataStack.shared.saveContext()
                    } catch {
                        Logger.error(error.localizedDescription)
                        toastManager.error(error.localizedDescription)
                    }
                    
                    vm.showRechargeTimePicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Recharge time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.showRechargeTimeInfo = true
                    } label: {
                        Image(systemName: "info")
                    }
                    .tint(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showRechargeTimePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .onAppear {
                vm.inputRechargeTimeValue = currentValue
            }
        }
        .sheet(isPresented: $vm.showRechargeTimeInfo) {
            RechargeTimeInfoView()
        }
    }
    
}

#Preview {
    BlockView(block: nil)
        .environmentObject(ToastManager())
        .environmentObject(UserViewModel())
}

#Preview("Button Delay Info") {
    ButtonDelayInfoView()
}

#Preview("Max Duration Info") {
    MaxDurationInfoView()
}

#Preview("Recharge Time Info") {
    RechargeTimeInfoView()
}

// MARK: INFO VIEWS

struct ButtonDelayInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    Image(.buttonDelayInfo)
                        .resizable()
                        .scaledToFit()
                        .padding(32)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What is Button delay?")
                            .font(.grotesk(.title2, weight: .bold))
                            .foregroundStyle(.textC)

                        Text("Button delay adds a countdown timer before you can open the blocked app. This creates a moment of friction that helps you think twice about whether you really want to use it.\n\n**Example:** With a 20-second delay, you'll need to wait 20 seconds before the open button becomes active.")
                            .font(.grotesk(.body, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }

                    WasThisHelpfulButtons(context: "What is Button delay?")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
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
            .navigationTitle("What is Button delay?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MaxDurationInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(.maxDurationInfo)
                        .resizable()
                        .scaledToFit()
                        .padding(32)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What is Max. Duration?")
                            .font(.grotesk(.title2, weight: .bold))
                            .foregroundStyle(.textC)
                        
                        Text("Max duration sets the maximum amount of time you can unlock the app for in a single session. In the time picker, you won't see durations higher than your max duration.\n\n**Important:** If you have less time remaining for the day than your max duration, the time remaining becomes your new max duration. For example, if your max duration is 15 minutes but you only have 10 minutes left today, your max duration will show as 10 minutes to prevent exceeding your daily screen time limit.")
                            .font(.grotesk(.body, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                    }
                    
                    WasThisHelpfulButtons(context: "What is Max. Duration?")

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
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
            .navigationTitle("What is Max. Duration?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RechargeTimeInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(.rechargeTimeInfo)
                        .resizable()
                        .scaledToFit()
                        .padding(32)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What is Recharge Time?")
                            .font(.grotesk(.title2, weight: .bold))
                            .foregroundStyle(.textC)
                        
                        Text("Recharge time is a cooldown period after you close the app. During this time, you won't be able to unlock the app again, preventing quick re-opens and encouraging longer breaks.\n\n**Example:** With a 30-minute recharge time, after closing the app, you'll need to wait 30 minutes before you can open it again.")
                            .font(.grotesk(.body, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    WasThisHelpfulButtons(context: "What is Recharge Time?")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
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
            .navigationTitle("What is Recharge Time?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
