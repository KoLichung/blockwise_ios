//
//  OB9.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB9: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "What habit would you like to change?"
//    let question: String = "What do you want less of in your day?"
    let subheadline: String = "Select all that apply"

    // Dynamically set based on age group
    @State private var answers: [OBAnswer] = []
    
    let allowMultipleAnswers: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Space(height: 18)
                
                VStack(alignment: .leading, spacing: 14) {
                    
                    Text(question)
                        .font(.grotesk(size: 26, weight: .semibold))
                        .padding(.trailing)
                        .lineSpacing(2.0)

                    if !subheadline.isEmpty {
                        Text(subheadline)
                            .foregroundStyle(.secondary)
                            .font(.grotesk(.subheadline, weight: .regular))
                    }
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)

                Answers()
            }
            .padding(32)
        }
        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            if allowMultipleAnswers {
                GlassButton("Continue") {
                    action()
                }
                .foregroundStyle(Color.blueAccent)
                .padding(.horizontal, 32)
                .padding()
                .offset(y: selectedAnswers.isEmpty ? 128 : 0)
                .animation(.smooth(duration: 0.25), value: selectedAnswers)
                .background {
                    LinearGradient(
                        colors: [.clear, Color(UIColor.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear(perform: setup)

    }
    
    // MARK: - UI component
    @ViewBuilder
    private func Answers() -> some View {
        let cornerRadius: CGFloat = 18
        
        VStack(spacing: 14) {
            if allowMultipleAnswers {
                ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                    let isSelected = selectedAnswers.contains(answer)
                    
                    Button {
                        addRemove(answer)
                    } label: {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .frame(height: 64)
                            .foregroundStyle(isSelected ? Color.blueAccent.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 64)
                                    .foregroundStyle(isSelected ? Color.blueAccent : Color.gray.opacity(0.15))
                            }
                            .overlay(alignment: .leading) {
                                Text(answer.title)
                                    .font(.grotesk(.body, weight: .medium))
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.leading)
                                    .padding(.trailing, 32)
                            }
                            .overlay(alignment: .trailing) {
                                Checkmark(
                                    size: 24,
                                    trigger: .isPresent(
                                        in: $selectedAnswers,
                                        element: answer
                                    ),
                                    backgroundColor: Color.blueAccent
                                )
                                .padding(.trailing, 22)
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
                            .frame(height: 64)
                            .foregroundStyle(isSelected ? Color.blueAccent.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 64)
                                    .foregroundStyle(isSelected ? Color.blueAccent : Color.gray.opacity(0.15))
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
                                                backgroundColor: Color.blueAccent,
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
    }
    
    // MARK: - Functions
    private func setup() {
        // Specific to view
        setAnswers()
        
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
            vm.nextPage()
        }
    }
    
    private func action() {        
        // Do not update the progress bar in this view
        vm.showProgressBar = false
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Habits")
    }
    
    private func addRemove(_ answer: OBAnswer) {
        if let index = selectedAnswers.firstIndex(where: { $0.title == answer.title }) {
            selectedAnswers.remove(at: index)
        } else {
            selectedAnswers.append(answer)
        }
        Haptics.feedback(style: .light)
    }
    
    // MARK: - Tailored answers based on age group
    func setAnswers() {
        switch vm.age {
        case "Under 18":
            answers = [
                OBAnswer(title: "Using phone during homework"),
                OBAnswer(title: "Using phone late at night"),
                OBAnswer(title: "Spending too much time on social media"),
                OBAnswer(title: "Not spending enough time with friends"),
                OBAnswer(title: "Playing too many video games"),
                OBAnswer(title: "Other")
            ]
        case "18-23":
            answers = [
                OBAnswer(title: "Getting distracted while studying"),
                OBAnswer(title: "Checking social media too much"),
                OBAnswer(title: "Looking at my phone first thing"),
                OBAnswer(title: "Using phone late at night"),
                OBAnswer(title: "Using messaging apps too much"),
                OBAnswer(title: "Other")
            ]
        case "24-29":
            answers = [
                OBAnswer(title: "Scrolling without thinking"),
                OBAnswer(title: "Using phone at work"),
                OBAnswer(title: "Using phone before bedtime"),
                OBAnswer(title: "Spending too much time on social media"),
                OBAnswer(title: "Watching videos or playing games too much"),
                OBAnswer(title: "Other")
            ]
        case "30-39":
            answers = [
                OBAnswer(title: "Using phone too much around family"),
                OBAnswer(title: "Checking work emails after hours"),
                OBAnswer(title: "Spending too much time on social media"),
                OBAnswer(title: "Using phone before sleep"),
                OBAnswer(title: "Losing track of time on phone"),
                OBAnswer(title: "Other")
            ]
        case "40-49":
            answers = [
                OBAnswer(title: "Using phone during family time"),
                OBAnswer(title: "Scrolling without thinking"),
                OBAnswer(title: "Checking news or social media too often"),
                OBAnswer(title: "Checking work emails at home"),
                OBAnswer(title: "Using phone before bedtime"),
                OBAnswer(title: "Other")
            ]
        default:
            answers = [
                OBAnswer(title: "Scrolling without thinking"),
                OBAnswer(title: "Using phone instead of family time"),
                OBAnswer(title: "Using phone during conversations"),
                OBAnswer(title: "Checking news or social media too often"),
                OBAnswer(title: "Using phone late at night"),
                OBAnswer(title: "Other")
            ]
        }
    }

}

#Preview {
    OB9()
        .environmentObject(OBVM())
}
