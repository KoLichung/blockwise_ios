//
//  OBQuizProfile.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/06/25.
//

import SwiftUI

enum OBQuizProfilePhase {
    case one, two, three, four, five
}

struct OBQuizProfile: View {
    @EnvironmentObject var vm: OBUserViewModel
    @State private var appearAnimation: Bool = false

    @State private var color: Color = Color.primaryBlue
        
    let cardCornerRadius: CGFloat = 32.0

    var body: some View {
        VStack(spacing: 32) {
            Space(height: 20)
            
            VStack(spacing: 14) {
//                Text("Completed".uppercased())
//                    .font(.footnote.weight(.medium))
//                    .foregroundStyle(Color.primaryBlue)
//                    .kerning(1.0)
                
                Text("Here's your profile")
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30).weight(.semibold))
                    .multilineTextAlignment(.center)
                
                Text("Your progress will be tracked here.")
                    .font(.grotesk(.subheadline, weight: .medium))
//                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .offset(y: appearAnimation ? 0 : 64)
            .opacity(appearAnimation ? 1 : 0)

            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .aspectRatio(0.75, contentMode: .fit)
                .foregroundStyle(color.gradient)
                .brightness(-0.10)
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 6)
                .overlay {
                    RoundedRectangle(cornerRadius: cardCornerRadius - 6, style: .continuous)
                        .stroke(lineWidth: 4.0)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .white.opacity(0.25), radius: 6, x: 0, y: 0)
                        .brightness(0.6)
                        .opacity(0.25)
                        .padding(10)
                }
                .overlay(alignment: .topLeading) {
                    LogoShape()
                        .frame(square: 56)
                        .foregroundStyle(.white)
                        .padding(32)
                }
                .overlay {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Active Streak")
//                            .font(.subheadline.weight(.medium))
                            .font(.grotesk(.subheadline, weight: .medium))
                            .opacity(0.6)
                        
                        Text("0 days")
//                            .font(.system(size: 32).weight(.medium))
                            .font(.grotesk(size: 32, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: -118)
                    .padding(.horizontal, 32)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 100)
                        .foregroundStyle(.thinMaterial)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cardCornerRadius, bottomTrailingRadius: cardCornerRadius, topTrailingRadius: 0, style: .continuous))
                        .overlay {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(.grotesk(.footnote, weight: .medium))
                                        .foregroundStyle(Color.primaryBlue)

                                    Text("\(vm.firstName)")
                                        .font(.grotesk(.title3, weight: .medium))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Daily goal")
                                        .foregroundStyle(Color.primaryBlue)
                                        .font(.grotesk(.footnote, weight: .medium))
                                    
                                    Text(TimeFormatter.display(vm.screenTimeGoal, style: .short))
                                        .font(.grotesk(.title3, weight: .medium))
                                }

                            }
                            .padding(.horizontal, 32)
                        }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(y: appearAnimation ? 0 : 500)
                .rotation3DEffect(.degrees(appearAnimation ? 2 : 45), axis: (1, 0, 0))
                .opacity(appearAnimation ? 1 : 0)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        SleepTask.sleep(seconds: 0.10) {
            withAnimation(.smooth(duration: 0.45, extraBounce: 0.15)) {
                appearAnimation = true
            }
        }
    }

    private func action() {
        vm.nextStep()
        vm.showSetupProgress = false
        vm.mixPanelTrack(name: "Quiz Profile Card")
    }

}

#Preview {
    OBQuizProfile()
        .environmentObject(OBUserViewModel())
}
