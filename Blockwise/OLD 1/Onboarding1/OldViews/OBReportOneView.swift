//
//  OBReportOneView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI

struct OBReportOneView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false
    
    let height: CGFloat = UIScreen.main.bounds.height
    
    let rectOne: CGFloat = 52
    let rectTwo: CGFloat = 14
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                Text("Report".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text("Your answers indicate you're developing a concerning phone addiction.*")
                    .lineSpacing(2.0)
                    .font(.title2.weight(.semibold))
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
                        .foregroundStyle(.red)
                        .overlay(alignment: .top) {
                            Text("\(Int(rectOne))")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .scaleEffect(appearAnimation ? 1 : 0.5)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                    
                    Text("Your Score")
                        .font(.footnote)
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
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .scaleEffect(appearAnimation ? 1 : 0.5)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                    
                    Text("Average")
                        .font(.footnote)
                        .opacity(appearAnimation ? 1 : 0)
                }
                .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
            }
            .frame(height: (baseUnit * rectOne) + 32, alignment: .bottom)
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                
                Group {
                    Text("38%").foregroundStyle(.red) +
                    Text(" higher risk of addiction")
                }
                .font(.body.weight(.medium))
            }
            .padding(10)
            .background(.red.opacity(0.15), in: .rect(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.top, .horizontal], 32)
        .padding(.top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 18) {
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
                
                Text("*This result is an indication only, not a medical diagnosis. For a definitive assessment, please contact your healthcare provider.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(1.0), value: appearAnimation)
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

    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35)) {
                appearAnimation = true
            }
        }
    }

    private func action() {
        // Call MixPanel
        
        // Update UserViewModel
        vm.currentReportProgress = .two
        
        // Continue
        vm.goToNextStep(step: 13)
    }

}

#Preview {
    OBReportOneView()
        .environmentObject(OBUserViewModel())
}
