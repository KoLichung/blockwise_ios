//
//  OBSixteenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI
import Lottie

enum PositiveStep: Int, CaseIterable {
    case one = 0, two, three, four
    
    static let last: Int = PositiveStep.four.rawValue
    
    var header: String {
        switch self {
        case .one: return "Time Reclaimed"
        case .two: return "Natural Rewards"
        case .three: return "Deep Control"
        case .four: return "Real Growth"
        }
    }

    var emoji: String {
        switch self {
        case .one: return "kite"
        case .two: return "battery-full"
        case .three: return "man-muscle"
        case .four: return "star-struck"
        }
    }
    
    var title: String {
        switch self {
        case .one: return "You can Change"
        case .two: return "Rewire your brain"
        case .three: return "Conquer yourself"
        case .four: return "Level up your life"
        }
    }
    
    var description: String {
        switch self {
        case .one:
            return "Create space for what matters: your goals, your people, your peace."
        case .two:
            return "As your brain resets, small wins feel good again, and you chase better ones."
        case .three:
            return "Focus becomes easier. You act with intention, not impulse."
        case .four:
            return "With clarity and energy, you start building the life you actually want."
        }
    }
}

struct OBSixteenView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var currentIndex: Int = 0
    
    @State private var backgroundColor: Color = Color.primaryBlue
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(PositiveStep.allCases, id: \.self) { step in
                    PageView(step)
                        .tag(step.rawValue)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
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
//        .background(background)
        .background {
            backgroundColor.opacity(0.15)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func PageView(_ step: PositiveStep) -> some View {
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
    
    private func action() {
        // Call MixPanel
        
        // Update UserViewModel
        
        // Continue
        if currentIndex != PositiveStep.last {
            withAnimation {
                currentIndex += 1
            }
        } else {
//            dismiss()
            vm.goToNextStep(step: 17)
        }
    }
    
}

#Preview {
    OBSixteenView()
        .environmentObject(OBUserViewModel())
}
