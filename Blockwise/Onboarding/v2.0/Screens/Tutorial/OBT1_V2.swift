//
//  OBT1_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI
import Lottie

struct OBT1_V2: View {
    @EnvironmentObject var vm: OBTVM_V2
    @State private var appearAnimation: Bool = false
    @State private var showSelection: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            LottieView(animation: .named("party-popper"))
                .looping()
                .frame(square: 128)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)

            VStack(spacing: 14) {
                Text("Welcome, \(vm.storedName)!")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Let’s choose the first app to block")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

            Space(height: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton {
                showSelection.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Choose an App")
                        .font(.grotesk(size: 20, weight: .semibold))
                }
            }
            .padding()
            .padding(.horizontal, 32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .sheet(isPresented: $showSelection) {
            OBFamilySelection_V2 {
                action()
            }
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        #if targetEnvironment(simulator)
        vm.storedName = "Ivan"
        #endif
        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        
        vm.nextPage(progressBar: 0.6)
//        
//        // Mixpanel
//        AnalyticsService.shared.track("Onboarding > Science")
    }
}

#Preview {
    OBT1_V2()
        .environmentObject(OBTVM_V2())
}
