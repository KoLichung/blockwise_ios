//
//  OBTrafficSource_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/01/26.
//

import SwiftUI

struct OBTrafficSource_V2: View {
    @EnvironmentObject var vm: OBTVM_V2
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    @State private var shuffledAnswers: [OBAnswer] = []
    
    let question: String = "Where did you hear about us?"
    let subheadline: String = "This helps us improve the app"

    let answers: [OBAnswer] = [
        OBAnswer(title: "Youtube"),
        OBAnswer(title: "Instagram / Facebook"),
        OBAnswer(title: "Friend / Family referral"),
        OBAnswer(title: "I found on the App Store"),
        OBAnswer(title: "I read an Article"),
        OBAnswer(title: "TikTok"),
        OBAnswer(title: "Somewhere else"),
    ]

    let allowMultipleAnswers: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 32) {
                Space(height: 18)
                
                VStack(alignment: .center, spacing: 10) {
                    
                    Text(question)
                        .font(.grotesk(size: 26, weight: .semibold))
                        .lineSpacing(2.0)
                        .multilineTextAlignment(.center)

                    if !subheadline.isEmpty {
                        Text(subheadline)
                            .foregroundStyle(.secondary)
                            .font(.grotesk(.body, weight: .regular))
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .center)

                Answers()
            }
            .padding(32)
        }
//        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            if allowMultipleAnswers {
                GlassButton("Continue") {
                    action()
                }
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
        let cornerRadius: CGFloat = 100
        let color: Color = .skyBlue
        let height: CGFloat = 60
        
        VStack(spacing: 14) {
            if allowMultipleAnswers {
                ForEach(Array(shuffledAnswers.enumerated()), id: \.offset) { (index, answer) in
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
                ForEach(Array(shuffledAnswers.enumerated()), id: \.offset) { (index, answer) in
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
        shuffledAnswers = answers.shuffled()
        
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
            do {
                try vm.completeTutorial()
                // MARK: Necessary for onboarding
                userViewModel.refresh()
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }
        }
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Traffic Source", properties: [
            "answer": answer.title
        ])
    }
    
    private func action() {
        vm.nextPage()
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
    OBTrafficSource_V2()
        .environmentObject(OBVM_V2())
        .environmentObject(ToastManager())
}
