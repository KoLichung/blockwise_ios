//
//  OBCongrats_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 25/01/26.
//

import SwiftUI
import Lottie

struct OBCongrats_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    @State private var triggerCheckmark: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 10)
            
            Checkmark(
                size: 48,
                trigger: $triggerCheckmark,
                backgroundColor: Color.skyBlue
            )
            
            VStack(spacing: 14) {
                Text("You're all set!")
                    .font(.grotesk(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Your goal is now active")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            .foregroundStyle(.black)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            LottieView(animation: .named("confetti"))
                .looping()
                .scaleEffect(2.0)
                .offset(y: -72)
        }
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding()
            .padding(.horizontal, 32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
        
        SleepTask.sleep(seconds: 0.2) {
            triggerCheckmark.toggle()
            Haptics.successFeedback()
        }
    }
    
    private func action() {
        vm.showProgressBarTwo = false
        
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > All set")
    }
}

#Preview {
    OBCongrats_V2()
        .environmentObject(OBVM_V2())
}
