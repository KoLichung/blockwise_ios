//
//  OBPaywall_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI

struct OBPaywall_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Space(height: 18)
                
                VStack(spacing: 14) {
                    Text("\(vm.name), you custom plan is ready.")
                        .font(.grotesk(size: 28, weight: .semibold))
                        .foregroundStyle(.textC)
                        .multilineTextAlignment(.center)
                    
                    Text("Your data is completely private and never leaves your device.")
                        .font(.grotesk(.body, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineSpacing(2.0)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                
                Image(.beforeAfter)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 8)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .background {
                LinearGradient(
                    colors: [.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        
    }
}

#Preview {
    OBPaywall_V2()
        .environmentObject(OBVM_V2())
}
