//
//  OBT4_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI
import Lottie

struct OBT4_V2: View {
    @EnvironmentObject var vm: OBTVM_V2
    @State private var appearAnimation: Bool = false
    @State private var triggerCheckmark: Bool = false

    @State private var streakCount: Int = 0
    
    let initialDelay: TimeInterval = 0.5

    var body: some View {
        VStack(spacing: 32) {
            LottieView(animation: .named("fire"))
                .looping()
                .frame(square: 128)
                .background {
                    LottieView(animation: .named("fire"))
                        .looping()
                        .frame(square: 128)
                        .scaleEffect(1.1)
                        .brightness(1.0)
                        .shadow(radius: 8)
                        .offset(y: -2)
                }
                .scaleEffect(streakCount == 0 ? 0.2 : 1.0)
                .offset(y: streakCount == 0 ? 100 : 0)
                .opacity(streakCount == 0 ? 0 : 1)
                .padding(.bottom)

            VStack(spacing: 0) {
                Text(streakCount.description)
                    .font(.grotesk(size: 100, weight: .semibold))
                    .contentTransition(.numericText(value: Double(streakCount)))
                    .foregroundStyle(Color.primaryOrange)
                    .grayscale(streakCount == 0 ? 1 : 0)
                    .scaleEffect(streakCount == 0 ? 1.0 : 1.15)
                    .offset(y: streakCount == 0 ? 0 : -32)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                    .frame(height: 90, alignment: .top)
                    .offset(y: streakCount == 0 ? 16 : 0)
                
                Text("Day Streak")
                    .font(.grotesk(size: 32, weight: .bold))
                    .foregroundStyle(Color.primaryOrange)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(initialDelay + 0.1), value: appearAnimation)
            }

            HStack(spacing: 10) {
                ForEach(weekDates, id: \.self) { date in
                    let isToday = Calendar.current.isDateInToday(date)
                    
                    VStack(spacing: 10) {
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .font(.grotesk(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                        
                        GeometryReader { geo in
                            let width = geo.size.width
                            
                            Circle()
                                .stroke(lineWidth: 2.5)
                                .foregroundStyle(.secondary.opacity(0.15))
                                .overlay {
                                    if isToday {
                                        Checkmark(size: width * 1.07, trigger: $triggerCheckmark, backgroundColor: Color.primaryOrange)
                                            .opacity(triggerCheckmark ? 1 : 0)
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(lineWidth: 2.5)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            .frame(height: 100)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(initialDelay + 0.25), value: appearAnimation)
            
            Text("You've officially started! Stay under your goal today to keep the streak alive")
                .font(.grotesk(.body))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(initialDelay + 0.35), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Let's go!") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(initialDelay + 0.45), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    // MARK: - Week (Mon...Sun)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Compute Monday of current week (Monday = 2 in Gregorian; Sunday = 1)
        let weekdayIndex = calendar.component(.weekday, from: today)
        // Offset from Monday (Mon -> 0, Tue -> 1, ..., Sun -> 6)
        let offsetFromMonday = (weekdayIndex + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -offsetFromMonday, to: today) else {
            return []
        }
        // Build Mon...Sun
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
        
        SleepTask.sleep(seconds: initialDelay) {
            withAnimation(.snappy(duration: 0.5, extraBounce: 0.25)) {
                streakCount = 1
            }
            
            Haptics.successFeedback()
        }
        
        // Trigger checkmark only for today's circle
        SleepTask.sleep(seconds: initialDelay + 0.6) {
            triggerCheckmark = true
        }
    }
    
    private func action() {
        // Complete tutorial
//        vm.completeTutorial()
        vm.nextPage()
    }

}

#Preview {
    OBT4_V2()
}
