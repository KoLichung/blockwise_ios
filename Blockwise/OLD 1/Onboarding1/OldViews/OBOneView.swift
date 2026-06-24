//
//  OBOneView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct OBOneView: View {
    let customOrange: Color = Color(hex: 0xFB8C00)
    let darkOrange: Color = Color(hex: 0xE65100)

    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let question = "What's your daily Screen Time?"
    let subtitle = "Question #1"

    let options: [OBOption] = [
        OBOption(emoji: "🕐", label: "Less than 3 hours", value: 8),
        OBOption(emoji: "🕒", label: "3-5 hours", value: 6),
        OBOption(emoji: "🕔", label: "5-7 hours", value: 4),
        OBOption(emoji: "🕘", label: "More than 7 hours", value: 3)
    ]

    // Not used
    let descriptions: [String] = [
        "You're doing okay, keep it up",
        "Pretty common. But imagine what you could do with more time.",
        "We get it. Your phone is designed to be addictive.",
        "You're not alone. Let's change this together."
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 48) {
            VStack(alignment: .center, spacing: 14) {
//                Text(subtitle.uppercased())
//                    .font(.footnote.weight(.semibold))
//                    .foregroundStyle(.secondary)
//                    .kerning(1.0)
                
                Text(question)
                    .font(.system(size: 30).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            }
            
            VStack(spacing: 14) {
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
                                RoundedRectangle(cornerRadius: 140, style: .continuous)
                                    .frame(height: 55)
                                    .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                    .background {
                                        RoundedRectangle(cornerRadius: 140, style: .continuous)
                                            .frame(height: 55)
                                            .opacity(isSelected ? 1.0 : 0.0)
                                            .foregroundStyle(Color.primaryOrange.opacity(0.3))
                                    }
                                    .overlay {
                                        HStack(spacing: 12) {
                                            if option.emoji != "" {
                                                Text(option.emoji)
                                                    .font(.title2)
                                            }
                                            
                                            Text(option.label)
                                                .font(.headline)
                                                .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : Color.primary)
                                        }
                                        .padding(.horizontal, 22)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                            }
                        }
                        
//                        if selectedOption == option {
//                            Text(descriptions[index])
//                                .font(.footnote)
//                                .multilineTextAlignment(.leading)
//                                .foregroundStyle(.secondary)
//                                .frame(height: 22, alignment: .top)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal)
//                        }
                        
                    }

                }
            }
        }
        .tint(.primary)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .background {
//            Color.primaryOrange.opacity(0.1)
//                .ignoresSafeArea()
        }
    }
    
    private func action() {
        // Check selection
        guard let selectedOption else { return }

        // Call MixPanel
        
        // Update UserViewModel
        vm.selections.append(selectedOption.value)
        
        // Continue
        vm.goToNextStep(step: 2)
    }
    
    private func isSelected(_ option: OBOption) -> Bool {
        selectedOption == option
    }
}

#Preview {
    NavigationStack {
        OBOneView()
            .environmentObject(OBUserViewModel())
    }
}
