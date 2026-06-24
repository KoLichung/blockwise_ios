//
//  OBCongratulations.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/09/25.
//

import SwiftUI
import Lottie

struct OBCongratulations: View {
    @EnvironmentObject var vm: OBTutorialUserViewModel
//    @State private var appearAnimation: Bool = false
    @AppStorage("appearAnimation") var appearAnimation: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            
            VStack(alignment: .center, spacing: 32) {
                
                LottieView(animation: .named("clinking-beer"))
                    .looping()
                    .frame(square: 150)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                Text("Congratulations!")
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30, weight: .semibold))
                    .lineSpacing(2.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                
                Text("We're so proud of you for coming this far! Let's now start blocking some apps.")
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
            VStack(spacing: 32) {
                Image(systemName: "chevron.compact.down")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .phaseAnimator([true, false]) { view, phase in
                        view
                            .offset(y: phase ? 0 : -24)
                            .opacity(phase ? 0.5 : 0.3)
                    } animation: { _ in
                            .smooth(duration: 0.5)
                    }
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.45), value: appearAnimation)

                GlassButton {
                    action()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                        Text("How \(AppConfiguration.name) works?")
                    }
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                }
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
            }
            .padding(32)
        }
        .onAppear(perform: setup)
        .background(alignment: .top) {
            LottieView(animation: .named("confetti-animation-2"))
                .looping()
                .frame(height: 400)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }

    private func setup() {
        
    }

    private func action() {
        vm.nextStep()
    }
}

#Preview {
    OBCongratulations()
        .environmentObject(OBTutorialUserViewModel())
}
