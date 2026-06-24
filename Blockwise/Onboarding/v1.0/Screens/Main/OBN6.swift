//
//  OBN6.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/01/26.
//

import SwiftUI

struct OBN6: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            Text("We get it. The first step is always the hardest.\nWe see two options:")
                .font(.grotesk(size: 26, weight: .semibold))
                .padding(.trailing)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.beforeAfter)
//                .resizable()
//                .scaledToFit()
//                .padding()
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("😩")
                            .font(.system(size: 20))
                    }
                
                Text("Go without \(AppConfiguration.name), and forever miss on the opportunity to build a better, healthier you.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("🚀")
                            .font(.system(size: 20))
                    }
                
                Text("Let us guide you on your journey and help you create better habits and reach your goals!")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.25), value: appearAnimation)
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
        vm.nextPage(progressBar: 0.33)
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
    OBN6()
        .environmentObject(OBVM())
}
