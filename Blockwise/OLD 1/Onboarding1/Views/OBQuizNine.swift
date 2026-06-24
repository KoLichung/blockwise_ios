//
//  OBQuizNine.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizNine: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let options: [OBOption] = [
        OBOption(emoji: "", label: "Yes", value: 8),
        OBOption(emoji: "", label: "No", value: 4),
    ]
    
    let questionNumber: Int = 9
    let question: String = "Do you sleep with your phone nearby?"
    
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
                                                backgroundColor: color1
                                            )
                                        }
                                    
                                    Text(option.label)
//                                        .fontWeight(.medium)
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
        vm.sumOfUserValues += selectedOption.value

        Haptics.feedback(style: .light)
        
        guard !vm.isAdvancing else { return }
        vm.isAdvancing = true
        
        SleepTask.sleep(seconds: vm.actionDelay) {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz 9", properties: [question : selectedOption.label])
        }
    }
}

#Preview {
    OBQuizNine()
        .environmentObject(OBUserViewModel())
}
