//
//  OBN1.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/01/26.
//

import SwiftUI

struct OBN1: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            Text("Simple app blockers can cause a yo-yo effect.")
                .font(.grotesk(size: 26, weight: .semibold))
                .padding(.trailing)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.chart)
//                .resizable()
//                .scaledToFit()
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)

            Text("Research on habit formation shows that extreme restrictions can trigger cycles of control and relapse, instead of lasting change.")
                .font(.grotesk(.body, weight: .medium))
                .opacity(0.5)
                .lineSpacing(4.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)

        }
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
        vm.nextPage(progressBar: 0.30)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Problem")
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
    OBN1()
        .environmentObject(OBVM())
}
