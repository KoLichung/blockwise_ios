//
//  OB10_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/01/26.
//

import SwiftUI
import Lottie
//import SDWebImageSwiftUI

struct OB10_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    @State private var checkmark1: Bool = false
    @State private var checkmark2: Bool = false
    @State private var checkmark3: Bool = false
    
    @State private var showCustomDuration: Bool = false
    @State private var screenTime: TimeInterval = 30 * 60
    
    let question: String = ""
    let subheadline: String = ""

    let answers: [OBAnswer] = [
        
    ]
    
    @State private var showPaywall: Bool = false

    let allowMultipleAnswers: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                Space(height: 18)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Group {
                        Text({
                            var result = AttributedString()
                            
                            var highlighted = AttributedString("This week,")
                            highlighted.foregroundColor = Color.skyBlue
                            highlighted.backgroundColor = Color.skyBlue.opacity(0.15)
                            result.append(highlighted)
                            
                            result.append(AttributedString(" \(AppConfiguration.name) will help you:"))
                            
                            return result
                        }())

                    }
                    .font(.grotesk(size: 26, weight: .semibold))
                    .lineSpacing(2.0)
                    .multilineTextAlignment(.leading)

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
                .frame(maxWidth: .infinity, alignment: .leading)
                                
                VStack(alignment: .leading, spacing: 44) {
                    HStack(spacing: 24) {
//                        Text("🙌")
//                            .font(.system(size: 32))
//                        LottieView(animation: .named("relaxed"))
//                            .looping()
//                            .frame(square: 40)
                        
//                        AnimatedImage(name: "relaxed.gif")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)

//                        Image(systemName: "\(1).circle.fill")
//                            .font(.system(size: 36, weight: .medium))
//                            .foregroundStyle(.white, Color.primaryOrange)

                        Checkmark(
                            size: 36,
                            trigger: $checkmark1,
                            backgroundColor: .skyBlue
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reduce screen time by 50% and save **over 2 hours every day**")
                                .font(.grotesk(size: 17, weight: .regular))
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                    
                    HStack(spacing: 24) {
//                        Text("☘️")
//                            .font(.system(size: 32))
//                        AnimatedImage(name: "luck.gif")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)

//                        Image(systemName: "\(2).circle.fill")
//                            .font(.system(size: 36, weight: .medium))
//                            .foregroundStyle(.white, Color.primaryOrange)

                        Checkmark(
                            size: 36,
                            trigger: $checkmark2,
                            backgroundColor: .skyBlue
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text("**Stop losing track of time** while on your phone")
                                .font(.grotesk(size: 17, weight: .regular))
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)

                    HStack(spacing: 24) {
//                        Text("⏳")
//                            .font(.system(size: 32))
//                        LottieView(animation: .named("fire"))
//                            .looping()
//                            .frame(square: 40)

//                        Image(systemName: "\(3).circle.fill")
//                            .font(.system(size: 36, weight: .medium))
//                            .foregroundStyle(.white, Color.primaryOrange)

                        Checkmark(
                            size: 36,
                            trigger: $checkmark3,
                            backgroundColor: .skyBlue
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Develop habits that will **save you decades** of your life")
                                .font(.grotesk(size: 17, weight: .regular))
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.2), value: appearAnimation)

                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .padding(32)
        }
//        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Let's Start!") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
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
                                    
                                    Group {
                                        Text(answer.title) +
                                        Text(answer.asset).foregroundStyle(.secondary)
                                    }
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
            
            Button {
                withAnimation(.smooth) {
                    showCustomDuration = true
                }
            } label: {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .frame(height: height)
                    .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(lineWidth: 3.0)
                            .frame(height: height)
                            .foregroundStyle(Color.gray.opacity(0.15))
                    }
                    .overlay(alignment: .leading) {
                        HStack(spacing: 10) {
                            Image(systemName: "\(answers.count + 1).circle.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.white, Color.primaryOrange)
                            
                            Text("Custom")
                                .font(.grotesk(.body, weight: .medium))
                        }
                        .padding(.horizontal)
                    }
            }
            .tint(.primary)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(TimeInterval(answers.count + 1) * 0.1), value: appearAnimation)

        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
        
        SleepTask.sleep(seconds: 0.2) {
            checkmark1 = true
        }

        SleepTask.sleep(seconds: 0.3) {
            checkmark2 = true
        }

        SleepTask.sleep(seconds: 0.4) {
            checkmark3 = true
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
        #if targetEnvironment(simulator)
        withAnimation(.smooth(duration: 0.35)) {
            // Transition to tutorial
            vm.hasFinishedOnboarding = true
        }
        #else
        vm.superwall {
            // Create user object
            do {
                try CoreDataStack.shared.createUser(
                    name: vm.name,
                    screenTimeGoal: vm.screenTimeGoal
                )
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }
            
            withAnimation(.smooth(duration: 0.35)) {
                // Transition to tutorial
                vm.hasFinishedOnboarding = true
            }
            
            // Mixpanel
            AnalyticsService.shared.track("OBV2 > Converted")
        }
        #endif
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Paywall seen")
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
    OB10_V2()
        .environmentObject(OBVM_V2())
        .environmentObject(ToastManager())
}
