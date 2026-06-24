//
//  OB16_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/01/26.
//

import SwiftUI

struct OB16_V2: View {
    @Environment(\.requestReview) var requestReview

    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
//            Space(height: 32)
            
            VStack(spacing: 14) {
                Text("\(AppConfiguration.name) is inspired by leading research")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Major studies inspired our approach to\nscreen time and habit change")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            .foregroundStyle(.black)
            
            Space(height: 2)
            
            Image(.cambridge)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .frame(height: 64)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.15), value: appearAnimation)

            Image(.harvard)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .frame(height: 64)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.20), value: appearAnimation)

            Image(.oxford)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .frame(height: 64)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.25), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
    }
    
    private func action() {
        vm.nextPage(progressTwo: 0.6)
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Science")
        
        SleepTask.sleep(seconds: 0.15) {
            requestReview()
        }
    }
}

#Preview {
    OB16_V2()
        .environmentObject(OBVM_V2())
}
