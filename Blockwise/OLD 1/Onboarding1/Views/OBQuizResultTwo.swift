//
//  OBQuizResultTwo.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizResultTwo: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    @State private var phaseTwo: Bool = false

    @State private var value: Int = 0
    
    @State private var timer: Timer? = nil
    
    let duration = 1.0 // total duration in seconds
    let updateInterval = 0.02 // how often to update (in seconds)
    
    let background: Color = Color(hex: 0x200107)
    
    var body: some View {
        VStack(spacing: 14) {
//            Text("Your report".uppercased())
//                .font(.footnote.weight(.medium))
//                .foregroundStyle(Color.primaryBlue)
//                .kerning(1.0)

            VStack(spacing: 14) {
                Text("You're on track to spend")
//                    .font(.system(size: 26).weight(.semibold))
                    .font(.grotesk(size: 26, weight: .semibold))
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.0), value: appearAnimation)
                    .lineSpacing(4.0)
                
                Text("\(value) years")
//                    .font(.system(size: 80, weight: .semibold))
                    .font(.grotesk(size: 80, weight: .semibold))
//                    .contentTransition(.numericText(value: Double(value)))
                    .animation(nil, value: value)
                    .foregroundStyle(Color.pink)
                    .offset(y: appearAnimation ? -4 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.3), value: appearAnimation)
                
                Group {
                    Text("of your life looking at your phone.")
                }
                .font(.grotesk(size: 26, weight: .semibold))
//                .font(.system(size: 26).weight(.semibold))
                .lineSpacing(4.0)
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(1.0), value: appearAnimation)

//                Group {
//                    Text("That's a total of") +
//                    Text(" 8610 days.").bold().foregroundStyle(Color.pink)
//                }
                
                Group {
                    Text("It's almost") +
                    Text(" \(Int(vm.percentOfLife))% of your remaining life.").bold().foregroundStyle(Color.pink)
                }
                .font(.grotesk(size: 20, weight: .semibold))
                .padding(.horizontal)
//                .font(.system(size: 20).weight(.semibold))
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: 24)
                .lineSpacing(4.0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(1.5), value: appearAnimation)
            }
            
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                Button {
                    action()
                } label: {
                    Circle()
                        .frame(square: 64)
                        .foregroundStyle(Color.pink)
                        .overlay {
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.white)
                                .font(.system(size: 24.0).weight(.semibold))
                        }
                }
                .phaseAnimator([false, true]) { view, phase in
                    view
                        .background {
                            Circle()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(Color.pink)
                                .scaleEffect(phase ? 1.8 : 1.0)
                                .opacity(phase ? 0.0 : 0.6)
                        }
                } animation: { phase in
                    if phase {
                        .easeInOut(duration: 1.0)
                    } else {
                        nil
                    }
                }
                .padding(.horizontal, 32)
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(2.15), value: appearAnimation)
                
                Text("*Projection based on an average of 16 waking hours.")
                    .multilineTextAlignment(.center)
//                    .font(.caption)
                    .font(.grotesk(.caption, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 32)
                    .padding(.bottom)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(2.20), value: appearAnimation)
            }
        }
        .onAppear(perform: setup)
        .onDisappear {
            timer?.invalidate()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background, ignoresSafeAreaEdges: .all)
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
        vm.currentReportProgress = .three
        
        // Continue
        vm.nextStep()
        
        vm.mixPanelTrack(name: "Quiz Result 2")
    }
    
    private func startCounting() {
        let target = Int(vm.yearsUsingPhone)
        
        let steps = Int(duration / updateInterval)
        let increment = Double(target) / Double(steps)
        var currentValue = 0.0

        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { t in
            currentValue += increment
            value = Int(currentValue)

            if value >= target {
                value = target
                t.invalidate()
            }
        }
    }
}

#Preview {
    OBQuizResultTwo()
        .environmentObject(OBUserViewModel())
}
