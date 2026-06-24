//
//  OB2Report_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/01/26.
//

import SwiftUI

struct OB2Report_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    // View properties
    @State private var years: Int = 0
    @State private var days: Int = 0
    @State private var timer: Timer? = nil
    
    // Base timer tick
    private let updateFrequency: TimeInterval = 0.02
    
    // Independent durations so days can end later than years
    private let yearsDuration: TimeInterval = 1.5
    private let daysDuration: TimeInterval = 2.0
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                Text("At your current pace, you'll spend")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .lineSpacing(4.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
                Text("\(years) years")
                    .font(.grotesk(size: 80, weight: .semibold))
                    .foregroundStyle(Color.pink)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                
                Group {
                    Text("of your life looking at your phone.")
                }
                .font(.grotesk(size: 26, weight: .semibold))
                .lineSpacing(4.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.15), value: appearAnimation)
                
                Group {
                    Text("It's almost") +
                    Text(" \(vm.monthsNextYear) months ").bold().foregroundStyle(Color.pink) +
                    Text("in 2026 alone.")
                }
                .font(.grotesk(size: 20, weight: .semibold))
                .padding(.horizontal)
                .offset(y: 24)
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
                
                Text("Projection of your current Screen Time habits, based on an average of 16 waking hours each day.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
        AnalyticsService.shared.track("OBV2 > Bad news")
    }
    
    private func startTimer() {
        let yearsTarget: Int = vm.yearsSpent
        
        Logger.debug(yearsTarget.description)
        
        // Independent step counts
        let yearSteps = max(1, Int(yearsDuration / updateFrequency))
        
        let yearsIncrement = 1.0 / Double(yearSteps)
        
        var yearsProgress = 0.0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { t in
            var shouldInvalidate = true
            
            if yearsProgress < 1.0 {
                yearsProgress = min(1.0, yearsProgress + yearsIncrement)
                years = Int(round(yearsProgress * Double(yearsTarget)))
            }
            
            // Keep timer alive until both are done
            if yearsProgress < 1.0 {
                shouldInvalidate = false
            }
            
            if shouldInvalidate {
                t.invalidate()
            }
        }
    }
}

#Preview {
    OB2Report_V2()
        .environmentObject(OBVM_V2())
}
