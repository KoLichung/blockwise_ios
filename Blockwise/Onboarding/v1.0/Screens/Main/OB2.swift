//
//  OB2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB2: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
//            Image(.mascotteOverwhelmed)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 54)
//                .padding(.vertical)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)

            VStack(alignment: .center, spacing: 14) {
                Text("It's not your fault.".uppercased())
                    .font(.grotesk(.subheadline, weight: .bold))
                    .kerning(1.5)
                    .foregroundStyle(Color.primaryOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .foregroundStyle(Color.primaryOrange.opacity(0.15))
                    }

                Group {
                    Text("We live in a") +
                    Text(" over-stimulating ")
                        .foregroundStyle(Color.blueAccent) +
                    Text("world.")
                }
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            
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
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.nextPage()
        
        // Mixpanel - (WS1: Welcome Step 1)
        AnalyticsService.shared.track("Onboarding > WS1")
    }

}

#Preview {
    OB2()
        .environmentObject(OBVM())
}
