//
//  LimitView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/02/26.
//

import SwiftUI
import Lottie

struct LimitView: View {
    @StateObject private var vm = LimitViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var durationViewModel: DurationViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var appearAnimation = false
    @State private var showStreakWarning = false
    @State private var pendingAction: UnlockAction?
    
    let completion: () -> Void
    
    enum UnlockAction: Equatable {
        case thirtyMinutes
        case tenMinutes
        case oneMinute(breaksStreak: Bool)
        
        var duration: Int {
            switch self {
            case .thirtyMinutes: return 30
            case .tenMinutes: return 10
            case .oneMinute: return 1
            }
        }
        
        var breaksStreak: Bool {
            switch self {
            case .thirtyMinutes, .tenMinutes: return true
            case .oneMinute(let breaks): return breaks
            }
        }
    }
    
    var body: some View {
        ZStack {
            if vm.showDurationPicker {
                durationPickerView
                    .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
            } else {
                countdownView
                    .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Theme.backgroundC.opacity(appearAnimation ? 1 : 0), ignoresSafeAreaEdges: .all)
        .animation(.smooth, value: appearAnimation)
        .safeAreaInset(edge: .bottom) {
            bottomButtons
        }
        .onAppear(perform: setup)
        .onDisappear(perform: vm.stopTimer)
        .alert("You'll lose your streak", isPresented: $showStreakWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Continue Anyway", role: .destructive) {
                Haptics.feedback(style: .rigid)
                performPendingAction()
            }
        } message: {
            Text("Opening a block after reaching your daily limit will reset your streak. Are you sure?")
        }
    }
    
    // MARK: - Subviews
    
    private var bottomButtons: some View {
        VStack(spacing: 28) {
            GlassButton("Nevermind") {
                completion()
            }
            .padding(.horizontal, 32)
            
            Button("Choose duration (\(vm.timeRemaining)s)") {
                withAnimation {
                    vm.showDurationPicker = true
                }
            }
            .font(.grotesk(.body, weight: .semibold))
            .disabled(!vm.isCompleted)
            .tint(.primary)
            .opacity(vm.showDurationPicker ? 0 : 1)
        }
        .offset(y: vm.showDurationPicker ? 32 : 0)
        .animation(.smooth, value: vm.isCompleted)
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth.delay(0.3), value: appearAnimation)
        .padding()
    }
    
    private var countdownView: some View {
        VStack(spacing: 32) {
            timerText
            instructionText
            if userViewModel.currentStreak > 0 {
                streakCard
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var timerText: some View {
        Group {
            Text("Please wait") +
            Text(" \(vm.timeRemaining)s").foregroundStyle(.skyBlue)
        }
        .font(.grotesk(size: 32, weight: .semibold))
        .contentTransition(.numericText())
        .animation(.smooth, value: vm.timeRemaining)
        .foregroundStyle(.textC)
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth, value: appearAnimation)
    }
    
    private var instructionText: some View {
        Text("Reflect before you break your streak")
            .font(.grotesk(.body, weight: .regular))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
    }
    
    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(userViewModel.currentStreak)")
                    .font(.grotesk(size: 44, weight: .bold))
                    .foregroundStyle(.orange)
                
                Text("Streak Days")
                    .font(.grotesk(size: 24, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .offset(y: -6)
            
            Spacer()
            
            LottieView(animation: .named("fire"))
                .looping()
                .frame(square: 128)
                .background {
                    LottieView(animation: .named("fire"))
                        .looping()
                        .frame(square: 128)
                        .scaleEffect(1.1)
                        .brightness(1.0)
                        .shadow(radius: 8)
                        .offset(y: -2)
                }
                .offset(x: 40, y: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 92)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(Color.orange.opacity(0.15))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(lineWidth: 8.0)
                        .foregroundStyle(.orange.opacity(0.15))
                }
        }
        .mask {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth.delay(0.2), value: appearAnimation)
    }
    
    private var durationPickerView: some View {
        VStack(spacing: 32) {
            Text("How long do you need?")
                .font(.grotesk(size: 26, weight: .semibold))
                .foregroundStyle(.textC)
            
            VStack(spacing: 16) {
                unlockButton(
                    title: "Open for 30 minutes",
                    action: .thirtyMinutes
                )
                
                unlockButton(
                    title: "Open for 10 minutes",
                    action: .tenMinutes
                )
                
                oneMinuteButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var oneMinuteButton: some View {
        Group {
            if let token = durationViewModel.token {
                let alreadyUsed = UserDefaultsManager.shared.hasUsedPass(for: token)
                
                VStack(spacing: 10) {
                    unlockButton(
                        title: "Open for 1 minute",
                        action: .oneMinute(breaksStreak: alreadyUsed)
                    )
                    
                    Text(alreadyUsed
                         ? "Already used - opening will break your streak"
                         : "Once per day - won't affect the streak")
                        .font(.grotesk(.footnote, weight: .regular))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .lineSpacing(4.0)
                }
                .padding(.top, 12)
            }
        }
    }
    
    private func unlockButton(title: String, action: UnlockAction) -> some View {
        Button {
            handleUnlockAction(action)
        } label: {
            Text(title)
                .font(.grotesk(.title3, weight: .semibold))
                .foregroundStyle(.textC)
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
    
    // MARK: - Actions
    
    private func setup() {
        #if targetEnvironment(simulator)
        userViewModel.currentStreak = 18
        #endif
        
        vm.startTimer()
        
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func handleUnlockAction(_ action: UnlockAction) {
        pendingAction = action
        
        if action.breaksStreak {
            showStreakWarning = true
        } else {
            performPendingAction()
        }
    }
    
    private func performPendingAction() {
        guard let action = pendingAction else { return }
        
        // Set duration
        durationViewModel.duration = action.duration
        
        // Break streak if needed
        if action.breaksStreak {
            userViewModel.breakStreak()
        }
        
        Task {
            // Attempt unlock
            do {
                if action == .oneMinute(breaksStreak: false) {
                    try await durationViewModel.unlockLimitReached(breaksStreak: false)
                } else {
                    try await durationViewModel.unlockLimitReached(breaksStreak: true)
                }

                if let superlinkId = durationViewModel.block?.superlinkId,
                   let superlink = Superlink.find(by: superlinkId) {
                    try await Task.sleep(nanoseconds: 650_000_000)
                    try superlink.open {
                        toastManager.error("Could not open URL: \(superlink.urlScheme)")
                    }
                }
                
                // Mark 1-minute pass as used if applicable
                if case .oneMinute(breaksStreak: false) = action,
                   let token = durationViewModel.token {
                    UserDefaultsManager.shared.useMinutePass(for: token)
                }
                
                completion()
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
                completion()
            }
        }
    }
}

#Preview {
    LimitView {}
        .environmentObject(UserViewModel())
        .environmentObject(DurationViewModel())
        .environmentObject(ToastManager())
}
