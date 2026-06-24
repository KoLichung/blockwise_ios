//
//  OBQuizSix.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

struct OBQuizSix: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let options: [OBOption] = [
        OBOption(emoji: "police-car-light", label: "Always", value: 8),
        OBOption(emoji: "balance-scale", label: "Sometimes", value: 6),
        OBOption(emoji: "nerd-face", label: "Never", value: 4)
    ]
    
    let descriptions: [String] = [
        "I feel lost without it",
        "I feel a little disconnected",
        "I'm fine without it"
    ]
    
    let questionNumber: Int = 6
    let question: String = "Do you feel uneasy when you don't have your phone?"
    
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
                
                Text("For example, when it's turned off.")
                    .foregroundStyle(.secondary.opacity(0.65))
                    .font(.grotesk(.subheadline))
            }

            VStack(spacing: 14) {
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    let isSelected = selectedOption == option
                    
                    Button {
                        action(option: option)
                    } label: {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .frame(height: 90)
                            .foregroundStyle(isSelected ? color1.opacity(0.1) : Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 90)
                                    .foregroundStyle(isSelected ? color1 : Color.white.opacity(0.0))
                            }
                            .overlay(alignment: .leading) {
                                HStack(spacing: 14) {
                                    LottieView(animation: .named(option.emoji))
                                        .looping()
                                        .frame(square: 56)
                                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 4)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(option.label)
//                                            .fontWeight(.medium)
                                            .font(.grotesk(.body, weight: .medium))

                                        Text(descriptions[index])
//                                            .font(.subheadline)
                                            .font(.grotesk(.subheadline, weight: .regular))
                                            .multilineTextAlignment(.leading)
                                            .opacity(0.65)
                                    }

                                }
                                .padding(.horizontal)
                            }

                    }
                    .tint(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .safeAreaInset(edge: .bottom) {
//            Button("Skip test") {
//                
//            }
//            .font(.subheadline.weight(.medium))
//            .foregroundStyle(Color.secondary.opacity(0.6))
//        }
        .padding(32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }

    private func action(option: OBOption) {
        withAnimation(.snappy(duration: 0.15)) {
            selectedOption = option
        }
        
        guard let selectedOption else { return }
        vm.sumOfUserValues += selectedOption.value

        Haptics.feedback(style: .light)
        
        guard !vm.isAdvancing else { return }
        vm.isAdvancing = true

        SleepTask.sleep(seconds: vm.actionDelay) {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz 6", properties: [question : selectedOption.label])
        }
    }
}

#Preview {
    OBQuizSix()
        .environmentObject(OBUserViewModel())
}
