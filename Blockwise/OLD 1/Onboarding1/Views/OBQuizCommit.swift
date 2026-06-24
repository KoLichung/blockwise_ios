//
//  OBQuizCommit.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/06/25.
//

import SwiftUI
import Lottie

struct OBQuizCommit: View {
    @EnvironmentObject var vm: OBUserViewModel
    @EnvironmentObject var lnManager: LocalNotificationManager

    @State private var appearAnimation: Bool = false
    
    @State private var scale: CGFloat = 1.0

    @State private var opacity: CGFloat = 0.0
    @State var completed: Bool = false
    
    @State var nextPage: Bool = false
    
    @State private var timer: Timer? = nil
    
    let color: Color = .primaryOrange

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            
            VStack(alignment: .center, spacing: 32) {
                
                LottieView(animation: .named("pencil-hand"))
                    .looping()
                    .frame(square: 150)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                VStack(alignment: .leading, spacing: 32) {
                    Text("\(vm.firstName), let's make a promise.")
                        .font(.grotesk(size: 30, weight: .semibold))
//                        .font(.system(size: 30, weight: .semibold))
                        .lineSpacing(4.0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        Text("From this day, I commit to:")
//                            .font(.title3.weight(.semibold))
                            .font(.grotesk(.title3, weight: .semibold))
                        
                        HStack(spacing: 10) {
                            let checkSize: CGFloat = 36
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .green,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 14,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)

                            Text("Staying within my \(TimeFormatter.display(vm.screenTimeGoal, style: .short)) limit")
                                .font(.grotesk())
                        }
                        
                        HStack(spacing: 10) {
                            let checkSize: CGFloat = 36
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .green,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 14,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)

                            Text("Build the future I know I deserve")
                                .font(.grotesk())
                        }
                        
                        HStack(spacing: 10) {
                            let checkSize: CGFloat = 36
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .green,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 14,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)

                            Text("Make no more excuses")
                                .font(.grotesk())
                        }
                        
                    }
                    .lineSpacing(6.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.2), value: appearAnimation)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .overlay {
            Color.black.opacity(opacity)
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                Text("Tap and hold to commit")
                    .font(.grotesk(.subheadline, weight: .regular))
//                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Circle()
                    .frame(square: 72)
                    .foregroundStyle(Color.primaryBlue)
                    .shadow(color: .black.opacity(scale != 1 ? 0.25 : 0.0), radius: 8)
                    .scaleEffect(scale) // Apply scale effect
                    .onLongPressGesture(minimumDuration: 2.5, maximumDistance: .infinity) { pressing in
                        if pressing && !completed {
                            withAnimation(.timingCurve(0.8,0,0.5,1, duration: 2.5)) {
                                scale = 25
                            }
                            triggerHaptics()
                        } else {
                            if !completed {
                                withAnimation {
                                    scale = 1.0
                                }
                            }
                            stopHaptics()
                        }
                    } perform: {
                        Logger.success("Completed")
                        withAnimation {
                            completed = true
                        }
                        stopHaptics()
                        scale = 25
                        Haptics.successFeedback()
                        
                        SleepTask.sleep(seconds: 1.1) {
                            withAnimation {
                                nextPage = true
                            }
                        }
                        
                        SleepTask.sleep(seconds: 2.0) {
                            action()
                        }
                    }
                    .overlay {
                        ZStack {
                            Image("fingerprint")
                                .resizable()
                                .scaledToFit()
                                .frame(square: 44)
                                .opacity(0.9)
                                .scaleEffect(scale != 1 ? 0.95 : 1)
                                .allowsHitTesting(false)
                                .animation(.snappy(duration: 0.4, extraBounce: 0.15), value: scale)
                            
                            Circle()
                                .stroke(lineWidth: 3.0)
                                .opacity(0.25)
                                .overlay {
                                    Circle()
                                        .trim(from: 0, to: scale != 1 ? 1 : 0)
                                        .stroke(lineWidth: 3.0)
                                        .rotationEffect(.degrees(-90))
                                }
                                .padding(1.5)
                                .foregroundStyle(.white)
                        }
                        .opacity(completed ? 0 : 1)
                    }
                .phaseAnimator([false, true]) { view, phase in
                    view
                        .background {
                            Circle()
                                .frame(width: 72, height: 72)
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
            }
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
            .padding(32)
        }
        .overlay {
            VStack {
                HStack(spacing: 14) {
                    Checkmark(
                        size: 25,
                        trigger: $completed,
                        checkmarkColor: Color.primaryBlue,
                        backgroundColor: .white
                    )
                    
                    Text("Committed!")
                        .font(.grotesk(.title3, weight: .semibold))
//                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .opacity(nextPage ? 0 : 1)
                .opacity(completed ? 1 : 0)
                .offset(y: nextPage ? -180 : completed ? -128 : -32)
                
                HStack(spacing: 14) {
                    Checkmark(
                        size: 25,
                        trigger: $nextPage,
                        checkmarkColor: Color.primaryBlue,
                        backgroundColor: .white
                    )
                    
                    Text("Your journey starts now")
//                        .font(.title3.weight(.semibold))
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .opacity(nextPage ? 1 : 0)
                .offset(y: nextPage ? -128 : -32)
                .animation(.smooth(duration: 0.4), value: nextPage)
            }
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
        .fullScreenCover(isPresented: $vm.showPaywall) {
            OBQuizPaywall()
        }
//        .fullScreenCover(isPresented: $showRoadmap) {
//            OBQuizPaywall()
//        }
//        .overlay {
//            if showRoadmap {
//                OBQuizPaywall()
//                    .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
//            }
//        }
    }

    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
        }
    }

    private func action() {
//        vm.nextStep()
        
        vm.showPaywall = true
        
        vm.mixPanelTrack(name: "Quiz Paywall View") // Paywall shown
        
//        withAnimation {
//            vm.firstTimeUser = false
//        }
        
            Task {
                do {
                    try await lnManager.requestAuth()
                } catch {
                    Logger.error(error.localizedDescription)
                }
            }

    }
    
    private func triggerHaptics() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Haptics.feedback(style: .soft)
            withAnimation {
                opacity += 0.05
            }
        }
        
    }
    
    private func stopHaptics() {
        timer?.invalidate()
        timer = nil
        withAnimation {
            opacity = 0
        }
    }
}

#Preview {
    OBQuizCommit()
        .environmentObject(OBUserViewModel())
        .environmentObject(LocalNotificationManager())
}
