//
//  OBQuizCarouselTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/06/25.
//

import SwiftUI
import Lottie

struct OBQuizCarouselTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var currentIndex: Int = 0
    
    let height: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        
        TabView(selection: $currentIndex) {
            ForEach(OBPositiveStep.allCases, id: \.self) { step in
                PageView(step)
                    .tag(step.rawValue)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                if height > 800 {
                    HStack(spacing: 10) {
                        ForEach(OBPositiveStep.allCases, id: \.self) { step in
                            let isColored: Bool = step.rawValue <= currentIndex
                            
                            Circle()
                                .frame(square: 6)
                                .foregroundStyle(.secondary)
                                .opacity(0.15)
                                .overlay {
                                    Circle()
                                        .frame(square: 6)
                                        .foregroundStyle(Color.primaryBlue)
                                        .opacity(isColored ? 1 : 0)
                                        .scaleEffect(isColored ? 1 : 0.5)
                                }
                                .animation(.snappy(duration: 0.35, extraBounce: 0.25), value: currentIndex)
                        }
                    }
                }

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
            }
            .padding(32)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)

    }
    
    @ViewBuilder
    private func PageView(_ step: OBPositiveStep) -> some View {
        VStack(spacing: 44) {
            VStack(spacing: 14) {
//                Text(step.header.uppercased())
//                    .font(.footnote.weight(.medium))
//                    .foregroundStyle(Color.primaryBlue)
//                    .kerning(1.0)
                
                Text(step.title)
                    .font(.grotesk(size: 32, weight: .bold))
//                    .font(.system(size: 32).weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            }
            .padding(.top, 32)

            if height > 800 {
                LottieView(animation: .named(step.emoji))
                    .looping()
                    .frame(square: 200)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 6)
            } else {
                LottieView(animation: .named(step.emoji))
                    .looping()
                    .frame(square: 170)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 6)
            }

            VStack(spacing: 22) {
                Text(step.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineSpacing(6.0)
                    .font(.grotesk(.subheadline, weight: .regular))
            }

        }
        .padding(.horizontal, 32)

    }
            
    private func action() {
        // Call MixPanel
        
        // Update UserViewModel
        
        // Continue
        if currentIndex != OBPositiveStep.last {
            withAnimation {
                currentIndex += 1
            }
        } else {
            vm.nextStep()
            vm.showSetupProgress = true
            vm.mixPanelTrack(name: "Quiz Carousel 2")
        }
    }
    
}

enum OBPositiveStep: Int, CaseIterable {
    case one = 0, two, three, four
    
    static let last: Int = OBNegativeStep.four.rawValue
    
    var header: String {
        switch self {
        case .one: return "Recovery"
        case .two: return "Natural Rewards"
        case .three: return "Deep Sleep"
        case .four: return "Heal"
        }
    }

    var emoji: String {
        switch self {
        case .one: return "plant"
        case .two: return "relieved"
        case .three: return "sleep"
        case .four: return "battery-full"
        }
    }
    
    var title: String {
        switch self {
        case .one: return "You'll Feel Better than Ever"
        case .two: return "Get Back your Mental Clarity"
        case .three: return "Improve your Sleep Quality"
        case .four: return "Restore your Full Brain Power"
        }
    }
    
    var description: String {
        switch self {
        case .one:
            return "When screen use decreases, brain regions responsible for attention recover, enabling you to engage deeply and create more."
        case .two:
            return "Without constant dopamine spikes, your brain heals. Real life begin to feel rewarding again."
        case .three:
            return "Reducing screen time decreases cognitive overstimulation, promoting mental calmness and improving sleep quality."
        case .four:
            return "With fewer interruptions, your brain reduces cognitive fatigue, improving processing speed and boosting energy levels."
        }
    }
}

#Preview {
    OBQuizCarouselTwo()
        .environmentObject(OBUserViewModel())
}
