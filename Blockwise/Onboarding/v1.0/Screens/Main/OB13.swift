//
//  OB13.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OB13: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "What's motivating you to set this limit?"
    let subheadline: String = ""

    let answers: [OBAnswer] = [
        OBAnswer(asset: "☀️", title: "Overall health", points: 7),
        OBAnswer(asset: "🧠", title: "Mental well-being", points: 14),
        OBAnswer(asset: "🏆", title: "Financial goals", points: 21),
        OBAnswer(asset: "💙", title: "Quality of life", points: 30),
        OBAnswer(asset: "🤷‍♂️", title: "No special reason", points: 30),
        OBAnswer(asset: "💬", title: "Something else", points: 30),
    ]
    
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
                                HStack(spacing: 10) {
                                    Text(answer.asset)
                                        .font(.grotesk(size: 20, weight: .medium))

                                    Text(answer.title)
                                        .font(.grotesk(.body, weight: .medium))
                                }
                                .padding(.horizontal)
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
                                    Text(answer.title)
                                        .font(.grotesk(.body, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text(answer.asset)
                                        .font(.grotesk(.subheadline, weight: .regular))
                                        .foregroundStyle(.secondary)
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
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action(answer: OBAnswer) {
        Haptics.feedback(style: .light)
        
        withAnimation(vm.selectAnswerAnimation) {
            selectedAnswer = answer
        }
        
        // Specific to view
        vm.streakGoal = Int(selectedAnswer?.points ?? 7)
                
        SleepTask.sleep(seconds: vm.nextPageDelay) {
            vm.nextPage(progressBar: 0.8)
        }
    }
    
    private func action() {
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Motivation")
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
    OB13()
        .environmentObject(OBVM())
}

/*
 struct OB13: View {
     @EnvironmentObject var vm: OBVM
     
     @State private var selectedAnswer: OBAnswer?
     @State private var selectedAnswers: [OBAnswer] = []
     
     @State private var appearAnimation: Bool = false
     
     let question: String = "Commit to your goal"
     let subheadline: String = ""

     let answers: [OBAnswer] = [
         OBAnswer(asset: "Promising", title: "7 days in a row", points: 7),
         OBAnswer(asset: "Determined", title: "14 days in a row", points: 14),
         OBAnswer(asset: "Impressive", title: "21 days in a row", points: 21),
         OBAnswer(asset: "Unstoppable", title: "30 days in a row", points: 30),
     ]
     
     let allowMultipleAnswers: Bool = false
     
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
             VStack(spacing: 32) {
                 HStack(spacing: 10) {
                     Image(.mascotteStreaks)
                         .resizable()
                         .scaledToFit()
                         .frame(square: 128)
                     
                     Bubble(direction: .left,
                            fill: Color.primaryBlue.opacity(0.15),
                            stroke: Color.primaryBlue.opacity(0.5)) {
                         Text("You'll be **4x** more likely to create a habit with a goal")
                             .font(.grotesk(.subheadline, weight: .medium))
                             .foregroundStyle(Color.primaryBlue)
                     }
                 }
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
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
                                     Text(answer.title)
                                         .font(.grotesk(.body, weight: .medium))
                                     
                                     Spacer()
                                     
                                     Text(answer.asset)
                                         .font(.grotesk(.subheadline, weight: .regular))
                                         .foregroundStyle(.secondary)
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
         SleepTask.sleep(seconds: 0.1) {
             appearAnimation = true
         }
     }
     
     private func action(answer: OBAnswer) {
         Haptics.feedback(style: .light)
         
         withAnimation(vm.selectAnswerAnimation) {
             selectedAnswer = answer
         }
         
         // Specific to view
         vm.streakGoal = Int(selectedAnswer?.points ?? 7)
                 
         SleepTask.sleep(seconds: vm.nextPageDelay) {
             vm.nextPage(progressBar: 0.8)
         }
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

 */

/*
 
 struct OB13: View {
     @EnvironmentObject var vm: OBVM
     
     @State private var selectedAnswer: OBAnswer?
     @State private var selectedAnswers: [OBAnswer] = []
     
     @State private var appearAnimation: Bool = false
     
     let question: String = "Commit to growing with \(AppConfiguration.name)"
     let subheadline: String = ""

     let answers: [OBAnswer] = [
         OBAnswer(asset: "Promising", title: "7-day streak", points: 7),
         OBAnswer(asset: "Determined", title: "14-day streak", points: 14),
         OBAnswer(asset: "Impressive", title: "21-day streak", points: 21),
         OBAnswer(asset: "Unstoppable", title: "30-day streak", points: 30),
     ]
     
     let allowMultipleAnswers: Bool = false
     
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
             VStack(spacing: 32) {
                 HStack(spacing: 10) {
                     Image(.mascotteStreaks)
                         .resizable()
                         .scaledToFit()
                         .frame(square: 128)
                     
                     Bubble(direction: .left,
                            fill: Color.primaryBlue.opacity(0.15),
                            stroke: Color.primaryBlue.opacity(0.5)) {
                         Text("You'll be **4x** more likely to create a habit with a goal")
                             .font(.grotesk(.subheadline, weight: .medium))
                             .foregroundStyle(Color.primaryBlue)
                     }
                 }
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
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
                                     Text(answer.title)
                                         .font(.grotesk(.body, weight: .medium))
                                     
                                     Spacer()
                                     
                                     Text(answer.asset)
                                         .font(.grotesk(.subheadline, weight: .regular))
                                         .foregroundStyle(.secondary)
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
         SleepTask.sleep(seconds: 0.1) {
             appearAnimation = true
         }
     }
     
     private func action(answer: OBAnswer) {
         Haptics.feedback(style: .light)
         
         withAnimation(vm.selectAnswerAnimation) {
             selectedAnswer = answer
         }
         
         // Specific to view
         vm.streakGoal = Int(selectedAnswer?.points ?? 7)
                 
         SleepTask.sleep(seconds: vm.nextPageDelay) {
             vm.nextPage(progressBar: 0.8)
         }
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

 
 */
