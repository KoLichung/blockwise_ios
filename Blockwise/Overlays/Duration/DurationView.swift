//
//  DurationView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI

struct DurationView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.requestReview) var requestReview

    @AppStorage(AppStorageKeys.Main.showDuration.key) var showDuration: Bool = false

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    @FetchRequest(sortDescriptors: [], predicate: .today(for: "timestamp"))
    private var todaysRecords: FetchedResults<RecordEntity>
    
    @StateObject private var vm = DurationViewModel()
    
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Group {
                if let superlink {
                    Image(superlink.asset)
                        .resizable()
                        .scaledToFit()
                        .appIconStyle(size: 56)
                } else if let token = vm.token {
                    Label(token)
                        .labelStyle(.iconOnly)
                        .scaleEffect(2.75)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .frame(square: 56)
                        .foregroundStyle(.secondary.opacity(0.15))
                }
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)

            Text("How much time do you need?")
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .foregroundStyle(.textC)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)

            Picker("", selection: $vm.duration) {
                ForEach(range, id: \.self) { value in
                    let seconds = CGFloat(value) * 60
                    
                    Text(TimeFormatter.display(seconds, style: .spaced))
                        .font(.grotesk(size: 20, weight: .medium))
                        .tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)

            HStack(spacing: 10) {
                let progress: CGFloat = min(1, totalUsageToday / max(1, screenTimeGoal))
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(.secondary.opacity(0.15))
                    
                    Circle()
                        .trim(from: progress, to: 1)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .rotationEffect(.degrees(-90))
                }
                .frame(square: 16)
                
                Text("**\(TimeFormatter.display(availableTime, style: .short))** left today")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule(style: .continuous)
                    .foregroundStyle(.secondary.opacity(0.1))
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton(buttonTitle) {
                    guard vm.isButtonEnabled else { return }
                    
                    dismiss()

                    Task {
                        do {
                            try await vm.unlock(usage: totalUsageToday, goal: screenTimeGoal)
                        } catch {
                            Logger.error(error.localizedDescription)
                            toastManager.error(error.localizedDescription)
                        }
                    }

                    // Separate detached task for opening superlink
                    if let superlinkId = vm.block?.superlinkId,
                       let superlink = Superlink.find(by: superlinkId) {
                        Task.detached(priority: .userInitiated) {
                            try? await Task.sleep(nanoseconds: 650_000_000)
                            await MainActor.run {
                                try? superlink.open {
                                    toastManager.error("Could not open URL: \(superlink.urlScheme)")
                                }
                            }
                        }
                    }
                }
                .contentTransition(.numericText())
                .opacity(vm.isButtonEnabled ? 1 : 0.9)
                .padding(.horizontal, vm.isButtonEnabled ? 32 : 38)
                .animation(.easeInOut(duration: 0.3), value: vm.timeRemaining)
                .animation(.easeInOut(duration: 0.3), value: vm.isButtonEnabled)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
                
                Button("Not now") {
                    dismiss()
                }
                .font(.grotesk(.body, weight: .medium))
                .tint(Color.secondary)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
            }
            .padding()
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .overlay {
            if vm.isLimit {
                LimitView {
                    dismiss()
                }
                .environmentObject(vm)
            }
        }
        .onChange(of: scenePhase, handleSceneUpdate)
        .onDisappear(perform: vm.stopTimer)
        .onAppear(perform: setup)
        .onAppear(perform: log)
    }
    
    // MARK: Computed properties
    private var buttonTitle: String {
        if vm.isButtonEnabled {
            return "Open for \(TimeFormatter.display(TimeInterval(vm.duration * 60), style: .spaced))"
        } else {
            return "Wait \(vm.timeRemaining) seconds"
        }
    }
    
    var superlink: Superlink? {
        if let superlinkId = vm.block?.superlinkId, let slink = Superlink.find(by: superlinkId) {
            return slink
        }
        
        return nil
    }

//    var totalUsageToday: TimeInterval {
//        blocks.reduce(0) { usage, block in
//            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
//        }
//    }
    
    var totalUsageToday: TimeInterval {
        todaysRecords.reduce(0) { $0 + $1.duration }
    }
    
    var screenTimeGoal: TimeInterval {
        userViewModel.user?.goal(for: .now) ?? 3600 // 1 hour if any error
    }
    
    var availableTime: TimeInterval {
        max(0, screenTimeGoal - totalUsageToday)
    }
    
    var range: ClosedRange<Int> {
        let maxDuration: Double = vm.block?.maxDuration ?? 0
        
        // Convert to minutes
        let remainingMinutes = Int(availableTime / 60)
        let maxDurationMinutes = Int(maxDuration / 60)
        
        // Get the upper bound (whichever is smaller)
        let upperBound = min(maxDurationMinutes, remainingMinutes)
                
        // Ensure we have a valid range (at least 1...1)
        return 1...max(1, upperBound)
    }

    // MARK: Functions
    private func setup() {
        let remainingMinutes = Int(availableTime / 60)
        vm.duration = max(1, min(remainingMinutes, vm.duration))

        vm.isLimit = UserDefaultsManager.shared.isLimitReached()
        
        terminateOnBackground()
        
        do {
            try vm.loadBlock(blocks: blocks)
        } catch {
            toastManager.error(error.localizedDescription)
        }
        
        guard !vm.isLimit else { return }
        
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
        
        vm.startTimer()
        
        if let block = vm.block, (userViewModel.user?.dateCreated?.distance(to: .now) ?? 0) > (2 * 86400) {
            requestReview()
        }
    }
    
    private func dismiss() {
        showDuration = false
        UserDefaultsManager.shared.setToken(token: nil, value: false)
    }
    
    private func terminateOnBackground() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            dismiss()
        }
    }
    
    private func handleSceneUpdate(newValue: ScenePhase, oldValue: ScenePhase) {
        guard newValue == .background else { return }
        
        dismiss()
    }
    
    private func log() {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering DurationView")
        Logger.debug("")
        Logger.debug("Goal:")
        Logger.debug("  • \(TimeFormatter.display(screenTimeGoal, style: .short))")
        Logger.debug("")
        Logger.debug("-----------------------------------------------------------")
    }
}

#Preview {
    DurationView()
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
}
