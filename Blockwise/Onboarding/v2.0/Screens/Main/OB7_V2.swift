//
//  OB7_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct OB7_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "How can we call you?"
    
    @FocusState private var isNameFocused: Bool
    @State private var warning: Bool = false
    @State private var name: String = ""
    private let characterLimit = 20
    private var isNameValid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 32) {
                Space(height: 18)
                
                VStack(alignment: .center, spacing: 10) {
                    Text(question)
                        .font(.grotesk(size: 26, weight: .semibold))
                        .lineSpacing(2.0)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .center)

                CustomTextField()
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .padding(32)
        }
//        .scrollDisabled(!allowMultipleAnswers)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(name.isEmpty ? 0 : 1)
            .offset(y: name.isEmpty ? 128 : 0)
            .animation(.smooth(duration: 0.25), value: name)
        }
        .onAppear(perform: setup)

    }
    
    @ViewBuilder
    private func CustomTextField() -> some View {
        let cornerRadius: CGFloat = 100
        let height: CGFloat = 60
        
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .frame(height: height)
            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(lineWidth: 3.0)
                    .frame(height: height)
                    .foregroundStyle(Color.gray.opacity(0.15))
            }
            .overlay {
                TextField(text: $name) {
                    Text("Your Name")
                        .font(.grotesk(size: 18.5, weight: .semibold))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .font(.grotesk(size: 18.5, weight: .semibold))
                .textContentType(.givenName)
                .autocapitalization(.words)
                .focused($isNameFocused)
                .onChange(of: name) {
                    if name.count > characterLimit {
                        name = String(name.prefix(characterLimit))
                    }
                }
                .overlay(alignment: .trailing) {
                    Button {
                        name = ""
                        Haptics.feedback(style: .soft)
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondary.opacity(0.6))
                    }
                    .padding(.horizontal, 22)
                    .opacity(name.isEmpty ? 0 : 1)
                }
                .padding(.vertical)
            }
    }
        
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.02) {
            isNameFocused = true
        }

        #if targetEnvironment(simulator)
        name = "Ivan"
        #endif
        
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
        
    private func action() {
        // Specific to view
        vm.showProgressBar = false
        vm.name = name

        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Name")
    }
    
}

#Preview {
    OB7_V2()
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

/*
 struct OB7_V2: View {
     @EnvironmentObject var vm: OBVM_V2
     
     @State private var selectedAnswer: OBAnswer?
     @State private var selectedAnswers: [OBAnswer] = []
     
     @State private var appearAnimation: Bool = false
     
     @State private var question: String = "What is your name?"
     
     @FocusState private var isNameFocused: Bool
     @State private var name: String = ""
     private let characterLimit = 20

     // Computed property to check if name is valid
     private var isNameValid: Bool {
         name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
     }
     
     @State private var warning: Bool = false

     let answers: [OBAnswer] = [
 //        OBAnswer(title: "Under 18 years old"),
 //        OBAnswer(title: "18 to 24 years old"),
 //        OBAnswer(title: "25 to 34 years old"),
 //        OBAnswer(title: "35 to 44 years old"),
 //        OBAnswer(title: "45 to 54 years old"),
 //        OBAnswer(title: "55+"),
     ]
     
     let allowMultipleAnswers: Bool = false
     
     var body: some View {
         ScrollView {
             VStack(spacing: 32) {
                 TopSection()
                 
 //                Answers()
                 
                 VStack(spacing: 14) {
                     TextField(text: $name) {
                         Text("First Name")
                             .font(.grotesk(size: 18.5, weight: .semibold))
                     }
                     .font(.grotesk(size: 18.5, weight: .semibold))
                     .textContentType(.givenName)
                     .autocapitalization(.words)
                     .focused($isNameFocused)
                     .onChange(of: name) {
                         if name.count > characterLimit {
                             name = String(name.prefix(characterLimit))
                         }
                     }
                     .padding(.horizontal, 22)
                     .background {
                         RoundedRectangle(cornerRadius: 20, style: .continuous)
                             .stroke(lineWidth: 2.0)
                             .frame(height: 60)
                             .foregroundStyle(.fillGray)
                             .background {
                                 RoundedRectangle(cornerRadius: 20, style: .continuous)
                                     .foregroundStyle(.background)
                                     .background {
                                         RoundedRectangle(cornerRadius: 20, style: .continuous)
                                             .foregroundStyle(.fillGray)
                                             .offset(y: 4)
                                     }
                             }
                             .overlay {
                                 RoundedRectangle(cornerRadius: 20, style: .continuous)
                                     .stroke(lineWidth: 2.0)
                                     .frame(height: 64)
                                     .phaseAnimator([false, true], trigger: warning) { view, phase in
                                         view
                                             .foregroundStyle(phase ? Color.red.opacity(0.5) : Color.white.opacity(0.0))
                                     } animation: { _ in
                                             .smooth
                                     }

                             }
                     }
                     .overlay(alignment: .trailing) {
                         Button {
                             name = ""
                             Haptics.feedback(style: .soft)
                         } label: {
                             Image(systemName: "xmark")
                                 .fontWeight(.medium)
                                 .foregroundStyle(Color.secondary.opacity(0.6))
                         }
                         .padding(.horizontal, 22)
                         .opacity(name.isEmpty ? 0 : 1)
                     }
                     .padding(.vertical)
                 }
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.1), value: appearAnimation)

             }
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
             .padding(32)
         }
         .overlay(alignment: .top) {
             LinearGradient(
                 colors: [Color(UIColor.systemBackground), .clear],
                 startPoint: .top,
                 endPoint: .bottom
             )
             .frame(height: 128)
             .ignoresSafeArea()
         }
         .safeAreaInset(edge: .bottom) {
             PressButton("Continue") {
                 action()
             }
             .padding(.horizontal, 32)
             .padding()
             .offset(y: !isNameValid ? 128 : 0)
             .opacity(!isNameValid ? 0 : 1)
             .animation(.smooth(duration: 0.25), value: isNameValid)
         }
         .scrollDisabled(true)
         .onAppear(perform: setup)
     }
     
     @ViewBuilder
     private func TopSection() -> some View {
         Space(height: 10)
         
         HStack(spacing: 32) {
             Image(.eyeMascotWriting)
                 .resizable()
                 .scaledToFit()
                 .frame(width: 90)
                 .animation(.smooth, value: question)
             
             Text(question)
                 .font(.grotesk(.title3, weight: .semibold))
                 .padding()
                 .speechBubble(tail: .left)
                 .scaleEffect(appearAnimation ? 1 : 0.25, anchor: .leading)
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(duration: 0.35), value: appearAnimation)
         }
         .frame(maxWidth: .infinity, alignment: .leading)
         .padding(.bottom)

     }
     
     @ViewBuilder
     private func Answers() -> some View {
         let color: Color = .fillDarkGreen
         
         VStack(spacing: 16) {
             if allowMultipleAnswers {
                 ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                     let isSelected = selectedAnswers.contains(answer)
                     StrokedPressButton(cornerRadius: 20, color: isSelected ? .fillUltraLightGreen : .fillGray) {
                         Text(answer.title)
                             .font(.grotesk(.body, weight: .medium))
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .overlay(alignment: .trailing) {
                                 Checkmark(
                                     size: 24,
                                     trigger: .isPresent(
                                         in: $selectedAnswers,
                                         element: answer
                                     ),
                                     backgroundColor: color
                                 )
                             }
                             .padding(.horizontal, 20)
                     } action: {
                         addRemove(answer)
                     }
                     .opacity(appearAnimation ? 1 : 0)
                     .offset(y: appearAnimation ? 0 : 32)
                     .scaleEffect(appearAnimation ? 1 : 0.95)
                     .animation(.smooth.delay(TimeInterval(index + 1) * 0.1), value: appearAnimation)
                 }
             } else {
                 ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                     let isSelected = selectedAnswer == answer
     
                     StrokedPressButton(cornerRadius: 20, color: isSelected ? .fillUltraLightGreen : .fillGray) {
                         HStack(spacing: 10) {
                             Image(systemName: "\(index + 1).circle.fill")
                                 .font(.system(size: 24, weight: .medium))
                                 .foregroundStyle(.white, .fillOrange)
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
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.horizontal)
                     } action: {
                         action(answer: answer)
                     }
                     .opacity(appearAnimation ? 1 : 0)
                     .offset(y: appearAnimation ? 0 : 32)
                     .scaleEffect(appearAnimation ? 1 : 0.95)
                     .animation(.smooth.delay(TimeInterval(index + 1) * 0.1), value: appearAnimation)
                 }
             }
             
         }
     }
     
     private func setup() {
         #if targetEnvironment(simulator)
         name = "Ivan"
         #endif
         
         SleepTask.sleep(seconds: 0.02) {
             isNameFocused = true
         }

         SleepTask.sleep(seconds: 0.1) {
             appearAnimation = true
         }
     }
     
     private func action() {
         guard isNameValid else {
             Haptics.warningFeedback()
             warning.toggle()
             return
         }
         
         vm.nextPage()
         
         vm.showProgressBar = false
         
         // Trim whitespace before saving
 //        vm.username = name.trimmingCharacters(in: .whitespacesAndNewlines)
         
         // Mixpanel
         AnalyticsService.shared.track("Onboarding > Name")
     }

     private func action(answer: OBAnswer) {
         Haptics.feedback(style: .soft)
         
         withAnimation(vm.selectAnswerAnimation) {
             selectedAnswer = answer
         }
         
         // Specific to view
         
         // Mixpanel
         AnalyticsService.shared.track("Onboarding > Age", properties: ["age": answer.title])
                 
         SleepTask.sleep(seconds: vm.nextPageDelay) {
             vm.nextPage(progress: 0.40)
         }
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
