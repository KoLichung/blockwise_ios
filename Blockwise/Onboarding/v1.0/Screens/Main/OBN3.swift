//
//  OBN3.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/01/26.
//

import SwiftUI

struct OBN3: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
//            Text("Real change comes from flexibility, not force.")
            Text("\(AppConfiguration.name) is designed to fit real life.")
                .font(.grotesk(size: 26, weight: .semibold))
                .padding(.trailing)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.chart2)
//                .resizable()
//                .scaledToFit()
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("🙌")
                            .font(.system(size: 20))
                    }
                
                Text("With \(AppConfiguration.name), you **don't need to quit** your phone.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("☘️")
                            .font(.system(size: 20))
                    }
                
                Text("We help you build a **healthier and more intentional** relationship with your phone.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.25), value: appearAnimation)

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
        vm.nextPage(progressBar: 0.33)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Solution")
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
    OBN3()
        .environmentObject(OBVM())
}
