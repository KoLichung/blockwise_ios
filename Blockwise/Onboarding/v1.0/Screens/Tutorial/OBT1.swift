//
//  OBT1.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/12/25.
//

import SwiftUI

struct OBT1: View {
    @EnvironmentObject var vm: OBTVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Nice work, \(vm.storedName)!\nYou're off to a great start.")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
                Text("We're proud of how far you've come.")
                    .foregroundStyle(.secondary)
                    .font(.grotesk(.subheadline, weight: .regular))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.mascotteNavigator2)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 32)
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
    OBT1()
        .environmentObject(OBTVM())
}

/*
 var body: some View {
     VStack(spacing: 32) {
         Image(.mascotteNavigator2)
             .resizable()
             .scaledToFit()
             .padding(.horizontal, 32)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth, value: appearAnimation)
             .background {
                 LottieView(animation: .named("celebration-animation"))
                     .looping()
                     .scaleEffect(2.0)
                     .offset(y: -128)
             }

         VStack(spacing: 18) {
             
             Text("Welcome aboard, \(vm.firstName)!")
                 .font(.grotesk(.title, weight: .semibold))
                 .multilineTextAlignment(.center)
                 .lineSpacing(2.0)
             
             Text("Let's get you set up and ready to be more present.")
                 .multilineTextAlignment(.center)
                 .foregroundStyle(.secondary)
                 .font(.grotesk(.body, weight: .regular))
                 .lineSpacing(4.0)
         }
         .opacity(appearAnimation ? 1 : 0)
         .offset(y: appearAnimation ? 0 : 32)
         .scaleEffect(appearAnimation ? 1 : 0.95)
         .animation(.smooth.delay(0.15), value: appearAnimation)
         
     }
     .frame(maxWidth: .infinity, maxHeight: .infinity)
     .padding(32)
     .safeAreaInset(edge: .bottom) {
         GlassButton("Let's do this!") {
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
 */
