//
//  OB19.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/11/25.
//

import SwiftUI

struct OB19: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    // View properties
    @State private var years: Int = 0
    @State private var timer: Timer? = nil
    
    // Base timer tick
    private let updateFrequency: TimeInterval = 0.01
    private let duration: TimeInterval = 0.8
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                Text("The good news is that we can help you get back")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .lineSpacing(4.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
                Text("\(years) years+")
                    .font(.grotesk(size: 72, weight: .semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                
                Group {
                    Text("of your life free from distractions, and help you achieve your dreams.")
                }
                .font(.grotesk(size: 26, weight: .semibold))
                .lineSpacing(4.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)
                
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
        .onDisappear(perform: disappear)
    }
    
    private func setup() {
        startTimer()
        
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func disappear() {
        timer?.invalidate()
    }
    
    private func action() {
        vm.showReportBar = false
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Good News")
    }
    
    private func startTimer() {
        // Targets to reach (replace with your real values or compute from vm)
        let target = vm.yearsBackCalc
        
        Logger.debug(target.description)
        
        let steps = Int(duration / updateFrequency)
        let increment = Double(target) / Double(steps)
        var currentValue = 0.0

        timer = Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { t in
            currentValue += increment
            years = Int(currentValue)

            if years >= target {
                years = target
                t.invalidate()
            }
        }
    }
}

#Preview {
    OB19()
        .environmentObject(OBVM())
}
