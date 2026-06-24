//
//  OBQuizThree.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

struct OBQuizThree: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let options: [OBOption] = [
        OBOption(emoji: "police-car-light", label: "Always", value: 8),
        OBOption(emoji: "balance-scale", label: "Sometimes", value: 6),
        OBOption(emoji: "nerd-face", label: "Never", value: 4)
    ]
    
    let descriptions: [String] = [
        "I keep scrolling nonstop",
        "Quick checks here and there",
        "No screens at the table"
    ]
    
    let questionNumber: Int = 3
    let question: String = "Do you use your phone while eating?"
    
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
                                            .font(.grotesk(.body, weight: .medium))

                                        Text(descriptions[index])
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
        .padding(32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }
    
    private func action(option: OBOption) {
        withAnimation(.snappy(duration: 0.15)) {
            selectedOption = option
        }
        
        Haptics.feedback(style: .light)
        
        guard let selectedOption else { return }
        vm.sumOfUserValues += selectedOption.value
        
        guard !vm.isAdvancing else { return }
        vm.isAdvancing = true

        SleepTask.sleep(seconds: vm.actionDelay) {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz 3", properties: [question : selectedOption.label])
        }
    }
}

#Preview {
    OBQuizThree()
        .environmentObject(OBUserViewModel())
}
