//
//  OB3.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB3: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
//            Image(.mascotteProcrastination2)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, -10)
//                .padding(.vertical)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)

            Group {
                Text("It makes us") +
                Text(" distracted, tired and stressed").foregroundStyle(Color.blueAccent) +
                Text(".")
            }
            .font(.grotesk(size: 30, weight: .semibold))
            .multilineTextAlignment(.center)
            .lineSpacing(2.0)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            
            Text("The average person spends approximately **70 days per year** looking at their phone.")
                .font(.grotesk(.subheadline, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        // View specific action
        vm.welcomeProgress = .two

        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }

    private func action() {
        vm.nextPage()
        
        // Mixpanel - (WS1: Welcome Step 2)
        AnalyticsService.shared.track("Onboarding > WS2")
    }
}

#Preview {
    OB3()
        .environmentObject(OBVM())
}
