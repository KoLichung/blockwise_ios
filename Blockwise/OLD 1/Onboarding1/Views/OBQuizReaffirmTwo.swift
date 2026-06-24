//
//  OBQuizReaffirmTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/06/25.
//

import SwiftUI
import Lottie

struct OBQuizReaffirmTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var appearAnimation: Bool = false
    @State private var showAward: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            
            VStack(alignment: .center, spacing: 32) {
                
                LottieView(animation: .named("party-popper"))
                    .looping().animationSpeed(1)
                    .frame(square: 150)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                Text("You are ready!")
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30, weight: .semibold))
                    .lineSpacing(2.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                
                Text("While everyone else is scrolling, you’re choosing to wake up.\nYou're special, \(vm.firstName)!")
                    .font(.grotesk(.title3, weight: .regular))
//                .font(.title3.weight(.regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(6.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.2), value: appearAnimation)
            }

        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                Circle()
                    .frame(square: 64)
                    .foregroundStyle(Color.primaryBlue)
                    .overlay {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.white)
                            .font(.system(size: 24.0).weight(.semibold))
                    }
            }
            .phaseAnimator([false, true]) { view, phase in
                view
                    .background {
                        Circle()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(Color.primaryBlue)
                            .scaleEffect(phase ? 1.8 : 1.0)
                            .opacity(phase ? 0.0 : 0.6)
                    }
            } animation: { phase in
                if phase {
                    .easeInOut(duration: 1.0)
                } else {
                    nil
                }
            }
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
            .padding(32)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }

    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
            showAward = true
        }
        
        SleepTask.sleep(seconds: 2.5) {
            showAward = false
        }
    }

    private func action() {
        // Create user
        do {
            try vm.createUser()
        } catch {
            toastManager.error(error.localizedDescription)
            Logger.error(error.localizedDescription)
        }
        
        vm.nextStep()
        
        vm.mixPanelTrack(name: "Quiz Reaffirm 2")
    }
}

#Preview {
    OBQuizReaffirmTwo()
        .environmentObject(OBUserViewModel())
}
