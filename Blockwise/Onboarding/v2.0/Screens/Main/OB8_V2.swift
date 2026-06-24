//
//  OB8_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct OB8_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "You are in the right place!"
    let subheadline: String = "Your best guess is ok"

    let answers: [OBAnswer] = [
        OBAnswer(title: "1-2 hours"),
        OBAnswer(title: "2-4 hours"),
        OBAnswer(title: "4-6 hours"),
        OBAnswer(title: "6-8 hours"),
        OBAnswer(title: "Over 8 hours"),
    ]
    
    let allowMultipleAnswers: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
//                VStack(alignment: .center, spacing: 10) {
//
////                    Text(question)
////                        .font(.grotesk(size: 26, weight: .semibold))
////                        .lineSpacing(2.0)
////                        .multilineTextAlignment(.center)
//
////                    if !subheadline.isEmpty {
////                        Text(subheadline)
////                            .foregroundStyle(.secondary)
////                            .font(.grotesk(.body, weight: .regular))
////                            .multilineTextAlignment(.center)
////                    }
//                }
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
//                .frame(maxWidth: .infinity, alignment: .center)

//                Answers()
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                            .font(.system(size: 22))
                    }
                }
                
                Group {
                    Text({
                        var result = AttributedString()
                                                    
//                            var highlight = AttributedString("I use it for my ADHD and tendency to doom scroll")
//                            highlight.foregroundColor = Color.orange
//                            highlight.backgroundColor = Color.orange.opacity(0.15)
//                            result.append(highlight)
                        
                        result.append(AttributedString("“I use it for my ADHD and tendency to doom scroll and lose complete track of time. "))

                        var highlighted = AttributedString("It's made a HUGE impact for me.")
                        highlighted.foregroundColor = Color.orange
                        highlighted.backgroundColor = Color.orange.opacity(0.15)
                        result.append(highlighted)
                        
                        result.append(AttributedString(" I haven't been able to find anything else like it!“"))
                        
                        return result
                    }())
                }
                .foregroundStyle(.textC)
                .font(.grotesk(.title2, weight: .semibold))
                .lineSpacing(3)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.vertical, 4)
            .background(Color(UIColor.secondarySystemGroupedBackground), in: .rect(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(lineWidth: 3.0)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .padding(32)
//        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .background(.skyBlue.opacity(0.25), ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                HStack(spacing: 10) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 72))
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 10) {
                        
                        HStack(spacing: 8) {
                            Image(systemName: "applelogo")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 18))

                            Text("App Store")
                                .foregroundStyle(.secondary)
                                .font(.grotesk(.body, weight: .regular))
                        }

                        HStack(spacing: 0) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 18))
                            }
                        }
                        
                        Text("Jan 2026, Worldwide")
                            .font(.grotesk(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    
                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 72))
                        .foregroundStyle(.secondary)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)

                GlassButton("Continue") {
                    action()
                }
                .padding(.horizontal, 32)
                .padding()
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
            }
        }
        .onAppear(perform: setup)

    }
    
    // MARK: - UI component
    @ViewBuilder
    private func Answers() -> some View {
        let cornerRadius: CGFloat = 100
        let color: Color = .skyBlue
        let height: CGFloat = 60
        
        VStack(spacing: 14) {
            if allowMultipleAnswers {
                ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                    let isSelected = selectedAnswers.contains(answer)
                    
                    Button {
                        addRemove(answer)
                    } label: {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .frame(height: height)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(lineWidth: 3.0)
                                    .frame(height: height)
                                    .foregroundStyle(isSelected ? color.opacity(0.5) : Color.gray.opacity(0.15))
                            }
                            .overlay(alignment: .leading) {
                                Text(answer.title)
                                    .font(.grotesk(.body, weight: .medium))
                                    .padding(.horizontal, 22)
                            }
                            .overlay(alignment: .trailing) {
                                Checkmark(
                                    size: 24,
                                    trigger: .isPresent(
                                        in: $selectedAnswers,
                                        element: answer
                                    ),
                                    backgroundColor: color
                                )
                                .padding(.trailing, 20)
                            }
                    }
                    .tint(.primary)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(TimeInterval(index + 1) * 0.1), value: appearAnimation)
                }
            } else {
                ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                    let isSelected = selectedAnswer == answer
                    
                    Button {
                        action(answer: answer)
                    } label: {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .frame(height: height)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(lineWidth: 3.0)
                                    .frame(height: height)
                                    .foregroundStyle(isSelected ? color.opacity(0.5) : Color.gray.opacity(0.15))
                            }
                            .overlay(alignment: .leading) {
                                HStack(spacing: 10) {
                                    Image(systemName: "\(index + 1).circle.fill")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(.white, Color.primaryOrange)
                                        .opacity(isSelected ? 0 : 1)
                                        .background {
                                            Checkmark(
                                                size: 24,
                                                trigger: $selectedAnswer.equals(answer),
                                                backgroundColor: color,
                                            )
                                        }
                                    
                                    Text(answer.title)
                                        .font(.grotesk(.body, weight: .medium))
                                }
                                .padding(.horizontal)
                            }
                    }
                    .tint(.primary)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(TimeInterval(index + 1) * 0.1), value: appearAnimation)
                }
            }
            
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action(answer: OBAnswer) {
        Haptics.feedback(style: .light)
        
        withAnimation(vm.selectAnswerAnimation) {
            selectedAnswer = answer
        }
                        
        SleepTask.sleep(seconds: vm.nextPageDelay) {
            vm.nextPage(progress: 0.8)
        }
    }
    
    private func action() {
        vm.nextPage(progressTwo: 0.5)
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Testimonial")
    }
    
    private func addRemove(_ answer: OBAnswer) {
        if let index = selectedAnswers.firstIndex(where: { $0.title == answer.title }) {
            selectedAnswers.remove(at: index)
        } else {
            selectedAnswers.append(answer)
        }
        Haptics.feedback(style: .light)
    }
    
}

#Preview {
    OB8_V2()
        .environmentObject(OBVM_V2())
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.15))
                .frame(height: 12)
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .frame(height: 32)
        }
}
