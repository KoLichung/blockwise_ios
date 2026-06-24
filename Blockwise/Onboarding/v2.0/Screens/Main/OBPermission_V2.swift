//
//  OBPermission_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 20/01/26.
//

import SwiftUI
import FamilyControls

struct OBPermission_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var showChevron: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(spacing: 14) {
                Text("Connect to Screen Time")
                    .font(.grotesk(size: 28, weight: .semibold))
                    .foregroundStyle(.textC)
                    .multilineTextAlignment(.center)
                
                Text("Your data is completely private and never leaves your device.")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .lineSpacing(2.0)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            
            Image(.connectScreenTime)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 64)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
                                    
//            Text("Let's make the magic work.")
//                .font(.grotesk(.title3, weight: .regular))
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.2), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton("Connect Screen Time") {
                    action()
                }
                .padding(.horizontal, 32)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)

                HStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("Secured by Apple")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(.secondary.opacity(0.15))
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.35), value: appearAnimation)

            }
            .padding()
        }
        .overlay {
            FamilyAuth()
        }
        .alert("\(AppConfiguration.name) couldn't access Screen Time", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage.isEmpty ? "Something went wrong while connecting to Screen Time. Please try again." : errorMessage)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        #if targetEnvironment(simulator)
        vm.nextPage()
        #else
        requestAuth()
        #endif
    }
    
    @MainActor
    private func requestAuth() {
        isLoading = true
        
        SleepTask.sleep(seconds: 1.55) {
            showChevron = true
        }
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                isLoading = false
                showChevron = false
                // Completed
                vm.nextPage(progressTwo: 1.0)
                
                // Mixpanel
                AnalyticsService.shared.track("OBV2 > Auth granted")

            } catch {
                Logger.error(error.localizedDescription)
                isLoading = false
                showChevron = false

                if let fcError = error as? FamilyControlsError {
                    switch fcError {
                    case .authorizationConflict:
                        errorMessage = "Another app is already authorized to manage Screen Time controls. You can revoke that app’s access in Settings > Screen Time, then try again."
                    case .authorizationCanceled:
                        errorMessage = "The authorization was canceled. Please try again to connect Screen Time."
                    case .invalidArgument:
                        errorMessage = "We sent an invalid request. Please try again. If the problem persists, contact support."
                    case .unavailable:
                        errorMessage = "Screen Time controls are currently unavailable. Please restart your device and try again."
                    case .restricted:
                        errorMessage = "Screen Time is restricted on this device. Check Settings > Screen Time and ensure restrictions allow this app to use Screen Time."
                    case .networkError:
                        errorMessage = "A network connection is required to enroll with Screen Time. Please check your internet connection and try again."
                    case .authenticationMethodUnavailable:
                        errorMessage = "A device passcode is required to enroll with Screen Time. Set a passcode in Settings and try again."
                    default:
                        errorMessage = "An unknown Screen Time error occurred. Please try again."
                    }
                } else {
                    errorMessage = "An unexpected error occurred. Please try again."
                }
                
                // Error
                showError = true
            }
        }
    }
    
    @ViewBuilder
    private func FamilyAuth() -> some View {
        let height: CGFloat = UIScreen.main.bounds.height

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
                        x: -75,
                        y: height * 0.2
                    )
            }
        }
        .opacity(isLoading ? 1 : 0)
        .animation(.smooth(duration: 0.35), value: showChevron)
        .animation(.smooth(duration: 0.35), value: isLoading)
    }

}

#Preview {
    OBPermission_V2()
        .environmentObject(OBVM_V2())
}
