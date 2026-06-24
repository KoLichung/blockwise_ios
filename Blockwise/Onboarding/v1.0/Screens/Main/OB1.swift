//
//  OB1.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB1: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 4)

            HStack(spacing: 8) {
                Image(systemName: "book.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(square: 22)
                    .foregroundStyle(Color.white, Color.blueAccent.gradient)
                
                Text("Science policy")
                    .font(.grotesk(.subheadline, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .padding(.trailing, 2)
            .background {
                Capsule(style: .continuous)
                    .stroke(lineWidth: 2.0)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            .foregroundStyle(.black)
            
            VStack(spacing: 14) {
                Text("\(AppConfiguration.name) is inspired by leading research")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Major studies inspired our approach to\nscreen time and habit change")
                    .font(.grotesk(.subheadline, weight: .regular))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .background(.white, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Understood") {
                action()
            }
            .foregroundStyle(Color.blueAccent)
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
        // View specific action
        vm.showWelcomeProgress = true

        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Science")
    }
}

#Preview {
    OB1()
        .environmentObject(OBVM())
}
