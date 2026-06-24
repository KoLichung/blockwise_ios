//
//  OB20.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/11/25.
//

import SwiftUI

struct OB20: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
//            Image(.mascotteAward)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 56)
//                .padding(.vertical)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth(extraBounce: 0.35), value: appearAnimation)
            
            VStack(spacing: 14) {
                Text("Great job, \(vm.firstName)!")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                
                Text("Well done on finishing the quiz. Taking a moment to reflect on your habits already puts you ahead of most people.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .lineSpacing(4.0)
                    .foregroundStyle(.secondary)
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
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Great job")
    }
}

#Preview {
    OB20()
        .environmentObject(OBVM())
}
