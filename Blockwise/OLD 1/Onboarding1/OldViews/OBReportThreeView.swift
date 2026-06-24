//
//  OBReportThreeView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI

struct OBReportThreeView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    @State private var phaseTwo: Bool = false

    @State private var value: Int = 0
    
    @State private var timer: Timer? = nil
    
    let target = 24
    let duration = 1.0 // total duration in seconds
    let updateInterval = 0.02 // how often to update (in seconds)
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Which means, you're one track to spend:")
                .font(.system(size: 30).weight(.bold))
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.0), value: appearAnimation)

            VStack(spacing: 32) {
                Text("\(value) years")
                    .font(.system(size: 72, weight: .semibold))
                    .contentTransition(.numericText(value: Double(value)))
                    .animation(.smooth, value: value)
                    .foregroundStyle(.red)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.3), value: appearAnimation)
                
                Group {
                    Text("of your life looking at your phone.")
                }
                .font(.system(size: 24).weight(.semibold))
                .lineSpacing(4.0)
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(2.0), value: appearAnimation)

//                Group {
//                    Text("That's") +
//                    Text(" 33% ").bold().foregroundStyle(.red.gradient) +
//                    Text("of your life")
//                }
//                .font(.system(size: 24).weight(.semibold))
//                .offset(y: appearAnimation ? 0 : 32)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: 24)
//                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(2.65), value: appearAnimation)
            }
            
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                Capsule(style: .continuous)
                    .frame(height: 60)
                    .overlay {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.background)
                    }
            }
            .padding(32)
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(3.0), value: appearAnimation)
        }
//        .background {
//            Circle()
//                .foregroundStyle(
//                    .linearGradient(
//                        colors: [.red, .pink],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .opacity(0.25)
//                .blur(radius: 144)
//        }
        .onAppear(perform: setup)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35, extraBounce: 0.15)) {
                appearAnimation = true
            }
            
            startCounting()
        }
    }
    
    private func action() {
        // Call MixPanel
        
        // Update UserViewModel
        vm.showReportProgress = false
        
        // Continue
        vm.goToNextStep(step: 15)
    }
    
    private func startCounting() {
        let steps = Int(duration / updateInterval)
        let increment = Double(target) / Double(steps)
        var currentValue = 0.0

        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { t in
            currentValue += increment
            value = Int(currentValue)
            
            if value % 4 == 0 {
                Haptics.feedback(style: .light)
            }

            if value >= target {
                value = target
                t.invalidate()
            }
        }
    }

}

#Preview {
    OBReportThreeView()
        .environmentObject(OBUserViewModel())
}
