//
//  OBN4.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/01/26.
//

import SwiftUI

struct OBN4: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var screenTimeGoal: TimeInterval {
        vm.screenTimeGoal
    }
    
    var screenTimeAvg: Int {
        vm.screenTimePoints
    }
    
    var difference: TimeInterval {
        TimeInterval(screenTimeAvg * 3600) - screenTimeGoal
    }

    var body: some View {
        VStack(spacing: 32) {
//            Image(.mascotteTrophy)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 32)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
            
            Text("Setting a goal is a huge first step!")
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
            
//            if difference > 0 {
//                Text("You could save up to **\(TimeFormatter.display(difference * Double(7), style: .hoursOnly)) hours** in the first 7 days.")
//                    .font(.grotesk(.subheadline, weight: .regular))
//                    .multilineTextAlignment(.center)
//                    .foregroundStyle(.secondary)
//                    .opacity(appearAnimation ? 1 : 0)
//                    .offset(y: appearAnimation ? 0 : 32)
//                    .scaleEffect(appearAnimation ? 1 : 0.95)
//                    .animation(.smooth.delay(0.2), value: appearAnimation)
//            }
            
            Text("Reminding yourself of why you want to set this limit in an important step to be able to stay on track and make positive changes.")
                .font(.grotesk(.subheadline, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(4.0)
                .foregroundStyle(.secondary)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
    }
    
    private func action() {
        vm.nextPage(progressBar: 0.85)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Congrats")
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
}

#Preview {
    OBN4()
        .environmentObject(OBVM())
}
