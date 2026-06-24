//
//  OB3Report_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/01/26.
//

import SwiftUI

struct OB3Report_V2: View {
    @EnvironmentObject var vm: OBVM_V2
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
            VStack(spacing: 14) {
                GlassButton("Continue") {
                    action()
                }
                
//                Text("Projection of your current Screen Time habits, based on an average of 16 waking hours each day.")
//                    .font(.grotesk(.footnote, weight: .regular))
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
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
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Good news")
    }
    
    private func startTimer() {
        // Targets to reach (replace with your real values or compute from vm)
        let target = vm.yearsSaved
        
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
    OB3Report_V2()
        .environmentObject(OBVM_V2())
}
