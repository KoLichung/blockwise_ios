//
//  OB11.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OB11: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var selectedAnswer: OBAnswer?
    @State private var selectedAnswers: [OBAnswer] = []
    
    @State private var appearAnimation: Bool = false
    
//    let question: String = "What habit would you like to change?"
    let question: String = "And what would you like more of?"
    let subheadline: String = "Select all that apply"

    let answers: [OBAnswer] = [
        OBAnswer(title: "Time for myself", points: 17),
        OBAnswer(title: "Time with family/friends", points: 22),
        OBAnswer(title: "Feeling calmer", points: 28),
        OBAnswer(title: "A clearer mind", points: 36),
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
        // Specific to view
        vm.showProgressBar = false
        vm.nextPage(progressBar: 0.65)
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
    OB11()
        .environmentObject(OBVM())
}

/*
 
 struct OB11: View {
     @EnvironmentObject var vm: OBVM
     @State private var appearAnimation: Bool = false
     
     @State private var scrollPosition: Int? = 0
     
     var body: some View {
         VStack(alignment: .leading, spacing: 32) {
             Space(height: 10)
             
             Text("See what others are saying.")
                 .font(.grotesk(.largeTitle, weight: .semibold))
                 .multilineTextAlignment(.leading)
                 .lineSpacing(2.0)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth, value: appearAnimation)
             
             ScrollView(.horizontal) {
                 LazyHStack(spacing: 32) {
                     ForEach(Array(Review.reviews.enumerated()), id: \.offset) { (index, review) in
                         ReviewRow(review)
                             .id(index)
                             .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                             .scrollTransition { view, phase in
                                 view
                                     .scaleEffect(phase.isIdentity ? 1 : 0.9)
                             }
                     }
                 }
                 .scrollTargetLayout()
             }
             .scrollTargetBehavior(.viewAligned)
             .contentMargins(.horizontal, 20)
             .padding(.horizontal, -32)
             .scrollIndicators(.hidden)
             .scrollPosition(id: $scrollPosition)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth.delay(0.1), value: appearAnimation)
             
             HStack(spacing: 10) {
                 ForEach(Array(Review.reviews.enumerated()), id: \.offset) { (index, review) in
                     Circle()
                         .foregroundStyle(.secondary.opacity(0.15))
                         .overlay {
                             Circle()
                                 .opacity(index == scrollPosition ? 1 : 0)
                                 .foregroundStyle(.secondary)
                         }
                         .frame(square: 6)
                 }
             }
             .padding(.vertical, 8)
             .frame(maxWidth: .infinity, alignment: .center)
             .animation(.smooth, value: scrollPosition)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth.delay(0.2), value: appearAnimation)
         }
         .padding([.horizontal, .top], 32)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .safeAreaInset(edge: .bottom) {
             VStack(alignment: .leading, spacing: 32) {
                 Group {
                     Text("Users with your goals have seen") +
                     Text(" real results").foregroundStyle(Color.blueAccent) +
                     Text(".")
                 }
                 .multilineTextAlignment(.leading)
                 .font(.grotesk(.title, weight: .semibold))
                 .lineSpacing(4.0)
                 .padding(.trailing, 32)
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.25), value: appearAnimation)

                 GlassButton("Continue") {
                     action()
                 }
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.3), value: appearAnimation)
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
         }
         .onAppear(perform: setup)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.1) {
             withAnimation {
                 appearAnimation = true
             }
         }
     }
     
     private func action() {
         // Specific to view
         vm.showProgressBar = true
         vm.nextPage(progressBar: 0.65)
     }
     
     // MARK: - UI components
     @ViewBuilder
     private func ReviewRow(_ review: Review) -> some View {
         VStack(alignment: .leading, spacing: 16) {
             VStack(alignment: .leading, spacing: 10) {
                 
                 HStack(spacing: 2) {
                     ForEach(0..<5) { index in
                         Image(systemName: "star.fill")
                             .foregroundStyle(Color.yellow)
                             .font(.system(size: 20))
                     }
                 }
                 
                 Text(review.title)
                     .font(.grotesk(.title2, weight: .semibold))
             }
             
             Text(review.body)
                 .font(.grotesk(.body, weight: .regular))
                 .lineSpacing(4.0)
                 .opacity(0.8)
             
             HStack(spacing: 10) {
                 Image(review.asset)
                     .resizable()
                     .scaledToFit()
                     .frame(square: 32)
                 
                 Text(review.name)
                     .font(.grotesk(.body, weight: .medium))
             }
         }
         .padding(20)
         .background {
             RoundedRectangle(cornerRadius: 18, style: .continuous)
                 .stroke(lineWidth: 2.0)
                 .foregroundStyle(.secondary.opacity(0.15))
         }
         .frame(maxHeight: .infinity, alignment: .top)
     }
 }

 #Preview {
     OB11()
         .environmentObject(OBVM())
 }
 
 */
