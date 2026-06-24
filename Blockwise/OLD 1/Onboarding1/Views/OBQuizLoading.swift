//
//  OBQuizLoading.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

//enum LoadingPhase: String {
//    case start = "Understanding your responses..."
//    case stepOne = "91% of users report feeling more in control"
//    case stepTwo = "“I finally stopped wasting hours on my phone every night.” - Igor S."
//    case hold = ""
//}

struct OBQuizLoading: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var percentageCompleted: Int = 0
    @State private var trim: CGFloat = 0.0
    
    @State private var timer: Timer? = nil
    
    @State private var loadingPhase: LoadingPhase = .start
    
    let startingColors: [Color] = [Color.primaryBlue, .purple]
    let hueMultiplier: CGFloat = 1.20
            
    var body: some View {
        VStack(spacing: 48) {
            Loader()
            
            VStack(spacing: 18) {
                
                Text("Calculating")
                    .font(.grotesk(size: 38, weight: .semibold))
//                    .font(.system(size: 38).weight(.semibold))
                    .multilineTextAlignment(.center)
                
                ZStack {
                    Text(LoadingPhase.start.rawValue)
                        .opacity(loadingPhase == .start ? 1 : 0)
//                        .offset(y: loadingPhase == .start ? 0 : 32)
                    
                    Text(LoadingPhase.stepOne.rawValue)
                        .opacity(loadingPhase == .stepOne ? 1 : 0)
//                        .offset(y: loadingPhase == .stepOne ? 0 : 32)

                    Text(LoadingPhase.stepTwo.rawValue)
                        .opacity(loadingPhase == .stepTwo ? 1 : 0)
//                        .offset(y: loadingPhase == .stepTwo ? 0 : 32)
                }
                .foregroundStyle(.white.opacity(0.65))
                .font(.grotesk())
                .animation(.smooth(duration: 0.8), value: loadingPhase)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineSpacing(4.0)
                .lineLimit(2, reservesSpace: true)
            }
        }
        .tint(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if percentageCompleted > 70 {
                ZStack {
                    LottieView(animation: .named("trophy"))
                    LottieView(animation: .named("poop"))
                }
                .hidden()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding()
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            startLoading()
        }
        
        vm.calculate()
    }
    
    @ViewBuilder
    private func Loader() -> some View {
        Circle()
            .stroke(lineWidth: 18.0)
            .frame(square: 220)
            .foregroundStyle(.secondary.opacity(0.15))
            .overlay {
                Circle()
                    .trim(from: 0.0, to: trim)
                    .stroke(style: .init(lineWidth: 20.0, lineCap: .round))
                    .animation(.smooth, value: trim)
                    .frame(square: 220)
                    .foregroundStyle(Color.primaryBlue)
                    .rotationEffect(.degrees(-90))
            }
            .overlay {
                Text("\(percentageCompleted)%")
//                    .font(.system(size: 56, weight: .semibold, design: .serif))
                    .font(.grotesk(size: 56, weight: .semibold))
            }
    }
        
    private func startLoading() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { _ in
            if percentageCompleted < 100 {
                percentageCompleted += 1
                trim = CGFloat(percentageCompleted) / 100.0
                
                if percentageCompleted > 36 && percentageCompleted < 64 {
                    loadingPhase = .stepOne
                } else if percentageCompleted > 72 {
                    loadingPhase = .stepTwo
                } else if percentageCompleted < 28 {
                    loadingPhase = .start
                } else {
                    loadingPhase = .hold
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
        vm.nextStep()
        
        withAnimation(.smooth(duration: 0.45)) {
            vm.showReportProgress = true
        }
    }
}

#Preview {
    OBQuizLoading()
        .environmentObject(OBUserViewModel())
}
