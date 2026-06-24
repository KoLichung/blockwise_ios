//
//  OBLoadingView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI

struct OBLoadingView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var percentageCompleted: Int = 0
    @State private var trim: CGFloat = 0.0
    
    @State private var timer: Timer? = nil
    
    @State private var loadingPhase: LoadingPhase = .start
    
    let startingColors: [Color] = [Color.primaryBlue, .purple]
    let hueMultiplier: CGFloat = 2.25
            
    var body: some View {
        VStack(spacing: 48) {
            Loader()
            
            VStack(spacing: 18) {
                
                Text("Calculating")
                    .font(.system(size: 38).weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(loadingPhase.rawValue)
                    .foregroundStyle(.secondary.opacity(0.65))
                    .font(.body.weight(.medium))
                    .animation(.smooth, value: loadingPhase)
                    .contentTransition(.numericText())
                    .phaseAnimator([true, false]) { view, phase in
                        view
                            .opacity(phase ? 1 : 0.5)
                    } animation: { _ in
                            .smooth(duration: 0.8)
                    }
            }
        }
        .tint(.primary)
        .padding(.horizontal)
        .padding(.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background {
            Circle()
                .foregroundStyle(
                    .linearGradient(
                        colors: startingColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .hueRotation(.degrees(Double(percentageCompleted) * hueMultiplier))
                .blur(radius: 144)
                .opacity(0.2)
        }
        .background {
//            if percentageCompleted > 66 {
//                LottieView(animation: .named("dizzy-face")) // Load for later
//                    .opacity(0.0)
//                LottieView(animation: .named("slot-machine")) // Load for later
//                    .opacity(0.0)
//
//                LottieView(animation: .named("poop")) // Load for later
//                    .opacity(0.0)
//            }
        }
        .onAppear(perform: setup)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            startLoading()
        }
    }
    
    @ViewBuilder
    private func Loader() -> some View {
        Circle()
            .stroke(lineWidth: 18.0)
            .frame(square: 220)
            .foregroundStyle(.thinMaterial)
            .overlay {
                Circle()
                    .trim(from: 0.0, to: trim)
                    .stroke(style: .init(lineWidth: 20.0, lineCap: .round))
                    .animation(.smooth, value: trim)
                    .frame(square: 220)
                    .foregroundStyle(
                        .linearGradient(
                            colors: startingColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .hueRotation(.degrees(Double(percentageCompleted) * hueMultiplier))
                    .rotationEffect(.degrees(-90))
            }
            .overlay {
                Text("\(percentageCompleted)%")
                    .font(.system(size: 56, weight: .semibold, design: .serif))
            }
    }
        
    private func startLoading() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { _ in
            if percentageCompleted < 100 {
                percentageCompleted += 1
                trim = CGFloat(percentageCompleted) / 100.0
                
                if percentageCompleted > 40 && percentageCompleted < 80 {
                    loadingPhase = .stepOne
                } else if percentageCompleted >= 80 {
                    loadingPhase = .stepTwo
                } else {
                    loadingPhase = .start
                }
                
                Haptics.feedback(style: .soft)
                
            } else {
                timer?.invalidate()
                Haptics.successFeedback()
                
                SleepTask.sleep(seconds: 0.2) {
                    action()
                }
            }
        }
    }
    
    private func action() {
        // Call MixPanel
        
        // Save to UserViewModel
        
        // Continue
        vm.goToNextStep(step: 12)
        
        withAnimation(.smooth(duration: 0.45)) {
            vm.showReportProgress = true
        }
    }
}

#Preview {
    OBLoadingView()
        .environmentObject(OBUserViewModel())
}
