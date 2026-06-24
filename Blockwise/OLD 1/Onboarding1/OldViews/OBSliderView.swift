//
//  OBSliderView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/06/25.
//

import SwiftUI
import NotificationCenter

struct OBSliderView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var phaseTwo: Bool = false
    @State private var phaseTwoHalf: Bool = false
    @State private var phaseThree: Bool = false

    @State private var phoneOffsetY: CGFloat = -16
    
    @State private var canDrag: Bool = true
    
    @State private var dragOffsetY: CGFloat = .zero
    
    @State private var moveOne: Bool = false
    @State private var moveTwo: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var nextPage: Bool = false
    
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    let screenWidth: CGFloat = UIScreen.main.bounds.width
        
    var body: some View {
        
        VStack {
            phone
                .offset(y: phoneOffsetY)
                .scaleEffect(phaseTwo ? (phaseThree ? 0.95 : 1.05) : 1.0)
                .offset(y: phaseTwo ? -dragOffsetY : dragOffsetY)
                .overlay(alignment: .top) {
                    VStack(spacing: 12) {
                        Notification(
                            title: "TikTok closing is 30 sec",
                            description: "",
                            time: "now",
                            timeSensitive: true
                        )
                        .offset(y: moveOne ? 0 : 10)
                        
                        if screenHeight > 700 {
                            Notification(
                                title: "Weekly Report Available",
                                description: "Tap to open the report",
                                time: "18m"
                            )
                            .offset(y: moveTwo ? 0 : 10)
                            .scaleEffect(0.95)
                        }
                    }
                    .offset(y: 200)
                    .opacity(phaseThree ? 1.0 : 0.0)
                    .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.1), value: phaseThree)
                    
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            // Opacity Gradient
            LinearGradient(colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.systemBackground),
                .clear, .clear, .clear, .clear,
            ], startPoint: .bottom, endPoint: .top)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .offset(y: -64)
            // End Opacity Gradient
            
            LinearGradient(colors: [
                Color(UIColor.systemBackground),
                .clear, .clear, .clear,
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .opacity(phaseTwo ? phaseThree ? 0 : 1 : 0)
            
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 28) {
                
                ZStack {
                    if phaseTwo && !phaseThree {
                        
                        VStack(spacing: 10) {
                            Text("How It Works".uppercased())
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color.primaryBlue)
                                .kerning(1.0)
                            
                            Text("Unlock with Intention")
                                .font(.title.weight(.bold))
                            
                            Text("\(AppConfiguration.name) prompts you to complete a task before unlocking an app.")
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .offset(x: -dragOffsetY)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .scale(scale: 0.8)).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .scale(scale: 0.8)).combined(with: .opacity)))
                        
                    } else if phaseThree {
                        
                        VStack(spacing: 10) {
                            Text("How It Works".uppercased())
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color.primaryBlue)
                                .kerning(1.0)

                            Text("Stay in Control")
                                .font(.title.weight(.bold))
                            
                            Text("\(AppConfiguration.name) notifies you when your break ends and seamlessly re-locks your apps.")
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .transition(.move(edge: .trailing).combined(with: .scale(scale: 0.8)).combined(with: .opacity))
                        
                    } else {
                        
                        VStack(spacing: 10) {
                            Text("How It Works".uppercased())
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color.primaryBlue)
                                .kerning(1.0)

                            Text("Restrict your apps")
                                .font(.title.weight(.bold))
                            
                            Text("\(AppConfiguration.name) locks your apps and lets you access them for brief.")
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .offset(x: dragOffsetY)
                        .transition(.move(edge: .leading).combined(with: .scale(scale: 0.8)).combined(with: .opacity))
                        
                    }
                }
                .padding(.horizontal, 8)
                .allowsHitTesting(false)
                
                HStack(spacing: 8) {
                    Circle()
                        .frame(square: 8)
                        .foregroundStyle(phaseTwo ? Color.secondary.opacity(0.5) : .primary)
                        .onTapGesture {
                            withAnimation(.smooth(duration: 0.4, extraBounce: 0.15)) {
                                phaseTwo = false
                                phaseThree = false
                                phoneOffsetY = -16
                            }
                            
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.15)) {
                                moveOne = false
                                moveTwo = false
                            }
                            
                        }
                    
                    Circle()
                        .frame(square: 8)
                        .foregroundStyle(phaseThree ? Color.secondary.opacity(0.5) : !phaseTwo ? Color.secondary.opacity(0.5) : .primary)
                        .onTapGesture {
                            guard phaseThree else { return }
                            withAnimation(.smooth(duration: 0.4, extraBounce: 0.15)) {
                                phaseTwo = true
                                phaseThree = false
                                phoneOffsetY = -240
                            }
                            
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.15)) {
                                moveOne = false
                                moveTwo = false
                            }
                        }
                    
                    Circle()
                        .frame(square: 8)
                        .foregroundStyle(!phaseThree ? Color.secondary.opacity(0.5) : .primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .foregroundStyle(.thinMaterial)
                }
                
                Button {
                    action()
                } label: {
                    Circle()
                        .frame(square: 64)
                        .foregroundStyle(Color.primaryBlue)
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
                                .foregroundStyle(Color.primaryBlue)
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
                .padding(.horizontal)
                
            }
            .padding()
        }
        .overlay {
            Color.black.opacity(isLoading ? 0.8 : 0.0)
                .ignoresSafeArea()
        }
        .overlay {
//            if isLoading {
//                LoadingState()
//                    .transition(.scale(scale: 0.9).combined(with: .opacity))
//            }
        }
        .navigationDestination(isPresented: $nextPage) {
            
        }
        
    }
    
    private func action() {
        if phaseThree {

            withAnimation(.smooth(duration: 0.35)) {
                isLoading = true
            }
            
            Task {
                try? await lnManager.requestAuth()
                
                withAnimation(.smooth(duration: 0.35)) {
                    isLoading = false
                }

//                            withAnimation(.smooth(duration: 0.35)) {
//                                nextPage = true
//                            }
                
                vm.goToNextStep(step: 19)
            }
        } else {

            if !phaseTwo {

                withAnimation(.smooth(duration: 0.4, extraBounce: 0.15)) {
                    phaseTwo = true
                    phoneOffsetY = -240
                }
            } else {

                withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
                    phaseThree = true
                    phoneOffsetY = -16
                }
                
                SleepTask.sleep(seconds: 0.15) {
                    withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                        moveOne = true
                    }
                }
                
                SleepTask.sleep(seconds: 0.25) {
                    withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                        moveTwo = true
                    }
                }
                
            }
        }
    }
    
    private var phone: some View {
        Image("iphone-shape")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .shadow(color: .primary.opacity(0.6), radius: 4)
            .background {
                // Inner Background Color
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(LinearGradient(
                        colors: phaseThree ? [Color.primaryBlue] : phaseTwo ? [Color.primaryBlue, .indigo] : [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    )
                    .opacity(colorScheme == .light ? 0.05 : 0.1)
                    .shadow(color: .primary.opacity(0.6), radius: 4)
                // End Inner Background Color
                
                // Background Shadow
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .opacity(0.85)
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .opacity(colorScheme == .light ? 0.1 : 0.35)
                            .blur(radius: 56)
                            .foregroundStyle(LinearGradient(
                                colors: phaseThree ? [Color.primaryBlue] : phaseTwo ? [Color.primaryBlue, .indigo] : [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                            )
                    }
                // End Background Shadow
                
            }
            .overlay {
                // iPhone Content
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        
                        Image("logo-256w")
                            .resizable()
                            .scaledToFit()
                            .frame(square: screenWidth * 0.28)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 6)
                        
                        Text("TikTok is shielded by BLOCKR")
                            .font(.system(size: 26).weight(.bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("This would be your 6th open")
                        .font(.system(size: 12, weight: .regular))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(3.0)
                        .opacity(0.8)
                }
                .offset(y: phaseThree ? 0 : -74)
                .opacity(phaseTwo ? 0.65 : 1.0)
                .scaleEffect(phaseThree ? 0.8 : 1.0)
                .blur(radius: phaseThree ? 44 : 0.0)
                // End iPhone Content
            }
            .overlay(alignment: .top) {
                VStack {
                    VStack(spacing: 0) {
                        Text(formattedDate)
                            .font(.title3.weight(.semibold))
                        
                        Text(formattedTime)
                            .font(.system(size: screenWidth * 0.19, weight: .medium))
                    }
                    .opacity(0.7)
                }
                .rotation3DEffect(.degrees(phaseThree ? 0 : 25),
                                  axis: (1.0, 0.0, 0.0), anchor: .top)
                .scaleEffect(phaseThree ? 1.0 : 0.5)
                .opacity(phaseThree ? 1 : 0)
                .offset(y: phaseThree ? 80 : 0)
            }
            .overlay(alignment: .bottom) {
                // iPhone Content
                ZStack {
                    if colorScheme == .light {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 36,
                            bottomTrailingRadius: 36,
                            topTrailingRadius: 24
                        )
                        .foregroundStyle(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                    } else {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 36,
                            bottomTrailingRadius: 36,
                            topTrailingRadius: 24
                        )
                        .foregroundStyle(.thinMaterial)
                    }
                }
                .frame(
                    height: phaseTwo ? (phaseThree ? 100 : (phaseTwoHalf ? 300 : 200)) : 100
                )
                .overlay {
                    VStack(spacing: 24) {
                        VStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Introducing")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                
                                Text("Limited Unlock")
                                    .font(.title2.weight(.bold))
                                    .fontDesign(.rounded)
                            }
                            
                            HStack(spacing: 0) {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                
                                HStack(alignment: .lastTextBaseline, spacing: 6) {
                                    Text("5")
                                        .font(.system(size: 44, weight: .semibold))
                                    
                                    Text("min")
                                        .font(.system(size: 24, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                
                                Image(systemName: "plus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 32)
                            
                        }
                        
                    }
//                    .offset(y: phaseTwoHalf ? 0 : 38)
                    .padding(.top, 22)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .opacity(phaseThree ? 0 : 1)
                    .scaleEffect(phaseThree ? 0.8 : 1.0)
                    .animation(.snappy(duration: 0.15), value: phaseThree)
                }
                .padding()
                .opacity(phaseTwo ? 1 : 0)
                .scaleEffect(phaseTwo ? 1.0 : 0.8)
                .padding(2)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15).delay(0.05), value: phaseTwo)
                // End iPhone Content
            }
            .overlay {
                ZStack {
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(square: 64)
                        .scaleEffect(phaseThree ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(x: 28, y: 40)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 6, y: 3)
                        .opacity(phaseThree ? 0.0 : 1.0)
                    
                    Image("unstress")
                        .resizable()
                        .scaledToFit()
                        .frame(square: 88)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 4, y: 4)
                        .scaleEffect(phaseThree ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(x: 8, y: -32)
                        .opacity(phaseThree ? 0.0 : 1.0)
                    
                    Image("relief1")
                        .resizable()
                        .scaledToFit()
                        .frame(square: 88)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 4, y: 4)
                        .scaleEffect(!phaseThree ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(x: 8, y: -32)
                        .opacity(!phaseThree ? 0.0 : 1.0)
                    
                    Image("hourglass")
                        .resizable()
                        .scaledToFit()
                        .frame(square: 80)
                        .scaleEffect(phaseThree ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -36, y: -140)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 4, y: 3)
                        .opacity(phaseThree ? 0.0 : 1.0)
                    
                    Image("bell")
                        .resizable()
                        .scaledToFit()
                        .frame(square: 80)
                        .scaleEffect(!phaseThree ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -36, y: -160)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 4, y: 3)
                        .opacity(!phaseThree ? 0.0 : 1.0)
                    
                }
            }
            .padding(.horizontal, 40)

    }
        
    @ViewBuilder
    private func Notification(title: String, description: String, time: String, timeSensitive: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, y: -0.5)
            .frame(height: 60)
            .overlay {
                HStack(spacing: 12) {
                    Image(AppConfiguration.appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        if timeSensitive {
                            Text("Time sensitive".uppercased())
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                            
                            Spacer()
                            
                            Text(time)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        
                        if !timeSensitive {
                            Text(description)
                                .font(.system(size: 14))
                                .opacity(0.8)
                        }
                    }
                    .opacity(0.8)
                }
                .padding()
            }
            .padding(.horizontal, 28)
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter.string(from: .now)
    }
    
    private var formattedTime: String {
        let currentTime = Date()
        let formattedDate = currentTime.formatted(date: .omitted, time: .shortened)
        let dateFormatter = DateFormatter()
        
        if formattedDate.contains("M") {
            dateFormatter.dateFormat = "h:mm"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        return dateFormatter.string(from: currentTime)
    }
    
}

extension View {
    @ViewBuilder
    func digitKeyframe(delay: Double) -> some View {
        
        self.keyframeAnimator(initialValue: DigitKeyframe(), repeating: true) { view, frame in
            view
                .offset(y: -frame.scaleIncrement * 15)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0.0, y: 4.0)
                .scaleEffect(1.0 + frame.scaleIncrement)
                .brightness(frame.scaleIncrement)
        } keyframes: { frame in
            KeyframeTrack(\.scaleIncrement) {
                CubicKeyframe(0.0, duration: delay)
                CubicKeyframe(0.1, duration: 0.3)
                CubicKeyframe(0.0, duration: 0.5)
                CubicKeyframe(0.0, duration: 0.6 - delay)
            }
        }
        
    }
}

struct DigitKeyframe {
    var scaleIncrement: CGFloat = .zero
    var brightness: Double = 0.0
}

#Preview {
    OBSliderView()
        .environmentObject(OBUserViewModel())
        .environmentObject(LocalNotificationManager())
}

