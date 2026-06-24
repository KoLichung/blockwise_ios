//
//  OBQuizFive.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizFive: View {
    @EnvironmentObject var vm: OBUserViewModel

    @State private var selectedOptions: [OBOption] = []
    
    let options: [OBOption] = [
        OBOption(emoji: "📱", label: "Social Media", value: 2),
        OBOption(emoji: "📺", label: "Videos/TV shows", value: 5),
        OBOption(emoji: "🎮", label: "Gaming apps", value: 4),
        OBOption(emoji: "", label: "Other", value: 3)
    ]

    let questionNumber: Int = 5
    let question: String = "Where do you spend the most time on?"
    
    let color1: Color = Color.primaryBlue
    let color2: Color = Color.primaryOrange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Space(height: 20)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Question \(questionNumber)".uppercased())
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(color1)
                    .kerning(1.0)

                Text(question)
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30, weight: .semibold))
//                    .lineSpacing(2.0)
                
                Text("Select all answers that apply")
                    .foregroundStyle(.secondary.opacity(0.65))
                    .font(.grotesk(.subheadline))
            }

            VStack(spacing: 14) {
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    let isSelected = selectedOptions.contains(option)
                    
                    Button {
                        addRemove(option)
                    } label: {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .frame(height: 64)
                            .foregroundStyle(isSelected ? color1.opacity(0.1) : Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 64)
                                    .foregroundStyle(isSelected ? color1 : Color.white.opacity(0.0))
                            }
                            .overlay(alignment: .leading) {
                                HStack(spacing: 12) {
                                    
                                    Text(option.emoji)
                                        .font(.title2)
                                    
                                    Text(option.label)
//                                        .fontWeight(.medium)
                                        .font(.grotesk(.body, weight: .medium))

                                }
                                .padding(.horizontal)
                            }
                            .overlay(alignment: .trailing) {
                                Checkmark(
                                    size: 24,
                                    trigger: .isPresent(
                                        in: $selectedOptions,
                                        element: option
                                    ),
                                    backgroundColor: color1
                                )
                                .padding(.trailing, 22)
                            }
                    }
                    .tint(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
            .foregroundStyle(Color.accentBlue)
            .offset(y: selectedOptions.isEmpty ? 128 : 0)
            .animation(.smooth(duration: 0.25), value: selectedOptions)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }
    
    private func addRemove(_ option: OBOption) {
        if let index = selectedOptions.firstIndex(where: { $0.label == option.label }) {
            selectedOptions.remove(at: index)
        } else {
            selectedOptions.append(option)
        }
        Haptics.feedback(style: .light)
    }
    
    private func action() {
        guard !selectedOptions.isEmpty else { return }
        vm.nextStep()
        vm.mixPanelTrack(name: "Quiz 5")
    }
}

#Preview {
    OBQuizFive()
        .environmentObject(OBUserViewModel())
}
