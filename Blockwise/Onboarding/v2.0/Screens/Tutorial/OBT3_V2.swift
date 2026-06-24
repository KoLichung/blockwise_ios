//
//  OBT3_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI
import AlarmKit

struct OBT3_V2: View {
    @EnvironmentObject var vm: OBTVM_V2
    
    @State private var appearAnimation: Bool = false
    @State private var isAuth: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var showChevron: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var errorTitle: String = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
            VStack(spacing: 14) {
                Text("Enable Usage Timer")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("A live activity timer shows your remaining time and notifies you when your session ends")
                    .lineSpacing(4.0)
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                let height = geo.size.height
                
                Image(.iphoneIg)
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .opacity(0.5)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 60, style: .continuous)
                            .foregroundStyle(Color(hex: 0x181818))
                            .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 8)
                            .frame(height: 72)
                            .frame(maxWidth: .infinity)
                            .overlay {
                                HStack {
//                                    Image(.blockrIconTransparent)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(square: 32)
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 4.0)
                                            .foregroundStyle(.fillOrange)
                                            .opacity(0.45)
                                        
                                        Circle()
                                            .trim(from: 0, to: appearAnimation ? 0 : 1)
                                            .rotation(.degrees(-90))
                                            .stroke(style: .init(lineWidth: 4.0, lineCap: .round))
                                            .foregroundStyle(.fillOrange)
                                            .animation(.linear(duration: 1 * 60), value: appearAnimation)
                                        
                                        Capsule()
                                            .frame(width: 5, height: 12)
                                            .foregroundStyle(.fillOrange)
                                            .offset(y: -6)
                                            .rotationEffect(.degrees(appearAnimation ? 0 : 360))
                                            .animation(.linear(duration: 1 * 60), value: appearAnimation)
                                    }
                                    .frame(square: 38)

                                    Spacer()
                                    
                                    Text(Date.now.addingTimeInterval(1*60), style: .timer)
                                        .foregroundStyle(.white)
                                        .font(.grotesk(size: 40, weight: .regular))
                                }
                                .padding(20)
                            }
                            .padding(.horizontal, 18)
                            .scaleEffect(appearAnimation ? 1.05 : 0.25, anchor: .top)
                            .offset(y: 48)
                    }
                    .offset(y: height * 0.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.2), value: appearAnimation)

            }

        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    .clear,
                    Color(UIColor.systemBackground).opacity(0.95),
                    Color(UIColor.systemBackground),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .frame(height: 100)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Allow & Continue") {
                    allowAndAction()
                }
                
                Button("Skip this step") {
                    action()
                }
                .font(.grotesk(.body, weight: .regular))
                .foregroundStyle(.secondary)
            }
            .padding()
            .padding(.horizontal, 32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .overlay {
            AlarmAuth()
        }
        .alert(errorTitle, isPresented: $showError) {
            if errorTitle == "Permission Denied" {
                Button("Settings") {
                    openAppSettings()
                }
                .keyboardShortcut(.defaultAction)
                
                Button("Skip", role: .cancel) {
                    action()
                }
            } else {
                Button("Try Again") {
                    allowAndAction()
                }
                Button("Skip", role: .cancel) {
                    action()
                }
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear(perform: setup)
    }
    
    @ViewBuilder
    private func AlarmAuth() -> some View {
        let height: CGFloat = UIScreen.main.bounds.height

        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .frame(square: 76)
//                .foregroundStyle(.thinMaterial)
//                .overlay {
//                    ProgressView()
//                        .controlSize(.large)
//                        .foregroundStyle(.white)
//                }
//                .scaleEffect(isLoading ? 1 : 0.9)
//                .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: isLoading)

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
                        y: height * 0.25
                    )
            }
        }
        .opacity(isLoading ? 1 : 0)
        .animation(.smooth(duration: 0.35), value: showChevron)
        .animation(.smooth(duration: 0.35), value: isLoading)
    }

    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func allowAndAction() {
        isLoading = true
        
        SleepTask.sleep(seconds: 0.5) {
            showChevron = true
        }

        if #available(iOS 26.0, *) {
            Task {
                do {
                    try await checkAlarmKitAuth {
                        isLoading = false
                        showChevron = false
                        
                        vm.nextPage()
                    }
                } catch {
                    isLoading = false
                    showChevron = false
                    handleAuthError(error)
                }
            }
        } else {
            // Handle iOS versions below 26.0
            isLoading = false
            showChevron = false
            errorTitle = "iOS Update Required"
            errorMessage = "Timer alerts require iOS 26.0 or later. Please update your device to enable this feature."
            showError = true
        }
    }
    
    private func action() {
        vm.nextPage()
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        // Optionally skip to next page after opening settings
        action()
    }

    @available(iOS 26.0, *)
    private func checkAlarmKitAuth(completion: @escaping () -> Void) async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            let status = try await AlarmManager.shared.requestAuthorization()
            isAuth = status == .authorized
            LocalNotificationManager.shared.isAlarmAuthGranted = isAuth
            
            if !isAuth {
                throw AlarmAuthError.userDenied
            }
            
        case .denied:
            isAuth = false
            LocalNotificationManager.shared.isAlarmAuthGranted = isAuth
            throw AlarmAuthError.previouslyDenied
            
        case .authorized:
            isAuth = true
            LocalNotificationManager.shared.isAlarmAuthGranted = isAuth
            
        @unknown default:
            throw AlarmAuthError.unknownState
        }
        
        completion()
    }
    
    private func handleAuthError(_ error: Error) {
        if let alarmError = error as? AlarmAuthError {
            switch alarmError {
            case .userDenied:
                errorTitle = "Permission Required"
                errorMessage = "Timer alerts keep you accountable by notifying you when time's up. You can enable this later in Settings."
                
            case .previouslyDenied:
                errorTitle = "Permission Denied"
                errorMessage = "Timer alerts need permission to notify you. Tap \"Settings\" below to enable notifications and alarms for \(AppConfiguration.name)."
                
            case .unknownState:
                errorTitle = "Unable to Enable"
                errorMessage = "An unexpected error occurred. Please restart the app and try again."
            }
        } else {
            errorTitle = "Something Went Wrong"
            errorMessage = "We couldn't enable timer alerts right now. Please try again or skip this step."
        }
        
        showError = true
    }
}

// MARK: - Error Types
enum AlarmAuthError: LocalizedError {
    case userDenied
    case previouslyDenied
    case unknownState
    
    var errorDescription: String? {
        switch self {
        case .userDenied:
            return "User denied authorization"
        case .previouslyDenied:
            return "Authorization was previously denied"
        case .unknownState:
            return "Unknown authorization state"
        }
    }
}

#Preview {
    OBT3_V2()
        .environmentObject(OBTVM_V2())
        .environmentObject(LocalNotificationManager())
}
