//
//  OB14.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OB14: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var appearAnimation: Bool = false
    
    var screenTimeGoal: TimeInterval {
        vm.screenTimeGoal
    }
    
    var screenTimeAvg: Int {
        vm.screenTimePoints
    }
    
    var difference: TimeInterval {
        TimeInterval(screenTimeAvg * 3600) - screenTimeGoal
    }
    
    var body: some View {
        VStack(spacing: 32) {
//            Image(.calendarWithFlame)
//                .resizable()
//                .scaledToFit()
//                .frame(square: 200)
//                .overlay {
//                    Text("\(vm.streakGoal)")
//                        .font(.grotesk(size: 52, weight: .semibold))
//                        .offset(y: 52)
//                }
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
            
            Group {
                Text("\(vm.streakGoal) days ").foregroundStyle(Color.blueAccent) +
                Text("may be a great start to build a habit")
            }
            .frame(height: 80)
            .font(.grotesk(.title, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .lineSpacing(2.0)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            
            if difference > 0 {
                Text("Means up to **\(TimeFormatter.display(difference * Double(vm.streakGoal), style: .hoursOnly))** hours saved!")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.2), value: appearAnimation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
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
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.nextPage(progressBar: 0.85)
    }
}

#Preview {
    OB14()
        .environmentObject(OBVM())
}
