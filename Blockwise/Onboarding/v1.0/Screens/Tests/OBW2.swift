//
//  OBW2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/12/25.
//

import SwiftUI

struct OBW2: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {

            Text("they protect their time like gold.")
                .font(.grotesk(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
            
//            Image(.gold)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal)
//                .padding(.vertical, 20)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)
            
            Text("“It is not that we have a short time to live, but that we waste a lot of it.“\n-Seneca")
                .font(.grotesk(.subheadline, weight: .regular))
                .lineSpacing(4.0)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Let's begin") {
                vm.nextPage()
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
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
}

#Preview {
    OBW2()
        .environmentObject(OBVM())
}
