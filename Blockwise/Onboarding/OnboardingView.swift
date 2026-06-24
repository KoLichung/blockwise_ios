//
//  OnboardingView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(AppStorageKeys.Onboarding.hasFinishedOnboarding.key) var hasFinishedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if hasFinishedOnboarding {
                OBTutorialStack_V2()
                    .transition(.move(edge: .trailing).combined(with: .offset(x: -100)))
            } else {
                OBStack_V2()
                    .transition(.move(edge: .leading).combined(with: .offset(x: 100)))
            }
        }
        .onAppear(perform: logCurrentRoute)
    }
    
    private func logCurrentRoute() {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering OnboardingView")
        Logger.debug("")
        
        Logger.debug("→ Showing: OBStack_V2")
        
        Logger.debug("-----------------------------------------------------------")
    }
}

#Preview {
    OnboardingView()
}

