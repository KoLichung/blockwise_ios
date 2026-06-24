//
//  OBGoalView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 14/05/25.
//

import SwiftUI
import Lottie

struct OBGoalView: View {
    @State private var goal: TimeInterval = 60 * 60
    let triangleWidth: CGFloat = 18
    
    @State private var next: Bool = false
    @State private var appear: Bool = false
    @State private var appearAnimation: Bool = false

    @Namespace var nspace
    
    var body: some View {
        VStack(spacing: 44) {
            VStack(spacing: 14) {
                Text("Your Goal".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text("What's your ideal Screen Time?")
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            Space(height: 16)
                        
            ZStack {
                if lessThan30min {
                    LottieView(animation: .named("comet"))
                        .looping()
                        .frame(square: 100)
                        .makeReflection(size: 100)
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
                                .frame(square: 100)
                                .makeReflection(size: 100)
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
                                        .frame(square: 100)
                                        .makeReflection(size: 100)
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
                                                .frame(square: 100)
                                                .makeReflection(size: 100)
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
                                                        .frame(square: 100)
                                                        .makeReflection(size: 100)
                                                        .frame(maxWidth: .infinity)
                                                        .transition(.move(edge: .leading)
                                                            .combined(with: .opacity)
                                                            .combined(with: .scale(scale: 0.95))
                                                        )
                                                } else {
                                                    LottieView(animation: .named("snail"))
                                                        .looping()
                                                        .frame(square: 100)
                                                        .makeReflection(size: 100)
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
                        
            VStack(spacing: 14) {
                
                VStack(spacing: 14) {
                    ZStack {
                        if lessThan30min {
                            Text("Legendary Goal")
                                .font(.title3.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .transition(.move(edge: .leading)
                                    .combined(with: .opacity)
                                    .combined(with: .scale(scale: 0.95))
                                )
                        } else {
                            ZStack {
                                if between30minAnd1hr30min {
                                    Text("Strong Goal")
                                        .font(.title3.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .transition(.move(edge: .leading)
                                            .combined(with: .opacity)
                                            .combined(with: .scale(scale: 0.95))
                                        )
                                } else {
                                    ZStack {
                                        if between1hr30minAnd2hr30min {
                                            Text("Balanced Goal")
                                                .font(.title3.weight(.semibold))
                                                .frame(maxWidth: .infinity)
                                                .transition(.move(edge: .leading)
                                                    .combined(with: .opacity)
                                                    .combined(with: .scale(scale: 0.95))
                                                )
                                        } else {
                                            ZStack {
                                                if between2hr30minAnd4hr {
                                                    Text("Solid Goal")
                                                        .font(.title3.weight(.semibold))
                                                        .frame(maxWidth: .infinity)
                                                        .transition(.move(edge: .leading)
                                                            .combined(with: .opacity)
                                                            .combined(with: .scale(scale: 0.95))
                                                        )
                                                } else {
                                                    ZStack {
                                                        if between4hrAnd6hr {
                                                            Text("Steady Goal")
                                                                .font(.title3.weight(.semibold))
                                                                .frame(maxWidth: .infinity)
                                                                .transition(.move(edge: .leading)
                                                                    .combined(with: .opacity)
                                                                    .combined(with: .scale(scale: 0.95))
                                                                )
                                                        } else {
                                                            Text("Slow Goal")
                                                                .font(.title3.weight(.semibold))
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

//                    Triangle()
//                        .frame(width: triangleWidth, height: triangleWidth * 0.7)
//                        .rotationEffect(.degrees(180))
//                        .foregroundStyle(Color.secondary.opacity(0.25))
                }
                
                HStack(spacing: 28) {
                    Button {
                        guard goal > 15 * 60 else { return }
                        withAnimation {
                            goal -= 15 * 60
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white, Color.secondary.opacity(0.25))
                            .opacity(goal <= 15 * 60 ? 0.35 : 1.0)
                    }
                    
                    Text(TimeFormatter.display(goal, style: .short))
                        .font(.system(size: 40, weight: .bold))
                        .contentTransition(.numericText(value: goal))
                    
                    Button {
                        guard goal < 7 * 3600 else { return }

                        withAnimation {
                            goal += 15 * 60
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white, Color.secondary.opacity(0.25))
                            .opacity(goal >= 7 * 3600 ? 0.35 : 1.0)
                    }
                }
            }
            
            Group {
                Text("You're giving yourself") +
                Text(" \(16) years ").fontWeight(.semibold) +
                Text("back.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary.opacity(0.8))
                        
        }
        .scaleEffect(next ? 1.1 : 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
//            if !next {
                Button {
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
//                        .matchedGeometryEffect(id: "bg", in: nspace)
                        .frame(height: 60)
                        .overlay {
                            Text("Confirm")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.background)
                        }
                }
                .padding(.horizontal)
                .opacity(next ? 0 : 1)
//            }
        }
        .padding()
        .background {
            LinearGradient(
                colors: [backgroundColor, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(appearAnimation ? 0.10 : 0.0)
            .ignoresSafeArea()
        }
        .opacity(next ? 0 : 1)
        .overlay {
            if next {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay {
                        OBCommitView()
                            .opacity(appear ? 1 : 0)
                            .scaleEffect(appear ? 1 : 0.9)
                    }
                    .onAppear {
                        SleepTask.sleep(seconds: 0.15) {
                            withAnimation(.smooth(duration: 0.30, extraBounce: 0.35)) {
                                appear = true
                            }
                        }
                    }
                    .transition(.push(from: .top))
            }
        }
        .onAppear(perform: setup)
        
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35)) {
                appearAnimation = true
            }
        }
    }
    
    var backgroundColor: Color {
        if lessThan30min {
            return .mint
        } else {
            if between30minAnd1hr30min {
                return .cyan
            } else {
                if between1hr30minAnd2hr30min {
                    return .gray
                } else {
                    if between2hr30minAnd4hr {
                        return .yellow
                    } else {
                        if between4hrAnd6hr {
                            return Color.primaryBlue
                        } else {
                            return .brown
                        }
                    }
                }
            }
        }
        
    }
    
    private func action() {
        withAnimation(.smooth(duration: 0.30)) {
            next = true
        }
    }
}

#Preview {
    OBGoalView()
}

extension OBGoalView {

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
