//
//  OBLetter.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/01/26.
//

import SwiftUI

struct OBLetter: View {
    @EnvironmentObject var vm: OBVM

    @State private var appearAnimation: Bool = false
    
    @State private var scale: CGFloat = 1.0

    @State private var opacity: CGFloat = 0.0
    @State var completed: Bool = false
    
    @State var nextPage: Bool = false
    
    @State private var timer: Timer? = nil
    @State private var showPaywall: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 10) {
                Text("🤝")
                    .font(.system(size: 40))
                
                Text("Commitment Pact")
                    .font(.grotesk(.title2, weight: .semibold))
                
                Text("I don’t need to be perfect.\nI just want to be more present with my time.\nBlockwise will help me do that — one day at a time.")
                    .font(.grotesk(.body, weight: .regular))
                    .lineSpacing(4.0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundStyle(.white)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(lineWidth: 2.0)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
        .overlay {
            Color.black.opacity(opacity * 0.15)
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                Text("Tap and hold to commit")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .foregroundStyle(.secondary)
                
                Circle()
                    .frame(square: 72)
                    .foregroundStyle(Color.blueAccent)
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
                                    .foregroundStyle(Color.blueAccent)
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
            .padding(32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .overlay {
            VStack {
                HStack(spacing: 14) {
                    Checkmark(
                        size: 25,
                        trigger: $completed,
                        checkmarkColor: Color.blueAccent,
                        backgroundColor: .white
                    )
                    
                    Text("Committed!")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .opacity(nextPage ? 0 : 1)
                .opacity(completed ? 1 : 0)
                .offset(y: nextPage ? -180 : completed ? -128 : -32)
                
                HStack(spacing: 14) {
                    Checkmark(
                        size: 25,
                        trigger: $nextPage,
                        checkmarkColor: Color.blueAccent,
                        backgroundColor: .white
                    )
                    
                    Text("It's time to invest in yourself")
                        .font(.grotesk(.title3, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .opacity(nextPage ? 1 : 0)
                .offset(y: nextPage ? -128 : -32)
                .animation(.smooth(duration: 0.4), value: nextPage)
            }
        }
        .onAppear(perform: setup)
        .fullScreenCover(isPresented: $showPaywall) {
            OBPaywall()
        }
    }

    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }

    private func action() {
        showPaywall = true
                
//        withAnimation {
//            vm.firstTimeUser = false
//        }
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
    OBLetter()
        .environmentObject(OBVM())
}
