//
//  OBQuizResultOne.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

struct OBQuizResultOne: View {
    @EnvironmentObject var vm: OBUserViewModel
        
    let checkSize: CGFloat = 32.0
    
    let color: Color = Color.primaryBlue
    let background: Color = Color(hex: 0x200107)
    
    @State private var appearAnimation: Bool = false

    var body: some View {
        VStack(spacing: 40) {
            LottieView(animation: .named("exclamation-double"))
                .playing(loopMode: .loop)
                .frame(square: 128)
            
//            VStack(spacing: 14) {
//                CheckmarkShape(trimEnd: 1.0)
//                    .trim(from: 0.0, to: 1.0)
//                    .stroke(
//                        color,
//                        style: StrokeStyle(
//                            lineWidth: checkSize / 14,
//                            lineCap: .round,
//                            lineJoin: .round
//                        )
//                    )
//                    .frame(square: checkSize / 2.0)
//                
//                Text("Analysis Completed".uppercased())
//                    .font(.footnote.weight(.medium))
//                    .foregroundStyle(.pink)
//                    .kerning(1.0)
                
                Text("\(vm.firstName), we've some bad news.")
                .font(.grotesk(size: 32, weight: .semibold))
//                    .font(.system(size: 30).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.25), value: appearAnimation)
                
//            }
            
            Space(height: 28)
            
            Text("Tap to reveal the results")
                .font(.grotesk(.subheadline, weight: .regular))
//                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(6.0)
                .padding(.bottom)
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.45), value: appearAnimation)

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
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.50), value: appearAnimation)

        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35, extraBounce: 0.15)) {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.currentReportProgress = .two
        vm.nextStep()
        vm.mixPanelTrack(name: "Quiz Result 1")
    }
}

#Preview {
    OBQuizResultOne()
        .environmentObject(OBUserViewModel())
}

/*
 
 var body: some View {
     VStack(spacing: 32) {
         VStack(spacing: 14) {
             Text("Analysis Completed".uppercased())
                 .font(.footnote.weight(.medium))
                 .foregroundStyle(Color.primaryBlue)
                 .kerning(1.0)
             
             Text("Some not-so-great news, Giulia")
                 .font(.system(size: 30).weight(.semibold))
                 .multilineTextAlignment(.center)
                 .lineSpacing(4.0)
         }
         
         BlankSpace(height: 50)
         
         GlassButton {
             action()
         } label: {
             Circle()
                 .frame(square: 64)
                 .foregroundStyle(Color.secondaryOrange)
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
                         .foregroundStyle(Color.secondaryOrange)
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

     }
     .padding(32)
 }

 
 */
