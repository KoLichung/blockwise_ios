//
//  OB9_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI
import Lottie

struct OB9_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    @State private var showCustomDuration: Bool = false
    @State private var screenTime: TimeInterval = 30 * 60
    
    let question: String = "Set your daily Screen Time goal"
    let subheadline: String = "You can adjust this later"

    let answers: [OBAnswer] = [
        OBAnswer(asset: " /day", title: "30 min", points: 30),
        OBAnswer(asset: " /day", title: "1 hour", points: 1),
        OBAnswer(asset: " /day", title: "1 hour 30 min", points: 130),
        OBAnswer(asset: " /day", title: "2 hours", points: 2),
        OBAnswer(asset: " /day", title: "2 hours 30 min", points: 230),
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

                if showCustomDuration {
                    CustomDuration()
                        .transition(.move(edge: .leading).combined(with: .offset(x: -64)))
                } else {
                    Answers()
                        .transition(.move(edge: .trailing).combined(with: .offset(x: 64)))
                }
            }
            .padding(32)
        }
//        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Confirm") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .offset(y: showCustomDuration ? 0 : 128)
            .animation(.smooth(duration: 0.25), value: showCustomDuration)
        }
        .onAppear(perform: setup)

    }
    
    @ViewBuilder
    private func CustomDuration() -> some View {
        Picker("", selection: selectedMinutesBinding) {
            ForEach(Array(stride(from: minMinutes, through: maxMinutes, by: stepMinutes)), id: \.self) { minutes in
                Text(TimeFormatter.display(TimeInterval(minutes * 60), style: .long))
                    .font(.grotesk(size: 20.0, weight: .regular))
                    .tag(minutes)
            }
        }
        .pickerStyle(.wheel)
        
    }
    
    // MARK: - More properties
    // Minutes range (upper bound is exclusive)
    let range: Range<Int> = 15..<(6 * 60)
    // Derived bounds in minutes
    private var minMinutes: Int { range.lowerBound }
    private var maxMinutes: Int { range.upperBound - 1 }
    // Snapping step in minutes (5-minute increments)
    private let stepMinutes: Int = 5
    
    // Selection binding that always snaps/clamps to 5-minute steps within bounds
    private var selectedMinutesBinding: Binding<Int> {
        Binding<Int>(
            get: {
                let currentMinutes = Int(round(screenTime / 60.0))
                let clamped = min(max(currentMinutes, minMinutes), maxMinutes)
                return ((clamped + stepMinutes / 2) / stepMinutes) * stepMinutes
            },
            set: { newValue in
                let clamped = min(max(newValue, minMinutes), maxMinutes)
                let snapped = ((clamped + stepMinutes / 2) / stepMinutes) * stepMinutes
                screenTime = TimeInterval(snapped * 60)
            }
        )
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(alignment: .trailing) {
                                    if answer.points == 1 {
                                        HStack(spacing: 6) {
                                            LottieView(animation: .named("fire"))
                                                .looping()
                                                .frame(square: 20)
                                                .hueRotation(.degrees(180))
                                            
                                            Text("Popular")
                                                .font(.grotesk(.subheadline, weight: .medium))
                                                .foregroundStyle(.skyBlue)
                                        }
                                    }
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
    }
    
    private func action(answer: OBAnswer) {
        Haptics.feedback(style: .light)
        
        withAnimation(vm.selectAnswerAnimation) {
            selectedAnswer = answer
        }
                        
        SleepTask.sleep(seconds: vm.nextPageDelay) {
            vm.nextPage(progressTwo: 0.9)
        }
        
        // Assign screenTimeGoal
        vm.screenTimeGoal = screenTime(fromPoints: answer.points)
        Logger.debug("Screen Time Goal: \(TimeFormatter.display(vm.screenTimeGoal, style: .long))")
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Set Goal")
    }
    
    private func screenTime(fromPoints points: CGFloat) -> TimeInterval {
        switch points {
        case 30: return 30 * 60                    // 30 minutes
        case 1: return 1 * 60 * 60                 // 1 hour
        case 130: return 1 * 60 * 60 + 30 * 60     // 1.5 hours
        case 2: return 2 * 60 * 60                 // 2 hours
        case 230: return 2 * 60 * 60 + 30 * 60     // 2.5 hours
        default: return 1
        }
    }
    
    private func action() {
        vm.nextPage(progressTwo: 0.9)
        vm.screenTimeGoal = screenTime
        Logger.debug("Screen Time Goal: \(TimeFormatter.display(vm.screenTimeGoal, style: .long))")

        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Set Goal")
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
    OB9_V2()
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
