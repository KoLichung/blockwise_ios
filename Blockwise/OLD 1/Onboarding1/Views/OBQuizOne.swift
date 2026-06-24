//
//  OBQuizOne.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizOne: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?
    
    @State private var appearAnimation: Bool = false
//    @State private var brightness: CGFloat = 0.1

    let options: [OBOption] = [
        OBOption(emoji: "", label: "Less than 3 hours", value: 2),
        OBOption(emoji: "", label: "Between 3-5 hours", value: 5),
        OBOption(emoji: "", label: "Between 5-7 hours", value: 7),
        OBOption(emoji: "", label: "More than 7 hours", value: 8),
    ]
    
    let questionNumber: Int = 1
    let question: String = "What is your average Screen Time?"
    
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
                
                Text("Your best guess is okay")
                    .foregroundStyle(.secondary.opacity(0.65))
                    .font(.grotesk(.subheadline))
            }
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(0.15), value: appearAnimation)

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
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.2 + TimeInterval(index) * 0.1), value: appearAnimation)

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
//        .brightness(brightness)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.05) {
            appearAnimation = true
        }
        
//        SleepTask.sleep(seconds: 0.25) {
//            withAnimation {
//                brightness = 0.0
//            }
//        }
    }
    
    private func action(option: OBOption) {
        withAnimation(.snappy(duration: 0.15)) {
            selectedOption = option
        }
        
        guard let selectedOption else { return }
        vm.screenTimeAvg = CGFloat.random(in: (selectedOption.value - 0.5)...selectedOption.value)
        Logger.debug("Screen Time Average estimation: \(vm.screenTimeAvg)")
        
        vm.sumOfUserValues += selectedOption.value
        
        Haptics.feedback(style: .light)
        
        guard !vm.isAdvancing else { return }
        vm.isAdvancing = true
        
        SleepTask.sleep(seconds: vm.actionDelay) {
            vm.nextStep()
            vm.mixPanelTrack(name: "Quiz 1", properties: [question : selectedOption.label])
        }
    }
}

#Preview {
    OBQuizOne()
        .environmentObject(OBUserViewModel())
}
