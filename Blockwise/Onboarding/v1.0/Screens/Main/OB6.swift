//
//  OB6.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB6: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "Have you tried other apps to help with your screen time before?"
    let subheadline: String = ""
    
    let answers: [OBAnswer] = [
        OBAnswer(title: "Male"),
        OBAnswer(title: "Female"),
        OBAnswer(title: "Other"),
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
                
//                Answers()
                
                Space(height: 10)
                
                HStack(spacing: 16) {
                    Button {
                        action("Yes")
                    } label: {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.25))
                            .frame(height: 128)
                            .overlay {
                                VStack(spacing: 10) {
                                    Text("👍")
                                        .font(.system(size: 38))
                                    
                                    Text("Yes")
                                        .font(.grotesk(.body, weight: .medium))
                                }
                            }
                    }
                    .tint(.primary)
                    
                    Button {
                        action("No")
                    } label: {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.25))
                            .frame(height: 128)
                            .overlay {
                                VStack(spacing: 10) {
                                    Text("👎")
                                        .font(.system(size: 38))
                                    
                                    Text("No")
                                        .font(.grotesk(.body, weight: .medium))
                                }
                            }
                    }
                    .tint(.primary)

                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .padding(32)
        }
        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            if allowMultipleAnswers {
                GlassButton("Continue") {
//                    action()
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
            vm.nextPage(progressBar: 0.30)
        }
    }
    
    private func action(_ answer: String) {
        Haptics.feedback(style: .light)
        vm.nextPage(progressBar: 0.25)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Have you tried other blockers?", properties: [
            "answer" : answer
        ])
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
    OB6()
        .environmentObject(OBVM())
}

/*
 struct OB6: View {
     @EnvironmentObject var vm: OBVM
     
     @State private var selectedAnswer: OBAnswer?
     @State private var selectedAnswers: [OBAnswer] = []
     
     @State private var appearAnimation: Bool = false
     
     let question: String = "What's your gender?"
     let subheadline: String = ""

     let answers: [OBAnswer] = [
         OBAnswer(title: "Male"),
         OBAnswer(title: "Female"),
         OBAnswer(title: "Other"),
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
             vm.nextPage(progressBar: 0.30)
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
 struct OB6: View {
     @EnvironmentObject var vm: OBVM
     @State private var appearAnimation: Bool = false
     
     var body: some View {
         VStack(spacing: 32) {
             Space(height: 18)
             
             Text("You’re not alone in feeling this way about your phone.")
                 .font(.grotesk(size: 26, weight: .semibold))
                 .padding(.trailing)
                 .lineSpacing(2.0)
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth, value: appearAnimation)
                 .frame(maxWidth: .infinity, alignment: .leading)
             
             Image(.chart)
                 .resizable()
                 .scaledToFit()
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.1), value: appearAnimation)

             Text("Phone overuse is more common than we think... Modern apps are designed to hold our attention. Struggling to put your phone down isn’t a personal failure — it’s something many people experience.")
                 .font(.grotesk(.body, weight: .medium))
                 .opacity(0.5)
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.2), value: appearAnimation)
                 .frame(maxWidth: .infinity, alignment: .leading)

         }
         .padding(32)
         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         .safeAreaInset(edge: .bottom) {
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
         .onAppear(perform: setup)
     }
     
     private func action() {
         vm.nextPage(progressBar: 1.0)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.1) {
             withAnimation {
                 appearAnimation = true
             }
         }
     }

 }

 */
