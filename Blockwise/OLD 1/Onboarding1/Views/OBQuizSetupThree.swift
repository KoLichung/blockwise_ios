//
//  OBQuizSetupThree.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/06/25.
//

import SwiftUI
import Lottie
import FamilyControls

struct OBQuizSetupThree: View {
    @EnvironmentObject var vm: OBUserViewModel
    @EnvironmentObject var toastManager: ToastManager
        
    @State private var appearAnimation: Bool = false
    @State private var learnMoreView: Bool = false
        
    var body: some View {
        VStack(alignment: .center, spacing: 64) {
            
            VStack(alignment: .center, spacing: 32) {
                LottieView(animation: .named("wand"))
                    .looping()
                    .animationSpeed(0.8)
                    .frame(square: 150)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 32)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                Text("Connect to Screen Time, Securely.")
//                    .font(.system(size: 30, weight: .semibold))
                    .font(.grotesk(size: 30, weight: .semibold))
                    .lineSpacing(4.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.1), value: appearAnimation)
                
                Text("Let's make the magic work.")
                    .font(.grotesk(.title3, weight: .regular))
//                    .font(.title3.weight(.regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(6.0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.2), value: appearAnimation)
            }

        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 44) {
                Button {
                    vm.requestAuthorization {
                        action()
                    } errorCompletion: { error in
                        toastManager.error(error.localizedDescription)
                        Haptics.errorFeedback()
                    }
                } label: {
                    Circle()
                        .frame(square: 64)
                        .foregroundStyle(Color.indigo)
                        .overlay {
                            Image(systemName: "link")
                                .foregroundStyle(.white)
                                .font(.system(size: 24.0).weight(.semibold))
                        }
                }
                .phaseAnimator([false, true]) { view, phase in
                    view
                        .background {
                            Circle()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(Color.indigo)
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
                .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)

                VStack(spacing: 18) {
                    
                    HStack(spacing: 8) {
                        Image(systemName: "applelogo")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        Text("Secured by Apple")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.25))
                    }
                    .padding(.bottom, 4)
                    
                    Text("You data is protected by Apple and never leaves your device.")
                        .font(.grotesk(.footnote, weight: .regular))
//                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                        .lineSpacing(4.0)
                    
                    Button("Learn More") {
                        learnMoreView = true
                        Haptics.feedback(style: .rigid)
                    }
                    .font(.grotesk(.subheadline, weight: .semibold))
//                    .font(.subheadline.weight(.semibold))
                }
                .offset(y: appearAnimation ? 0 : 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.smooth(duration: 0.35).delay(0.75), value: appearAnimation)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $learnMoreView) {
            LearnMoreModal()
                .presentationDetents([.medium])
        }
        .onAppear(perform: setup)
    }
    
    @ViewBuilder
    private func LearnMoreModal() -> some View {
        let secondaryBlue: Color = Color(hex: 0x2A2D55)

        VStack(alignment: .leading, spacing: 32) {
            Text("Your data is protected by Apple and never leaves your device.")
                .font(.grotesk(.title2, weight: .semibold))
            
            Text("We respect your privacy and employ Apple’s security protocols. No data is stored locally or remotely, nor is it shared with third parties.")
                .font(.grotesk(.body, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Give permission") {
                learnMoreView = false
                
                vm.requestAuthorization {
                    action()
                } errorCompletion: { error in
                    toastManager.error(error.localizedDescription)
                    Haptics.errorFeedback()
                }
            }
            .foregroundStyle(Color.indigo)
        }
        .padding(32)
        .background(secondaryBlue, ignoresSafeAreaEdges: .all)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextStep()
        vm.showSetupProgress = false
        Logger.success("Auth Granted")
        vm.mixPanelTrack(name: "Quiz Setup 3 - Auth")
    }
    
}

#Preview {
    NavigationStack {
        OBQuizSetupThree()
            .environmentObject(OBUserViewModel())
            .environmentObject(ToastManager())
    }
}

/*
 
 Button {
     withAnimation {
         isLoading = true
     }
     
//                Task {
//                    await requestAuth()
//
//                    withAnimation {
//                        isLoading = false
//                    }
//                }
 } label: {
     Capsule(style: .continuous)
         .frame(height: 60.0)
         .foregroundStyle(Color.primaryBlue)
         .frame(maxWidth: isLoading ? 60 : .infinity)
         .frame(maxWidth: .infinity)
         .overlay {
             Text("Connect")
                 .foregroundStyle(.white)
                 .font(.title3.weight(.semibold))
                 .opacity(isLoading ? 0 : 1)
                 .scaleEffect(isLoading ? 0.25 : 1.0)
             
             ProgressView()
                 .scaleEffect(1.35)
                 .opacity(!isLoading ? 0 : 1)
                 .scaleEffect(!isLoading ? 0.25 : 1.0)
                 .tint(.white)
         }
 }
 
 */

/*
 
 var body: some View {
     VStack(alignment: .center, spacing: 64) {
         Text("Connect to Screen Time, Securely")
             .font(.system(size: 30, weight: .semibold))
             .multilineTextAlignment(.center)
             .lineSpacing(4.0)
         
         AuthButton()
         
         Image(systemName: "chevron.compact.up")
             .font(.system(size: 64))
             .foregroundStyle(Color.primaryBlue)
             .phaseAnimator([true, false]) { view, phase in
                 view
                     .offset(y: phase ? -24 : 0)
                     .opacity(phase ? 1 : 0.75)
             } animation: { _ in
                     .smooth(duration: 0.5)
             }
             .offset(x: -67)
     }
     .multilineTextAlignment(.center)
     .frame(maxWidth: .infinity, maxHeight: .infinity)
     .safeAreaInset(edge: .bottom) {
         VStack(spacing: 18) {
             HStack(spacing: 8) {
                 Image(systemName: "applelogo")
                     .font(.subheadline.weight(.medium))
                     .foregroundStyle(.secondary)

                 Text("Secured by Apple")
                     .font(.footnote.weight(.medium))
                     .foregroundStyle(.secondary)
             }
             .padding(8)
             .background {
                 RoundedRectangle(cornerRadius: 10, style: .continuous)
                     .stroke(lineWidth: 2.0)
                     .foregroundStyle(.secondary.opacity(0.25))
             }
             .padding(.bottom, 4)

             Text("You data is protected by Apple and never leaves your device.")
                 .font(.footnote)
                 .multilineTextAlignment(.center)
                 .foregroundStyle(.secondary)
                 .padding(.horizontal, 32)
             
             Button("Learn More") {
                 
             }
         }
     }
     .padding(.horizontal, 32)
     .padding(.vertical)
     .onAppear(perform: setup)
 }
 
 */
