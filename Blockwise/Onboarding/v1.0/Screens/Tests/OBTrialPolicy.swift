//
//  OBTrialPolicy.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OBTrialPolicy: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 4)

            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(square: 22)
                    .foregroundStyle(Color.white, Color.primaryOrange.gradient)
                
                Text("Fair Trial policy")
                    .font(.grotesk(.subheadline, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .padding(.trailing, 2)
            .background {
                Capsule(style: .continuous)
                    .stroke(lineWidth: 2.0)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            .foregroundStyle(.black)
            
            VStack(spacing: 14) {
                Group {
                    Text("You got this! One more step to claim ") +
                    Text("your free gift!").foregroundStyle(Color.blueAccent)
                }
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            .foregroundStyle(.black)
            
            Space(height: 2)
            
//            Image(.mascotteGift)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 32)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.15), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .background(.white, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Let's go!") {
                action()
            }
            .foregroundStyle(Color.blueAccent)
            .padding(.vertical)
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
        vm.nextPage()
    }
}

#Preview {
    OBTrialPolicy()
}
