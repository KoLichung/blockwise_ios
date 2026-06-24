//
//  OBFifteenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI
import Lottie

enum NegativeStep: Int, CaseIterable {
    case one = 0, two, three, four, five
    
    static let last: Int = NegativeStep.five.rawValue
    
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
        case .one: return "Distractions Steals your Time."
        case .two: return "Destroys your Reward System."
        case .three: return "Shortens your Attention Span."
        case .four: return "Destroys your Relationships."
        case .five: return "Drains your Energy."
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
            return "Mental fatigue, sleep loss, and constant switching leave you feeling burned out by 10am."
        }
    }
}

struct OBFifteenView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    
    @State private var currentIndex: Int = 0
    @State private var nextPage: Bool = false

    @State private var backgroundColors: [Color] = [.pink, .purple]
    
    var body: some View {
        
        if nextPage {
            OBSixteenView()
                .transition(.push(from: .trailing))
        } else {
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(NegativeStep.allCases, id: \.self) { step in
                        PageView(step)
                            .tag(step.rawValue)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
//            .overlay(alignment: .bottom) {
                Button {
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .frame(height: 60)
                        .overlay {
                            Text("Continue")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.background)
                        }
                }
                .padding(.horizontal)
                .padding()
            }
            .background {
                Color.red.opacity(0.15)
                    .ignoresSafeArea()
            }
            .transition(.push(from: .trailing))
        }

    }
    
    @ViewBuilder
    private func PageView(_ step: NegativeStep) -> some View {
        VStack(spacing: 44) {
            VStack(spacing: 14) {
                Text(step.header.uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text(step.title)
                    .font(.system(size: 32).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            LottieView(animation: .named(step.emoji))
                .looping()
                .frame(square: 230)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 8)
                .makeReflection(size: 250)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 22) {
                Text(step.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 32)

        }
        .padding(32)
        
    }
    
    private func updateBackgroundColors() {
        switch currentIndex {
        case 0: backgroundColors = [.pink, .purple]
        case 1: backgroundColors = [.orange, .red]
        case 2: backgroundColors = [.brown, .purple]
        case 3: backgroundColors = [.red, .pink]
        default: backgroundColors = [.pink, .purple]
        }
    }
    
    var background: some View {
        Circle()
            .foregroundStyle(
                .linearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .opacity(0.3)
            .blur(radius: 144)
            .animation(.smooth(duration: 0.3), value: backgroundColors)
    }
    
    private func action() {
        // Call MixPanel
        
        // Update UserViewModel
        
        // Continue
        if currentIndex != NegativeStep.last {
            withAnimation {
                currentIndex += 1
            }
        } else {
            withAnimation {
                nextPage = true
            }
        }
    }
    
}

#Preview {
    OBFifteenView()
}
