//
//  OBT2_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI

struct OBT2_V2: View {
    @EnvironmentObject var vm: OBTVM_V2
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
            VStack(spacing: 14) {
                Text("Blocked apps will appear faded in your Home Screen")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                
//                Text("See exactly how much time you have left")
//                    .font(.grotesk(.body, weight: .regular))
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                let height = geo.size.height
                
                Image(.iphoneBlocked)
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .frame(maxHeight: .infinity, alignment: .bottom)
//                    .opacity(0.5)
                    .offset(y: height * 0.3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.2), value: appearAnimation)

            }

        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    .clear,
                    Color(UIColor.systemBackground).opacity(0.95),
                    Color(UIColor.systemBackground),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .frame(height: 100)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Continue") {
                    vm.nextPage()
                }
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

}

#Preview {
    OBT2_V2()
        .environmentObject(OBTVM_V2())
}
