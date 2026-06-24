//
//  OBQuizCarousel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/06/25.
//

import SwiftUI
import Lottie

struct OBQuizCarousel: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var currentIndex: Int = 0
    
    let height: CGFloat = UIScreen.main.bounds.height
    let background: Color = Color(hex: 0x200107)

    
    var body: some View {
        
        TabView(selection: $currentIndex) {
            ForEach(OBNegativeStep.allCases, id: \.self) { step in
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
                        ForEach(OBNegativeStep.allCases, id: \.self) { step in
                            let isColored: Bool = step.rawValue <= currentIndex
                            
                            Circle()
                                .frame(square: 6)
                                .foregroundStyle(.secondary)
                                .opacity(0.15)
                                .overlay {
                                    Circle()
                                        .frame(square: 6)
                                        .foregroundStyle(Color.pink)
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
                        .foregroundStyle(Color.pink)
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
                                .foregroundStyle(Color.pink)
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
        .background(background, ignoresSafeAreaEdges: .all)

    }
    
    @ViewBuilder
    private func PageView(_ step: OBNegativeStep) -> some View {
        VStack(spacing: 44) {
            VStack(spacing: 14) {
//                Text(step.header.uppercased())
//                    .font(.footnote.weight(.medium))
//                    .foregroundStyle(.pink)
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
        if currentIndex != OBNegativeStep.last {
            withAnimation {
                currentIndex += 1
            }
        } else {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz Carousel 1")
        }
    }
    
}

enum OBNegativeStep: Int, CaseIterable {
    case one = 0, two, three, four, five
    
    static let last: Int = OBNegativeStep.five.rawValue
    
    var header: String {
        switch self {
        case .one: return "Time Stolen"
        case .two: return "False Rewards"
        case .three: return "Attention Hijacked"
        case .four: return "Disconnected"
        case .five: return "Energy Drained"
        }
    }

    var emoji: String {
        switch self {
        case .one: return "dizzy-face"
        case .two: return "slot-machine"
        case .three: return "poop"
        case .four: return "broken-heart"
        case .five: return "battery-low"
        }
    }
    
    var title: String {
        switch self {
        case .one: return "Your Phone Hypnotizes You"
        case .two: return "Destroys your Reward System"
        case .three: return "Shortens your Attention Span"
        case .four: return "Destroys your Relationships"
        case .five: return "Drains your Brain's Energy"
        }
    }
    
    var description: String {
        switch self {
        case .one:
            return "Endless scrolling eats hours you’ll never get back, time that could’ve built your dreams."
        case .two:
            return "Apps flood your brain with cheap dopamine, making real rewards feel boring and out of reach."
        case .three:
            return "Every ping, post, and swipe trains your mind to crave noise, and forget how to go deep."
        case .four:
            return "You’re with people, but not really. Presence fades, and relationships slowly fray."
        case .five:
            return "Mental fatigue, sleep loss, and constant switching. Your brain is doing too much at once."
        }
    }
}

#Preview {
    OBQuizCarousel()
        .environmentObject(OBUserViewModel())
}
