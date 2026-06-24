//
//  OB10.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB10: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
//            Image(.mascotteSitOnClock)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 24)
//                .padding(.vertical)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
            
            VStack(spacing: 18) {
                Text("You’re in the right place!")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)

                Text("We built this app to help people exactly where you are right now.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .lineSpacing(4.0)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        // Specific to view
        vm.showProgressBar = true

        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Made for you")
    }
}

#Preview {
    OB10()
        .environmentObject(OBVM())
}
