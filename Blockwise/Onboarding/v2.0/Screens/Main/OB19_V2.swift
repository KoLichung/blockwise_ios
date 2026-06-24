//
//  OB19_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 20/01/26.
//

import SwiftUI

struct OB19_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(spacing: 14) {
//                Text("Before we start".uppercased())
//                    .font(.grotesk(size: 14, weight: .semibold))
//                    .foregroundStyle(Color.secondary)
//                    .kerning(1.5)

                Group {
                    Text({
                        var result = AttributedString()

                        var highlighted = AttributedString("It's not your fault.")
                        highlighted.foregroundColor = Color.fillOrange
                        highlighted.backgroundColor = Color.fillOrange.opacity(0.15)
                        result.append(highlighted)
                        
                        return result
                    }())
                }
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                
                Text("Modern apps are built to capture your attention, **whatever is the cost.**")
                    .font(.grotesk(.title3, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            .foregroundStyle(.black)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(32)
//        .overlay(alignment: .bottom) {
//            Image(.iphoneBlocked)
//                .resizable()
//                .scaledToFit()
//                .padding(40)
//                .offset(y: 256)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.2), value: appearAnimation)
//        }
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
        vm.nextPage(progress: 1.0)

        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Science")
    }
}

#Preview {
    OB19_V2()
        .environmentObject(OBVM_V2())
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.15))
                .frame(height: 12)
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .frame(height: 32)
        }

}

