//
//  OBT7.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/01/26.
//

import SwiftUI

struct OBT7: View {
    @EnvironmentObject var vm: OBTVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Every step you take is a step toward growth.")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
                Text("Whenever you need us, we're right here.")
                    .foregroundStyle(.secondary)
                    .font(.grotesk(.subheadline, weight: .regular))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.mascotteAndStairs)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            Text("Tap to continue")
                .font(.grotesk(.body, weight: .medium))
                .foregroundStyle(.secondary.opacity(0.75))
                .padding()
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .contentShape(.rect)
        .onTapGesture {
            action()
        }
//        .safeAreaInset(edge: .bottom) {
//            GlassButton("Continue") {
//                action()
//            }
//            .padding(.horizontal, 32)
//            .padding()
//            .opacity(appearAnimation ? 1 : 0)
//            .offset(y: appearAnimation ? 0 : 32)
//            .scaleEffect(appearAnimation ? 1 : 0.95)
//            .animation(.smooth.delay(0.3), value: appearAnimation)
//        }
        .onAppear(perform: setup)
    }
    
    private func action() {
        Haptics.feedback(style: .light)
        vm.nextPage()
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
    OBT7()
        .environmentObject(OBTVM())
}
