//
//  OBSevenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI
import Lottie

struct OBSevenView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let question = "Do you get anxious without your phone?"
    let subtitle = "Question #7"

    let options: [OBOption] = [
        OBOption(emoji: "nerd-face", label: "Never", value: 5),
        OBOption(emoji: "balance-scale", label: "Sometimes", value: 4),
        OBOption(emoji: "police-car-light", label: "Always", value: 3)
    ]
    
    let descriptions: [String] = [
        "I'm comfortable without it",
        "I feel a little disconnected",
        "I feel lost without it"
    ]
    
    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 14) {
//                Text(subtitle.uppercased())
//                    .font(.footnote.weight(.semibold))
//                    .foregroundStyle(.secondary)
//                    .kerning(1.0)
                
                Text(question)
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    let isSelected = isSelected(option)
                                        
                    VStack(spacing: 14) {
                        Button {
                            Haptics.feedback(style: .light)
                            withAnimation(.snappy(duration: 0.25)) {
                                selectedOption = option
                            }
                        } label: {
                            VStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 200, style: .continuous)
                                    .frame(height: 100)
                                    .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                    .background {
                                        RoundedRectangle(cornerRadius: 200, style: .continuous)
                                            .frame(height: 100)
                                            .opacity(isSelected ? 1.0 : 0.0)
                                    }
                                    .overlay {
                                        HStack(alignment: .center, spacing: 18) {
                                            LottieView(animation: .named(option.emoji))
                                                .looping()
                                                .frame(square: isSelected ? 64 : 56)
                                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 6)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(option.label)
                                                    .font(.headline)
                                                    .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : Color.primary)
                                                
                                                Text(descriptions[index])
                                                    .font(.subheadline)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : Color.primary)
                                                    .opacity(0.7)
                                            }
                                        }
                                        .padding(.horizontal, 22)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

            }
        }
        .tint(.primary)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 32)
        .safeAreaInset(edge: .bottom) {
            Button("Continue") {
                action()
            }
            .foregroundStyle(
                selectedOption == nil ? Color.gray : Color.secondaryOrange
            )
            .padding(.horizontal)
        }
        .padding()
        .overlay(alignment: .top) {
            Image("ob-bg")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .offset(y: -164)
        }
        .background {
            Color.primaryOrange.opacity(0.1)
                .ignoresSafeArea()
        }
    }

    private func action() {
        // Check selection
        guard let selectedOption else { return }

        // Call MixPanel
        
        // Update UserViewModel
        
        // Continue
        vm.goToNextStep(step: 8)
    }
    
    private func isSelected(_ option: OBOption) -> Bool {
        selectedOption == option
    }
}

#Preview {
    NavigationStack {
        OBSevenView()
            .environmentObject(OBUserViewModel())
    }
}
