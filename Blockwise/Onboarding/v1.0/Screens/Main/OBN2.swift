//
//  OBN2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/01/26.
//

import SwiftUI

struct OBN2: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 14) {
                
                Text("\(AppConfiguration.name) helps you control your time and live a happier life")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)

                    Text("\(AppConfiguration.name) does more than blocking apps; it helps you develop healthy habits for stress management, sleep, and overall happiness.")
                        .foregroundStyle(.secondary)
                        .font(.grotesk(.subheadline, weight: .regular))
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

//            Image(.mascotteRelax)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, -32)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 1.05)
//                .animation(.smooth.delay(0.2), value: appearAnimation)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.green.opacity(0.08), ignoresSafeAreaEdges: .all)
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
        vm.nextPage(progressBar: 1.0)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > We help you")
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
    OBN2()
        .environmentObject(OBVM())
}
