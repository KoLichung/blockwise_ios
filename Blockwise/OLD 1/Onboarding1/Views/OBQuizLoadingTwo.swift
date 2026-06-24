//
//  OBQuizLoadingTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/06/25.
//

import SwiftUI
import Lottie

struct OBQuizLoadingTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var progress: CGFloat = 0.0
    @State private var displayedPercentage: Int = 0
    
    private let loadingDuration: TimeInterval = 8.0
    
    var body: some View {
        VStack(spacing: 44) {
            
            LottieView(animation: .named("light-bulb"))
                .looping()
                .frame(square: 100)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 6)
            
            VStack(spacing: 18) {
                Text("Did you know?".uppercased())
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.primaryBlue)
                    .kerning(1.0)
                
                Text("Studies show excessive screen time may reduce grey matter volume.")
                    .font(.grotesk(size: 26, weight: .medium))
                    .lineSpacing(2.0)
                
                Text("1. The Impact of Smartphone Addiction on Cognitive Function and Attention Span, Lone Star Neurology, 2025.")
                    .foregroundStyle(.secondary)
                    .font(.grotesk(.footnote, weight: .regular))
                    .frame(width: 200)
                    .lineSpacing(4.0)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.primaryBlue)
                                .frame(width: width * progress)
                        }
                        .frame(height: 4)
                }
                .frame(height: 4)
                
                Text("Preparing plan \(displayedPercentage)%")
                    .font(.grotesk())
                    .fontWeight(.medium)
                    .monospacedDigit() // Prevents text jumping
                    .contentTransition(.numericText()) // Smooth number transitions (iOS 17+)
            }
            .padding(.vertical)
            .padding(.horizontal, 32)
        }
        .onAppear(perform: setup)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }
    
    private func setup() {
        startLoading()
    }
    
    private func startLoading() {
        // Animate the progress bar
        withAnimation(.easeInOut(duration: loadingDuration)) {
            progress = 1.0
        }
        
        // Animate the percentage counter separately
        animatePercentage()
        
        SleepTask.sleep(seconds: loadingDuration) {
            vm.nextStep()
        }
    }
    
    private func animatePercentage() {
        let updateInterval: TimeInterval = loadingDuration / 100.0 // Update every 1%
        
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            if displayedPercentage < 100 {
                displayedPercentage += 1
                Haptics.feedback(style: .soft)
            } else {
                timer.invalidate()
                Haptics.successFeedback()
            }
        }
    }
}

#Preview {
    OBQuizLoadingTwo()
        .environmentObject(OBUserViewModel())
}
