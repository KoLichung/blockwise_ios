//
//  OBFiveView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI
import Lottie

struct OBFiveView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let question = "How do you feel after phone use?"
    let subtitle = "Question #5"

    let options: [OBOption] = [
        OBOption(emoji: "victory", label: "Proud", value: 9),
        OBOption(emoji: "slightly-frowning", label: "Neutral", value: 6),
        OBOption(emoji: "scrunched-eyes", label: "Guilty", value: 4),
        OBOption(emoji: "sad", label: "Regretful", value: 2)
    ]
    
    let columns: [GridItem] = .init(repeating: GridItem(spacing: 12), count: 2)
    
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
            
            LazyVGrid(columns: columns, spacing: 12) {
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
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                    .background {
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .opacity(isSelected ? 1.0 : 0.0)
                                    }
                                    .overlay {
                                        VStack(alignment: .center, spacing: 16) {
                                            LottieView(animation: .named(option.emoji))
                                                .looping()
                                                .frame(square: isSelected ? 85 : 72)
                                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 6)
                                            
                                            Text(option.label)
                                                .font(.headline)
                                                .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : Color.primary)
                                        }
                                        .padding(.horizontal, 22)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                            }
                        }
                    }

                }

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
        vm.selections.append(selectedOption.value)

        // Continue
        vm.goToNextStep(step: 6)
    }
    
    private func isSelected(_ option: OBOption) -> Bool {
        selectedOption == option
    }
}

#Preview {
    NavigationStack {
        OBFiveView()
            .environmentObject(OBUserViewModel())
    }
}
