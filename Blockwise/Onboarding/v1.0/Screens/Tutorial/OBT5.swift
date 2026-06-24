//
//  OBT5.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/12/25.
//

import SwiftUI
import AlarmKit

struct OBT5: View {
    @EnvironmentObject var vm: OBTVM
    @EnvironmentObject var lnManager: LocalNotificationManager
    
    @State private var appearAnimation: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var showChevron: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSettingsPrompt: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 14) {
                
                Text("See how much time you have left during a session")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)

                Text("Let the timer ease your mind while you're using distracting apps.")
                    .foregroundStyle(.secondary)
                    .font(.grotesk(.subheadline, weight: .regular))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

//            Image(.allowTimer)
//                .resizable()
//                .scaledToFit()
//                .overlay(alignment: .top) {
//                    RoundedRectangle(cornerRadius: 60, style: .continuous)
//                        .foregroundStyle(Color(hex: 0x181818))
//                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 8)
//                        .frame(height: 72)
//                        .frame(maxWidth: .infinity)
//                        .overlay {
//                            HStack {
//                                Image(.blockrIconTransparent)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(square: 40)
//
//                                Spacer()
//                                
//                                Text(Date.now.addingTimeInterval(5*60), style: .timer)
//                                    .foregroundStyle(.white)
//                                    .font(.grotesk(size: 40, weight: .regular))
//                            }
//                            .padding(20)
//                        }
//                        .padding(.horizontal, 18)
//                        .offset(y: 18)
//                        .scaleEffect(appearAnimation ? 1 : 0.85, anchor: .top)
//                }
//                .padding(.horizontal, 20)
//                .overlay {
//                    LinearGradient(
//                        colors: [
//                            .clear, .clear,
//                            .white
//                        ],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                }
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.2), value: appearAnimation)
//                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton {
                    action()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Allow & Continue")
                            .font(.grotesk(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }

                Button {
                    skipStep()
                } label: {
                    Text("Skip this step")
                        .font(.grotesk())
                }
                .tint(Color.secondary)
                .disabled(isLoading)
            }
            .padding(.horizontal, isLoading ? 64 : 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .overlay {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(square: 76)
                    .foregroundStyle(.thinMaterial)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isLoading ? 1 : 0.9)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: isLoading)
                
                if showChevron {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .phaseAnimator([true, false]) { view, phase in
                            view
                                .offset(y: phase ? -24 : 0)
                                .opacity(phase ? 1 : 0.75)
                        } animation: { _ in
                                .smooth(duration: 0.5)
                        }
                        .offset(
                            x: 75,
                            y: 200
                        )
                }

            }
            .opacity(isLoading ? 1 : 0)

        }
        .alert("Permission Denied", isPresented: $showSettingsPrompt) {
            Button("Open Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) {
                resetLoadingState()
            }
        } message: {
            Text("Alarm permissions are required for this feature. Please enable them in Settings.")
        }
        .alert("Operation could not be completed", isPresented: $showError) {
            Button("OK", role: .cancel) {
                resetLoadingState()
            }
        } message: {
            Text(errorMessage.isEmpty ? "Something went wrong. Please try again." : errorMessage)
        }
        .onAppear(perform: setup)
    }
    
    private func action() {
        guard !isLoading else { return }
        
        isLoading = true
        showChevron = false
        
        SleepTask.sleep(seconds: 0.25) {
            showChevron = true
        }

        Task {
            await requestAlarmAuthorization()
        }
    }
    
    @MainActor
    private func requestAlarmAuthorization() async {
        guard #available(iOS 26, *) else {
            // Fallback - this screen shouldn't appear on older iOS versions
            Logger.error("OBT5 shown on iOS < 26")
            completedAction()
            return
        }
        
        do {
            let authResult = try await checkAlarmKitAuth()
            
            switch authResult {
            case .authorized:
                lnManager.isAlarmAuthGranted = true
                completedAction()
                
            case .denied:
                lnManager.isAlarmAuthGranted = false
                showSettingsPrompt = true
                
            case .notDetermined:
                // This shouldn't happen after requestAuthorization
                lnManager.isAlarmAuthGranted = false
                errorMessage = "Unable to determine authorization status."
                showError = true
            @unknown default:
                lnManager.isAlarmAuthGranted = false
                errorMessage = "Unable to determine authorization status."
                showError = true
            }
            
        } catch {
            Logger.error("Alarm authorization error: \(error.localizedDescription)")
            lnManager.isAlarmAuthGranted = false
            
            // Provide more specific error messages
            if let alarmError = error as? AlarmKitError {
                errorMessage = handleAlarmKitError(alarmError)
            } else {
                errorMessage = "An unexpected error occurred. Please try again."
            }
            
            showError = true
        }
    }
    
    @available(iOS 26.0, *)
    private func checkAlarmKitAuth() async throws -> AlarmAuthorizationState {
        let currentState = AlarmManager.shared.authorizationState
        
        switch currentState {
        case .notDetermined:
            let status = try await AlarmManager.shared.requestAuthorization()
            return status
            
        case .denied:
            return .denied
            
        case .authorized:
            return .authorized
            
        @unknown default:
            Logger.error("Unknown alarm authorization state encountered")
            return .notDetermined
        }
    }
    
    private func handleAlarmKitError(_ error: AlarmKitError) -> String {
        // Customize based on actual AlarmKitError cases
        switch error {
        default:
            return "Unable to access alarm permissions. Please try again."
        }
    }
    
    private func completedAction() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
            isLoading = false
            showChevron = false
        }
        
        // Small delay before navigation for smoother transition
        SleepTask.sleep(seconds: 0.2) {
            vm.nextPage(progressBar: 1.0)
        }
    }
    
    private func skipStep() {
        lnManager.isAlarmAuthGranted = false
        Haptics.feedback(style: .light)
        vm.nextPage(progressBar: 1.0)
    }
    
    private func resetLoadingState() {
        withAnimation(.smooth(duration: 0.3)) {
            isLoading = false
            showChevron = false
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
        
        resetLoadingState()
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
}

// Helper enum for clearer authorization state handling
@available(iOS 26.0, *)
typealias AlarmAuthorizationState = AlarmManager.AuthorizationState

// Mock error type - adjust based on actual AlarmKit implementation
enum AlarmKitError: Error {
    case authorizationFailed
    case unavailable
}

#Preview {
    OBT5()
        .environmentObject(OBTVM())
        .environmentObject(LocalNotificationManager())
}
