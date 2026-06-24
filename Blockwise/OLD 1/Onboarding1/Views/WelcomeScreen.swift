//
//  WelcomeScreen.swift
//  Blockwise
//
//  Created by Ivan Sanna on 31/08/25.
//

import SwiftUI

struct WelcomeScreen: View {
    var body: some View {
        VStack {
            
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 56) {
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("You're in the right place.")
                        .font(.grotesk(size: 32, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2.0)
                        .frame(height: 100)
                    
                    Text("Quitting phone addiction can improve your clarity, confidence and happiness.")
                        .font(.grotesk(size: 19, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4.0)
                        .padding(.trailing, 32)
                }

                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 32) {
                    GlassButton("Start Quiz") {
                        action()
                    }
                    .foregroundStyle(Color.accentBlue)
                    
                    Text("By continuing, you accept our \(terms) and \(privacy)")
                        .multilineTextAlignment(.center)
                        .font(.grotesk(.footnote, weight: .regular))
                        .padding(.horizontal, 32)
                        .padding(.horizontal)
                        .opacity(0.8)
                        .lineSpacing(4.0)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 32)
        }

    }
    
    private func action() {
        
    }
    
    @ViewBuilder
    private var privacy: Text {
        Text("**[Privacy Policy](\(AppConfiguration.privacyURL))**")
    }
    
    @ViewBuilder
    private var terms: Text {
        Text("**[Terms of Service](\(AppConfiguration.privacyURL))**")
    }

}

#Preview {
    WelcomeScreen()
}
