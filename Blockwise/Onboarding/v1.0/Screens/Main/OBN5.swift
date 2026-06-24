//
//  OBN5.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/01/26.
//

import SwiftUI
import SuperwallKit

struct OBN5: View {
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
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    let checkSize: CGFloat = 32.0
                    
                    CheckmarkShape(trimEnd: 1.0)
                        .trim(from: 0.0, to: 1.0)
                        .stroke(
                            .green,
                            style: StrokeStyle(
                                lineWidth: checkSize / 12,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(square: checkSize / 2.0)
                    
                    Text("You're all set!")
                        .foregroundStyle(.green)
                        .font(.grotesk(.body, weight: .semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                
                Text("This week, \(AppConfiguration.name) will help you:")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
            }
            
            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("🙌")
                            .font(.system(size: 20))
                    }
                
                Text("Reduce your current screen time by over 50% and **save up to 10 hours** each week.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("☘️")
                            .font(.system(size: 20))
                    }
                
                Text("Be more present and productive, reducing distractions by **over 50%**.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)
            
            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("💙")
                            .font(.system(size: 20))
                    }
                
                Text("Develop habits that will save you **decades** of your life.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.green.opacity(0.08), ignoresSafeAreaEdges: .all)
        .overlay {
            Color.black.opacity(opacity * 0.15)
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Start Now") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
//        .safeAreaInset(edge: .bottom) {
//            VStack(spacing: 32) {
//                Text("Tap and hold to start")
//                    .font(.grotesk(.subheadline, weight: .regular))
//                    .foregroundStyle(.secondary)
//                
//                Circle()
//                    .frame(square: 72)
//                    .foregroundStyle(Color.blueAccent)
//                    .shadow(color: .black.opacity(scale != 1 ? 0.25 : 0.0), radius: 8)
//                    .scaleEffect(scale) // Apply scale effect
//                    .onLongPressGesture(minimumDuration: 2.5, maximumDistance: .infinity) { pressing in
//                        if pressing && !completed {
//                            withAnimation(.timingCurve(0.8,0,0.5,1, duration: 2.5)) {
//                                scale = 25
//                            }
//                            triggerHaptics()
//                        } else {
//                            if !completed {
//                                withAnimation {
//                                    scale = 1.0
//                                }
//                            }
//                            stopHaptics()
//                        }
//                    } perform: {
//                        Logger.success("Completed")
//                        withAnimation {
//                            completed = true
//                        }
//                        stopHaptics()
//                        scale = 25
//                        Haptics.successFeedback()
//                        
//                        SleepTask.sleep(seconds: 1.1) {
//                            withAnimation {
//                                nextPage = true
//                            }
//                        }
//                        
//                        SleepTask.sleep(seconds: 2.0) {
//                            action()
//                        }
//                    }
//                    .overlay {
//                        ZStack {
//                            Image("fingerprint")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(square: 44)
//                                .opacity(0.9)
//                                .scaleEffect(scale != 1 ? 0.95 : 1)
//                                .allowsHitTesting(false)
//                                .animation(.snappy(duration: 0.4, extraBounce: 0.15), value: scale)
//                            
//                            Circle()
//                                .stroke(lineWidth: 3.0)
//                                .opacity(0.25)
//                                .overlay {
//                                    Circle()
//                                        .trim(from: 0, to: scale != 1 ? 1 : 0)
//                                        .stroke(lineWidth: 3.0)
//                                        .rotationEffect(.degrees(-90))
//                                }
//                                .padding(1.5)
//                                .foregroundStyle(.white)
//                        }
//                        .opacity(completed ? 0 : 1)
//                    }
//                    .phaseAnimator([false, true]) { view, phase in
//                        view
//                            .background {
//                                Circle()
//                                    .frame(width: 72, height: 72)
//                                    .foregroundStyle(Color.blueAccent)
//                                    .scaleEffect(phase ? 1.8 : 1.0)
//                                    .opacity(phase ? 0.0 : 0.6)
//                            }
//                    } animation: { phase in
//                        if phase {
//                            .easeInOut(duration: 1.0)
//                        } else {
//                            nil
//                        }
//                    }
//            }
//            .padding(32)
//            .opacity(appearAnimation ? 1 : 0)
//            .offset(y: appearAnimation ? 0 : 32)
//            .scaleEffect(appearAnimation ? 1 : 0.95)
//            .animation(.smooth.delay(0.3), value: appearAnimation)
//        }
//        .overlay {
//            VStack {
//                HStack(spacing: 14) {
//                    Checkmark(
//                        size: 25,
//                        trigger: $completed,
//                        checkmarkColor: Color.blueAccent,
//                        backgroundColor: .white
//                    )
//                    
//                    Text("Set up completed!")
//                        .font(.grotesk(.title3, weight: .semibold))
//                        .foregroundStyle(.white)
//                }
//                .opacity(nextPage ? 0 : 1)
//                .opacity(completed ? 1 : 0)
//                .offset(y: nextPage ? -180 : completed ? -128 : -32)
//                
//                HStack(spacing: 14) {
//                    Checkmark(
//                        size: 25,
//                        trigger: $nextPage,
//                        checkmarkColor: Color.blueAccent,
//                        backgroundColor: .white
//                    )
//                    
//                    Text("It's time to invest in yourself")
//                        .font(.grotesk(.title3, weight: .semibold))
//                        .foregroundStyle(.white)
//                }
//                .opacity(nextPage ? 1 : 0)
//                .offset(y: nextPage ? -128 : -32)
//                .animation(.smooth(duration: 0.4), value: nextPage)
//            }
//        }
        .onAppear(perform: setup)
    }
    
    private func action() {
        vm.showPaywall()
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
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
    OBN5()
        .environmentObject(OBVM())
}
