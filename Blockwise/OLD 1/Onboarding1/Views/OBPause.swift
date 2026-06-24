//
//  OBPause.swift
//  Blockwise
//
//  Created by Ivan Sanna on 25/06/25.
//

import SwiftUI
import Lottie

struct OBPause: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Space(height: 20)
            
            VStack(alignment: .center, spacing: 32) {
                
                LottieView(animation: .named("broken-chain"))
                    .looping()
                    .frame(square: 150)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                Text("You're breaking the loop.")
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30, weight: .semibold))
                    .lineSpacing(2.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                
                Text("The hardest part is seeing the truth. You’ve done that, and it’s something to be proud of!")
//                    .font(.title3.weight(.regular))
                    .font(.grotesk(.title3, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.65))
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
        }
    }
    
    private func action() {
        vm.nextStep()
        vm.mixPanelTrack(name: "Quiz Pause")
    }
}

#Preview {
    OBPause()
        .environmentObject(OBUserViewModel())
}
