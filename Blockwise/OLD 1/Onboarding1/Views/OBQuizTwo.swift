//
//  OBQuizTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?
    
    let options: [OBOption] = [
        OBOption(emoji: "", label: "Under 18", value: 16),
        OBOption(emoji: "", label: "18-23", value: 18),
        OBOption(emoji: "", label: "24-29", value: 24),
        OBOption(emoji: "", label: "30-39", value: 30),
        OBOption(emoji: "", label: "Above 40", value: 41),
    ]
    
    let questionNumber: Int = 2
    let question: String = "How old are you?"
    
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
                            .frame(height: 64)
//                            .foregroundStyle(isSelected ? color1.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundStyle(isSelected ? color1.opacity(0.1) : Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 64)
                                    .foregroundStyle(isSelected ? color1 : Color.white.opacity(0.0))
                            }
                            .overlay(alignment: .leading) {
                                HStack(spacing: 10) {
                                    Image(systemName: "\(index + 1).circle.fill")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(.white, color2)
                                        .opacity(isSelected ? 0 : 1)
                                        .background {
                                            Checkmark(
                                                size: 24,
                                                trigger: $selectedOption.equals(option),
                                                backgroundColor: color1,
                                            )
                                        }
                                    
                                    Text(option.label)
                                        .font(.grotesk(.body, weight: .medium))
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
        
        guard let selectedOption else { return }
        vm.estimatedAge = CGFloat.random(in: selectedOption.value...(selectedOption.value + 2.0))
        Logger.debug("Estimated Age: \(vm.estimatedAge)")
        
        Haptics.feedback(style: .light)
        
        guard !vm.isAdvancing else { return }
        vm.isAdvancing = true

        SleepTask.sleep(seconds: vm.actionDelay) {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz 2", properties: [question : selectedOption.label])
        }
        
        vm.ageGroup = option.label
    }
}

#Preview {
    OBQuizTwo()
        .environmentObject(OBUserViewModel())
}
