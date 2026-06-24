//
//  ResetStreaksView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 17/12/25.
//

import SwiftUI
import Lottie

struct ResetStreaksView: View {
    @EnvironmentObject var vm: UserViewModel
    
    @Binding var showStreakReset: Bool
    
    @State private var appearAnimation: Bool = false
    
    @State private var showAnimation: Bool = false
    
    @State private var streakCount: Int = 0
    @State private var triggerStrike: Bool = false
    
    var isZero: Bool {
        streakCount == 0
    }
    
    @State private var value: Double = 5
            
    var range: ClosedRange<Int> = 1...30
    
    var completion: ((_ interval: TimeInterval) -> Void)
    var dismissCompletion: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .opacity(appearAnimation ? 1.0 : 0)
            
            VStack(spacing: 0) {
                Text("\(streakCount)")
                    .font(.grotesk(size: 128, weight: .semibold))
                    .foregroundStyle(Color.primaryOrange)
                    .contentTransition(.numericText(value: Double(streakCount)))
                    .opacity(showAnimation ? 1 : 0)
                    .scaleEffect(showAnimation ? 1.0 : 1.1)
                    .animation(.smooth.delay(0.3), value: showAnimation)
                    .offset(y: isZero ? -48 : 0)
                
                Text("Day Streak")
                    .font(.grotesk(size: 32, weight: .semibold))
                    .foregroundStyle(Color.primaryOrange)
                    .opacity(showAnimation ? 1 : 0)
                    .scaleEffect(showAnimation ? 1.0 : 1.1)
                    .animation(.smooth.delay(0.35), value: showAnimation)
                    .offset(y: isZero ? -48 : 0)
                
                Text("App unlocked and streak resetted")
                    .font(.grotesk(size: 22, weight: .semibold))
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray)
                    .opacity(showAnimation ? 1 : 0)
                    .offset(y: showAnimation ? -32 : 0)
                    .scaleEffect(showAnimation ? 1.0 : 1.1)
                    .animation(.smooth.delay(1.15), value: showAnimation)

            }
                        
            LightningView(trigger: $triggerStrike)
            
            VStack(spacing: 32) {
                Text("How much time do you need?")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.white)
                
                Picker("", selection: $value) {
                    ForEach(range, id: \.self) { value in
                        Text("\(value) min")
                            .font(.grotesk(size: 20, weight: .medium))
                            .tag(Double(value))
                    }
                    .foregroundStyle(.white)
                }
                .pickerStyle(.wheel)
                .padding(.vertical)
                
                Text("Your streak will be resetted if you unlock")
                    .multilineTextAlignment(.center)
                    .font(.grotesk(.body, weight: .medium))
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 14) {
                    
                    GlassButton("Use for \(Int(value)) min", labelColor: .red, background: .red.opacity(0.15)) {
                        withAnimation {
                            showAnimation = true
                        }
                        
                        SleepTask.sleep(seconds: 0.85) {
                            strike()
                        }
                        
                        completion(value * 60)
                        
                        SleepTask.sleep(seconds: 1.0) {
                            Haptics.feedback(style: .heavy)
                            withAnimation {
                                streakCount = 0
                            }
                        }
                    }
                    
                    GlassButton("Go Back", labelColor: .gray, background: .gray.opacity(0.15)) {
                        dismissCompletion()
                    }

                }
                .padding(.horizontal, 32)
            }
            .opacity(appearAnimation ? 1 : 0)
            .scaleEffect(appearAnimation ? 1.0 : 1.1)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            .opacity(showAnimation ? 0 : 1)
            
            Button {
                withAnimation {
                    showStreakReset = false
                }
            } label: {
                Capsule(style: .continuous)
                    .frame(height: 50)
                    .foregroundStyle(Color.gray.opacity(0.25))
                    .overlay {
                        Text("Okay")
                            .font(.grotesk(size: 18.5, weight: .semibold))
                            .foregroundStyle(Color.gray)
                    }
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
            .opacity(showAnimation ? 1 : 0)
            .scaleEffect(showAnimation ? 1.0 : 1.1)
            .animation(.smooth.delay(1.35), value: showAnimation)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        streakCount = vm.currentStreak
        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.4)) {
                appearAnimation = true
            }
        }
    }
    
    private func strike() {
        triggerStrike.toggle()
    }
}

#Preview {
    ResetStreaksView(showStreakReset: .constant(true)) { _ in
        
    } dismissCompletion: {
        
    }
    .environmentObject(UserViewModel())
}

/*
 struct ResetStreaksView: View {
     @Binding var showStreakReset: Bool
     
     @State private var appearAnimation: Bool = false
     
     @State private var streakCount: Int = 142
     @State private var triggerStrike: Bool = false
     
     var isZero: Bool {
         streakCount == 0
     }

     var body: some View {
         ZStack {
             Color.black.ignoresSafeArea()
                 .opacity(appearAnimation ? 1 : 0)
             
             VStack(spacing: 0) {
                 Text("\(streakCount)")
                     .font(.grotesk(size: 128, weight: .semibold))
                     .foregroundStyle(Color.primaryOrange)
                     .contentTransition(.numericText(value: Double(streakCount)))
                     .opacity(appearAnimation ? 1 : 0)
                     .scaleEffect(appearAnimation ? 1.0 : 1.1)
                     .animation(.smooth.delay(0.1), value: appearAnimation)
                     .offset(y: isZero ? -48 : 0)
                 
                 Text("Day Streak")
                     .font(.grotesk(size: 32, weight: .semibold))
                     .foregroundStyle(Color.primaryOrange)
                     .opacity(appearAnimation ? 1 : 0)
                     .scaleEffect(appearAnimation ? 1.0 : 1.1)
                     .animation(.smooth.delay(0.15), value: appearAnimation)
                     .offset(y: isZero ? -48 : 0)
                 
                 Text("Resetted")
                     .font(.grotesk(size: 48, weight: .semibold))
                     .foregroundStyle(Color.gray)
                     .opacity(appearAnimation ? 1 : 0)
                     .offset(y: appearAnimation ? -32 : 0)
                     .scaleEffect(appearAnimation ? 1.0 : 1.1)
                     .animation(.smooth.delay(0.95), value: appearAnimation)

             }
             
             LightningView(trigger: $triggerStrike)
         }
         .overlay(alignment: .bottom) {
             Button {
                 withAnimation {
                     showStreakReset = false
                 }
             } label: {
                 Capsule(style: .continuous)
                     .frame(height: 55)
                     .foregroundStyle(Color.gray.opacity(0.25))
                     .overlay {
                         Text("Okay")
                             .font(.grotesk(size: 18.5, weight: .semibold))
                             .foregroundStyle(Color.gray)
                     }
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
             .opacity(appearAnimation ? 1 : 0)
             .scaleEffect(appearAnimation ? 1.0 : 1.1)
             .animation(.smooth.delay(1.35), value: appearAnimation)
         }
         .onAppear(perform: setup)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.1) {
             withAnimation(.smooth(duration: 0.4)) {
                 appearAnimation = true
             }
         }
         
         SleepTask.sleep(seconds: 0.65) {
             strike()
         }
         
         SleepTask.sleep(seconds: 0.80) {
             Haptics.feedback(style: .heavy)
             withAnimation {
                 streakCount = 0
             }
         }
     }
     
     private func strike() {
         triggerStrike.toggle()
     }
 }

 */

/*
 
 var body: some View {
     ZStack {
         Color.black.ignoresSafeArea()
             .opacity(appearAnimation ? showAnimation ? 1 : 0.8 : 0)
         
         VStack(spacing: 0) {
             Text("\(streakCount)")
                 .font(.grotesk(size: 128, weight: .semibold))
                 .foregroundStyle(Color.primaryOrange)
                 .contentTransition(.numericText(value: Double(streakCount)))
                 .opacity(showAnimation ? 1 : 0)
                 .scaleEffect(showAnimation ? 1.0 : 1.1)
                 .animation(.smooth.delay(0.3), value: showAnimation)
                 .offset(y: isZero ? -48 : 0)
             
             Text("Day Streak")
                 .font(.grotesk(size: 32, weight: .semibold))
                 .foregroundStyle(Color.primaryOrange)
                 .opacity(showAnimation ? 1 : 0)
                 .scaleEffect(showAnimation ? 1.0 : 1.1)
                 .animation(.smooth.delay(0.35), value: showAnimation)
                 .offset(y: isZero ? -48 : 0)
             
             Text("Resetted")
                 .font(.grotesk(size: 48, weight: .semibold))
                 .foregroundStyle(Color.gray)
                 .opacity(showAnimation ? 1 : 0)
                 .offset(y: showAnimation ? -32 : 0)
                 .scaleEffect(showAnimation ? 1.0 : 1.1)
                 .animation(.smooth.delay(1.15), value: showAnimation)

         }
                     
         LightningView(trigger: $triggerStrike)
         
         VStack(spacing: 32) {
             LottieView(animation: .named("exclamation-double"))
                 .looping()
                 .frame(square: 128)

             VStack(spacing: 14) {
                 Text("This will reset your streak")
                     .font(.grotesk(size: 26, weight: .semibold))
                     .multilineTextAlignment(.center)
                     .lineSpacing(2.0)
                     .foregroundStyle(.white)
                     .padding(.horizontal, -32)
                 
                 Text("You’ve reached your screen time limit for today.")
                     .font(.grotesk(size: 18, weight: .semibold))
                     .multilineTextAlignment(.center)
                     .lineSpacing(4.0)
                     .foregroundStyle(.white.opacity(0.8))
             }
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .opacity(appearAnimation ? 1 : 0)
         .scaleEffect(appearAnimation ? 1.0 : 1.1)
         .animation(.smooth.delay(0.1), value: appearAnimation)
         .padding(32)
         .safeAreaInset(edge: .bottom) {
             VStack(spacing: 14) {
                 GlassButton("Go Back") {
                     withAnimation {
                         showStreakReset = false
                     }
                 }
                 
                 GlassButton("Unlock & Reset Streak", labelColor: .white, color: .red) {
                     withAnimation {
                         showAnimation = true
                     }
                     
                     SleepTask.sleep(seconds: 0.85) {
                         strike()
                     }
                     
                     SleepTask.sleep(seconds: 1.0) {
                         Haptics.feedback(style: .heavy)
                         withAnimation {
                             streakCount = 0
                         }
                     }
                 }
             }

         }
         .padding(.horizontal, 32)
         .opacity(showAnimation ? 0 : 1)
         
         Button {
             withAnimation {
                 showStreakReset = false
             }
         } label: {
             Capsule(style: .continuous)
                 .frame(height: 55)
                 .foregroundStyle(Color.gray.opacity(0.25))
                 .overlay {
                     Text("Okay")
                         .font(.grotesk(size: 18.5, weight: .semibold))
                         .foregroundStyle(Color.gray)
                 }
         }
         .padding(.horizontal, 32)
         .padding(.vertical)
         .opacity(showAnimation ? 1 : 0)
         .scaleEffect(showAnimation ? 1.0 : 1.1)
         .animation(.smooth.delay(1.35), value: showAnimation)
         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
         
     }
     .onAppear(perform: setup)
 }

 
 */
