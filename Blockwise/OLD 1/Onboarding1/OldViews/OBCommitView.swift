//
//  OBCommitView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 15/05/25.
//

import SwiftUI
import Lottie

struct OBCommitView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 0.0
    @State var completed: Bool = false
    
    @State var show: Bool = false

    @State var nextPage: Bool = false
    @State private var timer: Timer? = nil

    @State var buttonRotation: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            LottieView(animation: .named("pencil-hand"))
                .looping()
                .frame(square: 100)
                .makeReflection(size: 100)
            
            Text("Promise to Myself")
                .font(.largeTitle.weight(.bold))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("I've had enough.\nNo more autopilot. No more wasted hours.\nToday, May 25th, is the day I take back control.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .opacity(0.5)
                    .lineSpacing(6.0)
                    .multilineTextAlignment(.leading)
                
//                Rectangle()
//                    .frame(width: 64, height: 2)
//                    .foregroundStyle(.secondary.opacity(0.15))
//
//                Text("Sincerely, Me")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
            }
                .padding(.horizontal)
                .padding(.vertical)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.thinMaterial)
                        .opacity(0.1)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3.0)
                        .foregroundStyle(.secondary.opacity(0.1))
                    
                    Rectangle()
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.primaryBlue, .clear, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(buttonRotation ? 360 : 0))
                        .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: buttonRotation)
                        .scaleEffect(2.0)
                        .padding(.horizontal, -32)
                        .mask {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(lineWidth: 2.5)
                        }
                        .allowsHitTesting(false)

                }
                .onAppear { buttonRotation = true }
                .onDisappear { buttonRotation = false }
            
            Space(height: 128)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: scale != 1 ? scale * 0.5 : 0)
        .overlay {
            Color.black.opacity(opacity)
                .ignoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 32) {
                Image(systemName: "chevron.compact.down")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .phaseAnimator([true, false]) { view, phase in
                        view
                            .offset(y: phase ? 0 : -24)
                            .opacity(phase ? 0.5 : 0.3)
                    } animation: { _ in
                            .smooth(duration: 0.5)
                    }
                
                Circle()
                    .frame(square: 80)
                    .foregroundStyle(Color.primaryBlue)
                    .shadow(color: .black.opacity(scale != 1 ? 0.25 : 0.0), radius: 8)
                    .scaleEffect(scale) // Apply scale effect
                    .onLongPressGesture(minimumDuration: 2.5, maximumDistance: 50) { pressing in
                        if pressing && !completed {
                            withAnimation(.timingCurve(0.8,0,0.5,1, duration: 2.5)) {
                                scale = 20
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
                        print("Completed")
                        withAnimation {
                            completed = true
                        }
                        scale = 20
                        Haptics.successFeedback()
                        
                        SleepTask.sleep(seconds: 1.1) {
                            withAnimation {
                                nextPage = true
                            }
                        }
                        
                        SleepTask.sleep(seconds: 2.0) {
                            withAnimation {
//                                vm.showCustomPlan = true
                                show = true
                            }
                        }
                    }
                    .overlay {
                        ZStack {
                            Image("fingerprint")
                                .resizable()
                                .scaledToFit()
                                .frame(square: 48)
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

                Text(scale > 1 ? "Hold..." : "Hold to commit")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .contentTransition(.numericText())
                    .opacity(completed ? 0 : 1)
                    .animation(.smooth(duration: 0.5), value: scale)

            }
            .padding(10)
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
                    
                    Text("Yay, committed!")
                        .font(.title3.weight(.semibold))
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
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .opacity(nextPage ? 1 : 0)
                .offset(y: nextPage ? -128 : -32)
                .animation(.smooth(duration: 0.4), value: nextPage)
            }
        }
        .fullScreenCover(isPresented: $show) {
            OBRoadmapView()
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
    OBCommitView()
        .background(.white, ignoresSafeAreaEdges: .all)
}
