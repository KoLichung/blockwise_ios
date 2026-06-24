//
//  OBQuizResultThree.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizResultThree: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    
    let height: CGFloat = UIScreen.main.bounds.height
    
    @State private var rectOne: CGFloat = 0
    @State private var rectTwo: CGFloat = 0
    
    let background: Color = Color(hex: 0x200107)

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                
                Text("Your answers indicate you're developing a concerning phone addiction.*")
                    .lineSpacing(2.0)
                    .font(.grotesk(.title2, weight: .semibold))
//                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        
            let baseUnit: CGFloat = height * 0.0055
            
            HStack(alignment: .bottom, spacing: 32) {
                
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(
                            width: 72,
                            height: appearAnimation ? baseUnit * rectOne : baseUnit,
                            alignment: .bottom
                        )
                        .foregroundStyle(.pink)
                        .overlay(alignment: .top) {
                            Text("\(Int(rectOne))")
//                                .font(.system(size: 22, weight: .semibold))
                                .font(.grotesk(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .scaleEffect(appearAnimation ? 1 : 0.5)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                    
                    Text("Your Score")
                        .font(.grotesk(.footnote, weight: .regular))
//                        .font(.footnote)
                        .opacity(appearAnimation ? 1 : 0)
                }
                
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(
                            width: 72,
                            height: appearAnimation ? baseUnit * rectTwo : baseUnit,
                            alignment: .bottom
                        )
                        .foregroundStyle(.gray)
                        .overlay(alignment: .top) {
                            Text("\(Int(rectTwo))")
//                                .font(.system(size: 22, weight: .semibold))
                                .font(.grotesk(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .scaleEffect(appearAnimation ? 1 : 0.5)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                    
                    Text("Good Score")
//                        .font(.footnote)
                        .font(.grotesk(.footnote, weight: .regular))
                        .opacity(appearAnimation ? 1 : 0)
                }
                .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
            }
            .frame(height: (baseUnit * rectOne) + 32, alignment: .bottom)
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.pink)
                
                Group {
                    Text("\(Int(rectOne - rectTwo))%").foregroundStyle(.pink) +
                    Text(" higher risk of addiction")
                }
                .font(.grotesk(.body, weight: .medium))
//                .font(.body.weight(.medium))
            }
            .padding(10)
            .background(.red.opacity(0.15), in: .rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.top, .horizontal], 32)
        .padding(.top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 20) {                
                GlassButton("Check symptoms") {
                    action()
                }
                .foregroundStyle(Color.pink)
                
                Text("*This result is an indication only, not a medical diagnosis. For a definitive assessment, please contact your healthcare provider.")
                    .multilineTextAlignment(.center)
                    .font(.grotesk(.caption, weight: .regular))
//                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
            .lineSpacing(4.0)
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(0.85), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)

    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35)) {
                appearAnimation = true
            }
        }
        
        rectOne = min(64, vm.sumOfUserValues)
        rectTwo = vm.sumOfNormalValues
    }

    private func action() {
        vm.nextStep()
        vm.showReportProgress = false
        vm.mixPanelTrack(name: "Quiz Result 3")
    }
}

#Preview {
    OBQuizResultThree()
        .environmentObject(OBUserViewModel())
}
