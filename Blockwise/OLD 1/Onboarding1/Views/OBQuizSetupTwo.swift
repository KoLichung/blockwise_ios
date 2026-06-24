//
//  OBQuizSetupTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/06/25.
//

import SwiftUI
import Lottie

struct OBQuizSetupTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    @State private var goal: TimeInterval = 9 * 15 * 60
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Space(height: 20)
            
            VStack(alignment: .center, spacing: 32) {
                
                Lottie()
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.vertical, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)
                
                Text("What's your Screen Time Goal?")
                    .font(.grotesk(size: 30, weight: .semibold))
//                    .font(.system(size: 30, weight: .semibold))
                    .lineSpacing(4.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                    .frame(height: 90)
                
                VStack(spacing: 32) {
                    let triangleWidth: CGFloat = 18
                    
//                    Triangle()
//                        .frame(width: triangleWidth, height: triangleWidth * 0.7)
//                        .rotationEffect(.degrees(180))
//                        .foregroundStyle(Color.white.opacity(0.15))
                    
                    ScreenTimeSelector()
                    
                    Group {
                        Text("You're giving yourself") +
                        Text(" \(calculateYearsBack()) years ").fontWeight(.semibold) +
                        Text("back.")
                    }
                    .font(.grotesk(.subheadline, weight: .regular))
//                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.8))
                    .contentTransition(.numericText(value: goal))
                    
                }
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35).delay(0.2), value: appearAnimation)
            }
            
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                Circle()
                    .frame(square: 64)
                    .foregroundStyle(Color.primaryBlue)
                    .overlay {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.white)
                            .font(.system(size: 24.0).weight(.semibold))
                    }
            }
            .phaseAnimator([false, true]) { view, phase in
                view
                    .background {
                        Circle()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(Color.primaryBlue)
                            .scaleEffect(phase ? 1.8 : 1.0)
                            .opacity(phase ? 0.0 : 0.6)
                    }
            } animation: { phase in
                if phase {
                    .easeInOut(duration: 1.0)
                } else {
                    nil
                }
            }
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
            .padding(32)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextStep()
        vm.currentSetupProgress = .three
        vm.screenTimeGoal = goal
        vm.mixPanelTrack(name: "Quiz Setup 2 - Goal")
    }
    
    private func calculateYearsBack() -> Int {
        let newScreenTimeGoal: Double = goal / 3600
        let currentScreenTimePerDay: CGFloat = vm.screenTimeAvg
//        let totalYearsSpent: CGFloat = vm.yearsUsingPhone
        
//        let newScreenTimeGoal: Double = goal / 3600  // Convert seconds to hours
//        let currentScreenTimePerDay: Double = 6.5  // 6.5 hours per day
        let expectedLifetimeYears: Double = 80  // Average lifetime in years
        
        Logger.debug("---------------------------------------------")
        Logger.debug("newScreenTimeGoal (in hours): \(newScreenTimeGoal)")  // 2 hours
        Logger.debug("currentScreenTimePerDay (in hours): \(currentScreenTimePerDay)")  // 6.5 hours
        Logger.debug("expectedLifetimeYears: \(expectedLifetimeYears)")  // 80 years
        
        // Convert total years spent into total hours (current screen time)
        let totalCurrentScreenTimeInHours = currentScreenTimePerDay * 365.25 * expectedLifetimeYears
        Logger.debug("totalCurrentScreenTimeInHours: \(totalCurrentScreenTimeInHours)")  // 6.5 hours/day * 365.25 days/year * 80 years
        
        // Convert total years spent into total hours (new screen time goal)
        let totalNewScreenTimeInHours = newScreenTimeGoal * 365.25 * expectedLifetimeYears
        Logger.debug("totalNewScreenTimeInHours: \(totalNewScreenTimeInHours)")  // 2 hours/day * 365.25 days/year * 80 years
        
        // Calculate the hours saved over the user's lifetime
        let hoursSaved = totalCurrentScreenTimeInHours - totalNewScreenTimeInHours
        Logger.debug("Hours Saved (lifetime): \(hoursSaved)")  // Difference between the current and new screen time
        
        // Convert hours saved to years
        let yearsSaved = max(0, Int(hoursSaved / 24 / 365.25))  // Convert hours saved into years
        
        Logger.debug("Years Saved (lifetime): \(yearsSaved)")  // The final result
        
        Logger.debug("---------------------------------------------")
        
        return max(yearsSaved, 0)
    }
    
    @ViewBuilder
    private func ScreenTimeSelector() -> some View {
        let color: Color = Color.primaryBlue
        
        HStack(spacing: 28) {
            Button {
                guard goal > 15 * 60 else { return }
                withAnimation {
                    goal -= 15 * 60
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .opacity(goal <= 15 * 60 ? 0.35 : 1.0)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Text(TimeFormatter.display(goal, style: .short))
                .font(.grotesk(size: 40, weight: .bold))
//                .font(.system(size: 40, weight: .bold))
                .contentTransition(.numericText(value: goal))
                .foregroundStyle(color)
            
            Button {
                guard goal < 7 * 3600 else { return }
                
                withAnimation {
                    goal += 15 * 60
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .opacity(goal >= 7 * 3600 ? 0.35 : 1.0)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
    
    @ViewBuilder
    private func Lottie() -> some View {
        let lottieSize: CGFloat = 128
        
        ZStack {
            if lessThan30min {
                LottieView(animation: .named("comet"))
                    .looping()
                    .frame(square: lottieSize)
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .leading)
                        .combined(with: .opacity)
                        .combined(with: .scale(scale: 0.95))
                    )
            } else {
                ZStack {
                    if between30minAnd1hr30min {
                        LottieView(animation: .named("gold-medal"))
                            .looping()
                            .frame(square: lottieSize)
                            .frame(maxWidth: .infinity)
                            .transition(.move(edge: .leading)
                                .combined(with: .opacity)
                                .combined(with: .scale(scale: 0.95))
                            )
                    } else {
                        ZStack {
                            if between1hr30minAnd2hr30min {
                                LottieView(animation: .named("balance-scale"))
                                    .looping()
                                    .frame(square: lottieSize)
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .leading)
                                        .combined(with: .opacity)
                                        .combined(with: .scale(scale: 0.95))
                                    )
                            } else {
                                ZStack {
                                    if between2hr30minAnd4hr {
                                        LottieView(animation: .named("thumbs-up"))
                                            .looping()
                                            .frame(square: lottieSize)
                                            .frame(maxWidth: .infinity)
                                            .transition(.move(edge: .leading)
                                                .combined(with: .opacity)
                                                .combined(with: .scale(scale: 0.95))
                                            )
                                    } else {
                                        ZStack {
                                            if between4hrAnd6hr {
                                                LottieView(animation: .named("bicycle"))
                                                    .looping()
                                                    .frame(square: lottieSize)
                                                    .frame(maxWidth: .infinity)
                                                    .transition(.move(edge: .leading)
                                                        .combined(with: .opacity)
                                                        .combined(with: .scale(scale: 0.95))
                                                    )
                                            } else {
                                                LottieView(animation: .named("snail"))
                                                    .looping()
                                                    .frame(square: lottieSize)
                                                    .frame(maxWidth: .infinity)
                                                    .transition(.move(edge: .trailing)
                                                        .combined(with: .opacity)
                                                        .combined(with: .scale(scale: 0.95))
                                                    )
                                            }
                                        }
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                    }
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }

    }
}

#Preview {
    OBQuizSetupTwo()
        .environmentObject(OBUserViewModel())
}

extension OBQuizSetupTwo {

    var lessThan30min: Bool {
        goal <= 45 * 60
    }

    var between30minAnd1hr30min: Bool {
        goal > 45 * 60 && goal <= 120 * 60
    }

    var between1hr30minAnd2hr30min: Bool {
        goal > 120 * 60 && goal <= 180 * 60
    }

    var between2hr30minAnd4hr: Bool {
        goal > 180 * 60 && goal <= 240 * 60
    }

    var between4hrAnd6hr: Bool {
        goal > 240 * 60 && goal <= 300 * 60
    }
    
    var above5hr: Bool {
        goal > 300 * 60
    }
}
