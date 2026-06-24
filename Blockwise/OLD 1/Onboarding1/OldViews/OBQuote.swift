//
//  OBQuote.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

struct OBQuote: View {
    var body: some View {
        VStack(spacing: 32) {
            
            LottieView(animation: .named("slot-machine"))
                .looping()
                .frame(square: 180)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 4, y: 4)
            
            Text("“Now is a great moment to take control of your life.“")
            .lineSpacing(8.0)
            .font(.title2.weight(.medium))
            .multilineTextAlignment(.center)
            
            Text("Andrew Huberman")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button("Continue") {
                
            }
            .foregroundStyle(Color.primaryBlue)
        }
        .padding(.horizontal, 32)
        .padding(.vertical)
    }
}

#Preview {
    OBQuote()
}
