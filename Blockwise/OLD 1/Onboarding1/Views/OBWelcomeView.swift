//
//  OBWelcomeView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/05/25.
//

import SwiftUI
import Lottie

#Preview(body: {
    OBWelcomeView2()
})

struct OBWelcomeView2: View {
    @State private var appearAnimation: Bool = false
        
    private let logoSize: CGFloat = 56
    private let dockHeight: CGFloat = 76
    
    @State private var showQuiz: Bool = false
    
    var body: some View {
        ZStack {
            if showQuiz {
                OBQuizView()
                    .transition(.move(edge: .trailing).combined(with: .offset(x: 32)))
            } else {
                VStack(spacing: 32) {

                    VStack(spacing: 14) {
                        
                        Text("Welcome to \(AppConfiguration.name)")
                            .multilineTextAlignment(.center)
                        //                .font(.system(size: 30).weight(.bold))
                            .font(.grotesk(size: 28, weight: .semibold))
                            .offset(y: appearAnimation ? 0 : 32)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.smooth(duration: 0.25).delay(0.05), value: appearAnimation)
                            .lineSpacing(2.0)
                        
                        Text("Let's see if you have a problem with your phone in the first place.")
                            .multilineTextAlignment(.center)
                        //                .font(.title3.weight(.medium))
                            .font(.grotesk(.title3, weight: .medium))
                            .opacity(0.65)
                            .lineSpacing(4.0)
                            .offset(y: appearAnimation ? 0 : 32)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.smooth(duration: 0.35).delay(0.25), value: appearAnimation)
                    }
                    
                    Space(height: 4)
                    
                    HStack(spacing: 10) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 72))
                            .foregroundStyle(.yellow)
                        
                        Text("Science based approach")
                            .font(.grotesk(.title2, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 8)
                        
                        Image(systemName: "laurel.trailing")
                            .font(.system(size: 72))
                            .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.40), value: appearAnimation)

                    HStack(spacing: 10) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 72))
                            .foregroundStyle(.yellow)
                        
                        Text("96% satisfaction score")
                            .font(.grotesk(.title2, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 8)
                        
                        Image(systemName: "laurel.trailing")
                            .font(.system(size: 72))
                            .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.55), value: appearAnimation)
                    
                    Space(height: 12)
                                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 22) {
                        
//                        Button {
//                            action()
//                        } label: {
//                            Circle()
//                                .frame(square: 64)
//                                .foregroundStyle(Color.accentBlue)
//                                .overlay {
//                                    Image(systemName: "arrow.right")
//                                        .foregroundStyle(.white)
//                                        .font(.system(size: 24.0).weight(.semibold))
//                                }
//                        }
//                        .phaseAnimator([false, true]) { view, phase in
//                            view
//                                .background {
//                                    Circle()
//                                        .frame(width: 64, height: 64)
//                                        .foregroundStyle(Color.accentBlue)
//                                        .scaleEffect(phase ? 1.8 : 1.0)
//                                        .opacity(phase ? 0.0 : 0.6)
//                                }
//                        } animation: { phase in
//                            if phase {
//                                .easeInOut(duration: 1.0)
//                            } else {
//                                nil
//                            }
//                        }
//                        .offset(y: appearAnimation ? 0 : 32)
//                        .opacity(appearAnimation ? 1 : 0)
//                        .animation(.smooth(duration: 0.35).delay(0.65), value: appearAnimation)
//                        .padding(.vertical)

                        GlassButton {
                            action()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Start Quiz")
        //                            .font(.system(size: 18.0).weight(.semibold))
                                    .font(.grotesk(size: 20, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.footnote)
                            
                            Text("Takes about 30 seconds")
                                .font(.grotesk(.footnote, weight: .regular))
                        }
                        .padding(.horizontal, 32)
                        .padding(.horizontal)
                        .opacity(0.65)
                        .lineSpacing(4.0)
                    }
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.65), value: appearAnimation)
                }
                .padding(.vertical)
                .padding(.horizontal, 32)
        //        .overlay {
        //            if showQuiz {
        //                OBQuizView()
//                            .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
        //            }
        //        }
                .background(alignment: .top) {
                    LottieView(animation: .named("confetti-animation"))
                        .playing(loopMode: .playOnce)
                        .frame(height: 400)
                        .offset(y: -144)
                }
                .onAppear(perform: setup)
                .transition(.move(edge: .leading).combined(with: .offset(x: -32)))

            }
        }
    }
    
    private func setup() {
        appearAnimation = true
    }
    
    private func action() {
        withAnimation(.smooth(duration: 0.45)) {
            showQuiz = true
        }
    }

}


struct OBWelcomeView: View {
    @State private var appearAnimation: Bool = false
        
    private let logoSize: CGFloat = 56
    private let dockHeight: CGFloat = 76
    
    @State private var showQuiz: Bool = false
    
    var body: some View {
        ZStack {
            if showQuiz {
                OBQuizView()
                    .transition(.move(edge: .trailing).combined(with: .offset(x: 32)))
            } else {
                VStack(spacing: 32) {

                    LottieView(animation: .named("wave"))
                        .looping()
                        .frame(square: 100)
                        .offset(y: appearAnimation ? 0 : 32)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.smooth(duration: 0.35).delay(0.15), value: appearAnimation)

                    Text("Welcome to \(AppConfiguration.name)")
                        .multilineTextAlignment(.center)
        //                .font(.system(size: 30).weight(.bold))
                        .font(.grotesk(size: 30, weight: .semibold))
                        .offset(y: appearAnimation ? 0 : 32)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.smooth(duration: 0.25), value: appearAnimation)
                        .lineSpacing(2.0)
                                
                    Text("Let's see if you have a problem with your phone in the first place.")
                        .multilineTextAlignment(.center)
        //                .font(.title3.weight(.medium))
                        .font(.grotesk(.title3, weight: .medium))
                        .opacity(0.65)
                        .lineSpacing(4.0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.smooth(duration: 0.35).delay(0.35), value: appearAnimation)
                    
                    Space(height: 12)
                    
                    Button {
                        action()
                    } label: {
                        Circle()
                            .frame(square: 64)
                            .foregroundStyle(Color.accentBlue)
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
                                    .foregroundStyle(Color.accentBlue)
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
                    .animation(.smooth(duration: 0.35).delay(0.55), value: appearAnimation)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 22) {
                        
        //                Button {
        //                    action()
        //                } label: {
        //                    Circle()
        //                        .frame(square: 64)
        //                        .foregroundStyle(Color.accentBlue)
        //                        .overlay {
        //                            Image(systemName: "arrow.right")
        //                                .foregroundStyle(.white)
        //                                .font(.system(size: 24.0).weight(.semibold))
        //                        }
        //                }
        //                .phaseAnimator([false, true]) { view, phase in
        //                    view
        //                        .background {
        //                            Circle()
        //                                .frame(width: 64, height: 64)
        //                                .foregroundStyle(Color.pink)
        //                                .scaleEffect(phase ? 1.8 : 1.0)
        //                                .opacity(phase ? 0.0 : 0.6)
        //                        }
        //                } animation: { phase in
        //                    if phase {
        //                        .easeInOut(duration: 1.0)
        //                    } else {
        //                        nil
        //                    }
        //                }

        //                GlassButton("Start Quiz") {
        //                    vm.goToNextStep(step: 1)
        //                }
        //                .foregroundStyle(Color.accentBlue)
                        
        //                Text("Takes around 1 minute")
        //                    .multilineTextAlignment(.center)
        //                    .font(.grotesk(.footnote, weight: .regular))
        //                    .padding(.horizontal, 32)
        //                    .padding(.horizontal)
        //                    .opacity(0.8)
        //                    .lineSpacing(4.0)
                    }
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
                }
                .padding(.vertical)
                .padding(.horizontal, 32)
        //        .overlay {
        //            if showQuiz {
        //                OBQuizView()
//                            .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
        //            }
        //        }
                .onAppear(perform: setup)
                .transition(.move(edge: .leading).combined(with: .offset(x: -32)))

            }
        }
    }
    
    private func setup() {
        appearAnimation = true
    }
    
    private func action() {
        withAnimation(.smooth(duration: 0.45)) {
            showQuiz = true
        }
    }

}

#Preview {
    OBWelcome()
        .environmentObject(OBUserViewModel())
}

struct OBWelcome: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var showTermsSheet: Bool = false
    @State private var showPrivacySheet: Bool = false
    
    let color = Color.primaryBlue
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var phoneOffsetY: CGFloat = -350
    
    @State private var startPosition: CGRect = .zero {
        didSet {
            calculateOffsetIfReady()
        }
    }
    @State private var endPosition: CGRect = .zero {
        didSet {
            calculateOffsetIfReady()
        }
    }
    
    @State private var logoOffsetY: CGFloat = .zero
    @State private var logoOffsetX: CGFloat = .zero
    
    @State private var startAnimation: Bool = false
    
    @State private var secondPhase: Bool = false
    @State private var hideStars: Bool = false
    @State private var thirdPhase: Bool = false
    
    @State private var appearAnimation: Bool = false
    @State private var showScrollingContent: Bool = false
    @State private var showScrollingContent2: Bool = false
    
    private let logoSize: CGFloat = 56
    private let phoneHPadding: CGFloat = 32
    private let phoneCornerRadius: CGFloat = 56
    private let phoneDockCornerRadius: CGFloat = 30
    private let phoneLineWidth: CGFloat = 7.0
    private let dockHeight: CGFloat = 76

    
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        VStack {
            phone
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(y: phoneOffsetY)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .overlay(alignment: .bottom) {
            VStack(spacing: 36) {
                
                Image(AppConfiguration.appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(square: dockHeight * 0.55)
                    .clipShape(.rect(cornerRadius: logoSize / 4.4, style: .continuous))
                    .scaleEffect(startAnimation ? 1.0 : 1.35)
                    .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
                    .background {
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                startPosition = geo.frame(in: .global)
                                Logger.debug("Start Position: \(startPosition)")
                            }
                        }
                    }
                    .appIconKeyframeAnimation(
                        trigger: startAnimation,
                        offsetX: logoOffsetX,
                        offsetY: logoOffsetY
                    )

                Group {
                    Text("A Science-Backed Journey to ") +
                    Text("Quit Phone Addiction.").foregroundStyle(color)
                }
                .font(.system(size: 30).weight(.semibold))
                .multilineTextAlignment(.center)
                .fontDesign(.default)
                .lineSpacing(4.0)

                VStack(spacing: 22) {
                    GlassButton("Start your Journey") {
                        action()
                    }
                    
                    Text("By continuing, you accept our \(termsLink) and \(privacyLink)")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .padding(.horizontal)
                        .tint(color)
                        .opacity(0.8)
                        .lineSpacing(4.0)
                }

            }
            .padding()
            .padding(.horizontal, 32)
        }
        .mainKeyframeAnimation(startAnimation, y: phoneOffsetY)
        .iphoneShapeKeyframeAnimation(startAnimation)
        .opacity(secondPhase ? 0.0 : 1.0)
        .animation(.smooth(duration: 0.6), value: secondPhase)
        .overlay {
//            if thirdPhase {
//                OBWelcomeView()
//                    .transition(.scale(scale: 0.8).combined(with: .opacity))
//            }
        }
        .sheet(isPresented: $showTermsSheet) {
            Text("Terms of Service")
        }
        .sheet(isPresented: $showPrivacySheet) {
            Text("Privacy Policy")
        }
        .onAppear(perform: setup)
    }
    
    private func calculateOffsetIfReady() {
        // Check if both positions have been set (not zero)
        if startPosition != .zero && endPosition != .zero {
            logoOffsetX = endPosition.origin.x - startPosition.origin.x
            logoOffsetY = endPosition.origin.y - startPosition.origin.y
            Logger.debug("Calculated offset: x=\(logoOffsetX), y=\(logoOffsetY)")
        }
    }
    
    @ViewBuilder
    private var privacyLink: Text {
        Text("**[Privacy Policy](\(AppConfiguration.privacyURL))**")
    }

    @ViewBuilder
    private var termsLink: Text {
        Text("**[Terms of Service](\(AppConfiguration.termsURL))**")
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.25) {
            withAnimation(.smooth) {
                appearAnimation = true
                showScrollingContent = true
            }
        }
        
        SleepTask.sleep(seconds: 0.35) {
            showScrollingContent2 = true
        }
    }
    
    private func action() {
        withAnimation {
            startAnimation = true
        }
        
        SleepTask.sleep(seconds: 1.1) {
            withAnimation(.smooth(duration: 0.5)) {
                hideStars = true
            }
            
            Haptics.successFeedback()
        }
        
        SleepTask.sleep(seconds: 1.6) {
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.15)) {
                secondPhase = true
            }
        }
        
        SleepTask.sleep(seconds: 1.8) {
            withAnimation(.smooth(duration: 0.25)) {
                thirdPhase = true
            }
        }
    }
    
    private var phone: some View {
        Image("iphone-shape")
            .resizable()
            .scaledToFit()
            .shadow(color: .primary.opacity(0.6), radius: 4)
            .background {
                // Inner Background Color
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(LinearGradient(
                        colors: appearAnimation ? [Color.primaryBlue] : [.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    )
                    .opacity(colorScheme == .dark ? 0.1 : 0.08)
                    .shadow(color: .primary.opacity(0.2), radius: 4)
                // End Inner Background Color
                
                // Background Shadow
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .opacity(secondPhase ? 0.75 : 0.85)
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundStyle(LinearGradient(
                                colors: hideStars ? [Color.primaryBlue] : [.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                            )
                            .opacity(hideStars ? 0.75 : 0.25)
                            .blur(radius: 144)
                    }
                // End Background Shadow
                
            }
            .overlay {
                // iPhone Content
                
                // Scrolling Content
                if !startAnimation {
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(.secondary.opacity(0.1))
                            .frame(height: 150)
                        
                        RoundedRectangle(cornerRadius: 28)
                            .foregroundStyle(.secondary.opacity(0.1))
                            .frame(width: 140, height: 10)
                        
                        RoundedRectangle(cornerRadius: 28)
                            .foregroundStyle(.secondary.opacity(0.1))
                            .frame(width: 200, height: 10)
                    }
                    .padding(32)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 100)
                    .transition(.asymmetric(
                        insertion: AnyTransition.scale(scale: 0.8).combined(with: .offset(y: 32).combined(with: .opacity)),
                        removal: AnyTransition.scale(scale: 0.8).combined(with: .offset(y: -32).combined(with: .opacity)))
                    )
//                    .scrollContentKeyframe()
                }
                // End Scrolling Content
                
                // Bottom Dock
                RoundedRectangle(cornerRadius: 28)
                    .foregroundStyle(.secondary.opacity(0.1))
                    .frame(height: 64)
                    .shadow(color: .black.opacity(0.2), radius: 6)
                    .padding(22)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .frame(width: 44, height: 44)
                                .opacity(0.1)
                                .offset(x: 28.0)
                                .iconKeyframeAnimation(startAnimation, edge: .leading)
                            
                            RoundedRectangle(cornerRadius: 14)
                                .frame(width: 44, height: 44)
                                .opacity(0.1)
                                .offset(x: -28.0)
                                .iconKeyframeAnimation(startAnimation, edge: .trailing)
                        }
                        .background {
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    endPosition = geo.frame(in: .global)
                                    Logger.debug("End Position: \(endPosition)")
                                }
                            }
                        }
                        .frame(height: 64)
                    }
                    .padding(.bottom, 4)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .dockKeyframeAnimation(startAnimation)
                // End Bottom Dock
                
                // End iPhone Content
            }
            .padding(.horizontal, 40)
    }

}

extension View {
    func mainKeyframeAnimation(_ trigger: Bool, y offsetY: CGFloat) -> some View {
        self.keyframeAnimator(initialValue: ContentKeyframe(), trigger: trigger) { view, frame in
            view
                .scaleEffect(frame.scale)
                .offset(y: frame.offsetY)
        } keyframes: { frame in
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(-20, duration: 0.15)
                CubicKeyframe(.zero, duration: 0.20)
                SpringKeyframe(-offsetY, spring: .smooth(duration: 0.45, extraBounce: 0.15))
            }
            
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.0, duration: 0.35)
                SpringKeyframe(1.1, spring: .smooth(duration: 0.5, extraBounce: 0.15))
                CubicKeyframe(1.08, duration: 0.15)
                SpringKeyframe(1.1, spring: .smooth(duration: 0.6, extraBounce: 0.15))
            }
        }
    }
}

extension View {
    func appLogoKeyframeAnimation(_ trigger: Bool, x offsetX: CGFloat, y offsetY: CGFloat) -> some View {
        self.keyframeAnimator(initialValue: LogoKeyframe(), trigger: trigger) { view, frame in
            view
                .rotation3DEffect(.degrees(frame.rotation3d), axis: (1.0, 0.0, 0.0))
                .scaleEffect(frame.scale)
                .offset(x: frame.offsetX, y: frame.offsetY)
                .brightness(frame.brightness)
        } keyframes: { frame in
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(.zero, duration: 0.25)
                CubicKeyframe(offsetY * 2, duration: 0.55)
                CubicKeyframe(offsetY, duration: 0.5)
            }
            
            KeyframeTrack(\.offsetX) {
                CubicKeyframe(.zero, duration: 0.25)
                CubicKeyframe(offsetX, duration: 1.05)
            }
            
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.0, duration: 0.1)
                CubicKeyframe(0.95, duration: 0.15)
                CubicKeyframe(3, duration: 0.45)
                
                CubicKeyframe(1.0, duration: 0.6)
                CubicKeyframe(0.9, duration: 0.15)
                CubicKeyframe(1.0, duration: 0.15)
            }
            
            KeyframeTrack(\.rotation3d) {
                CubicKeyframe(.zero, duration: 0.35)
                CubicKeyframe(360, duration: 0.95)
            }
            
            KeyframeTrack(\.brightness) {
                CubicKeyframe(.zero, duration: 0.55)
                CubicKeyframe(0.6, duration: 0.15)
                CubicKeyframe(.zero, duration: 0.35)
            }
            
            KeyframeTrack(\.shadowRadius) {
                CubicKeyframe(2.0, duration: 0.45)
                CubicKeyframe(14.0, duration: 0.15)
                CubicKeyframe(2.0, duration: 0.35)
            }
        }
    }
}

extension View {
//    func scrollContentKeyframe() -> some View {
//        self.keyframeAnimator(initialValue: ScrollContentKeyframe(), repeating: true) { view, frame in
//            view
//                .opacity(frame.opacity1)
//                .rotation3DEffect(
//                    .degrees(frame.degrees1), axis: (x: 1.0, y: 0.0, z: 0.0)
//                )
//                .scaleEffect(frame.scale1)
//                .offset(y: frame.offsetY1)
//                .overlay {
//                    Image(systemName: "hand.point.up.left.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(square: 44)
//                        .rotationEffect(.degrees(frame.degrees2))
//                        .offset(x: 80, y: frame.offsetY2)
//                        .offset(y: 64)
//                        .foregroundStyle(.secondary.opacity(0.45))
//                    
//                }
//        } keyframes: { frame in
//            KeyframeTrack(\.offsetY1) {
//                CubicKeyframe(0, duration: 0.25)
//                CubicKeyframe(-100, duration: 0.35)
//                CubicKeyframe(64, duration: 0.05)
//                CubicKeyframe(0, duration: 0.7)
//            }
//            
//            KeyframeTrack(\.opacity1) {
//                CubicKeyframe(1.0, duration: 0.25)
//                CubicKeyframe(0.0, duration: 0.35)
//                CubicKeyframe(0.0, duration: 0.4)
//                CubicKeyframe(1.0, duration: 0.65)
//            }
//            
//            KeyframeTrack(\.scale1) {
//                CubicKeyframe(1.0, duration: 0.25)
//                CubicKeyframe(0.95, duration: 0.35)
//                CubicKeyframe(0.95, duration: 0.35)
//                CubicKeyframe(1.0, duration: 0.65)
//            }
//            
//            KeyframeTrack(\.degrees1) {
//                CubicKeyframe(0.0, duration: 0.25)
//                CubicKeyframe(15, duration: 0.35)
//                CubicKeyframe(0.0, duration: 0.05)
//                CubicKeyframe(0.0, duration: 0.65)
//            }
//            
//            KeyframeTrack(\.offsetY2) {
//                CubicKeyframe(64, duration: 0.15)
//                CubicKeyframe(32, duration: 0.25)
//                SpringKeyframe(64, spring: .smooth(duration: 0.6, extraBounce: 0.25))
//            }
//            
//            KeyframeTrack(\.degrees2) {
//                CubicKeyframe(0.0, duration: 0.15)
//                CubicKeyframe(10, duration: 0.25)
//                CubicKeyframe(0.0, duration: 0.4)
//            }
//            
//            KeyframeTrack(\.rectHeight) {
//                CubicKeyframe(0, duration: 0.15)
//                CubicKeyframe(64, duration: 0.25)
//                CubicKeyframe(0, duration: 0.15)
//            }
//        }
//    }
}

extension View {
    func iphoneShapeKeyframeAnimation(_ trigger: Bool) -> some View {
        self.keyframeAnimator(initialValue: PhoneKeyframe(), trigger: trigger) { view, frame in
            view
                .scaleEffect(frame.scale)
                .offset(y: frame.offsetY)
                .rotation3DEffect(.degrees(frame.rotationAngle), axis: (1.0, 0.0, 0.0))
        } keyframes: { frame in
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(.zero, duration: 0.1)
                CubicKeyframe(.zero, duration: 1.5)
                CubicKeyframe(50, duration: 0.35)
            }
            
            KeyframeTrack(\.rotationAngle) {
                CubicKeyframe(.zero, duration: 1.2)
                CubicKeyframe(4, duration: 0.55)
                CubicKeyframe(.zero, duration: 0.25)
            }
            
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.0, duration: 1.65)
                SpringKeyframe(2.0, spring: .smooth(duration: 0.6, extraBounce: 0.15))
            }
        }
    }
}

extension View {
    @ViewBuilder
    func iconKeyframeAnimation(_ trigger: Bool, edge: HorizontalEdge) -> some View {
        let isLeading = edge == .leading
        
        self.keyframeAnimator(initialValue: EdgeIconKeyframe(), trigger: trigger) { view, frame in
            view
                .rotationEffect(.degrees(frame.rotation))
                .offset(x: frame.offsetX)
                .rotation3DEffect(.degrees(frame.rotationEffect), axis: (0.0, isLeading ? 1.0 : -1.0, 0.0))
        } keyframes: { frame in
            KeyframeTrack(\.rotationEffect) {
                CubicKeyframe(.zero, duration: 1.15)
                CubicKeyframe(2, duration: 0.3)
                CubicKeyframe(.zero, duration: 0.5)
            }
            
            KeyframeTrack(\.offsetX) {
                CubicKeyframe(.zero, duration: 0.8)
                CubicKeyframe(isLeading ? 28.0 : -28.0, duration: 0.4)
            }
            
            KeyframeTrack(\.rotation) {
                CubicKeyframe(.zero, duration: 0.4)
                CubicKeyframe(isLeading ? 6 : -6, duration: 0.4)
                CubicKeyframe(.zero, duration: 0.2)
            }
        }
    }
}

extension View {
    func dockKeyframeAnimation(_ trigger: Bool) -> some View {
        self.keyframeAnimator(initialValue: DockKeyframe(), trigger: trigger) { view, frame in
            view
                .scaleEffect(frame.scale)
                .offset(y: frame.offsetY)
        } keyframes: { frame in
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.0, duration: 1.15)
                CubicKeyframe(0.96, duration: 0.3)
                CubicKeyframe(1.0, duration: 0.5)
            }
            
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(.zero, duration: 1.15)
                CubicKeyframe(8, duration: 0.3)
                CubicKeyframe(.zero, duration: 0.5)
            }
        }
    }
}

struct ScrollContentKeyframe {
    var opacity1: Double = 1.0
    var offsetY1: CGFloat = .zero
    var scale1: CGFloat = 1.0
    var degrees1: Double = .zero
    
    var opacity2: Double = 1.0
    var offsetY2: CGFloat = 64
    var scale2: CGFloat = 0.95
    var degrees2: Double = .zero
    
    var rectHeight: CGFloat = .zero
}

struct DockKeyframe {
    var scale: CGFloat = 1.0
    var offsetY: CGFloat = .zero
}

struct LogoKeyframe {
    var offsetY: CGFloat = .zero
    var offsetX: CGFloat = .zero
    var scale: CGFloat = 1.0
    var rotation3d: CGFloat = .zero
    var brightness: Double = .zero
    var shadowRadius: CGFloat = 2
}

struct PhoneKeyframe {
    var scale: CGFloat = 1.0
    var offsetY: CGFloat = .zero
    var rotationAngle: Double = .zero
}

struct ContentKeyframe {
    var scale: CGFloat = 1.0
    var offsetY: CGFloat = .zero
}

struct EdgeIconKeyframe {
    var scale: CGFloat = 1.0
    var rotationEffect: CGFloat = .zero
    var offsetX: CGFloat = .zero
    var rotation: CGFloat = .zero
}

/// A view modifier that applies a shimmering effect to the content.
///
/// This modifier adds a shimmering appearance to the content by overlaying a moving gradient. It is designed to be used to give a visual highlight or loading indication to the view.
private struct ShimmeringEffectViewModifier: ViewModifier {
    
    /// The height of the shimmering view.
    let height: CGFloat
    
    /// A state property to control the movement of the gradient.
    @State private var moveGradient: Bool = false
    
    /// The delay before the shimmering effect starts.
    let delay: TimeInterval
    
    /// Modifies the content view by applying a shimmering effect.
    ///
    /// - Parameter content: The original content view.
    /// - Returns: A view with the shimmering effect applied.
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.1),
                            .white.opacity(0.2),
                            .white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 200)
                    .offset(
                        x: moveGradient ? geo.size.width / 1.2 : -geo.size.width / 1.2
                    )
                    .allowsHitTesting(false)
                }
                .animation(
                    .smooth(duration: 1.8)
                    .repeatForever(autoreverses: false),
                    value: moveGradient
                )
                .mask { content }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.1 + delay)) {
                        moveGradient = true
                    }
                }
                .onDisappear {
                    moveGradient = false
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: height)
    }
}

// Convenience extension
extension View {
    /// Applies a shimmering effect to the view.
    ///
    /// This method applies a `ShimmeringEffectViewModifier` to the view, giving it a shimmering appearance with the specified height.
    ///
    /// - Parameters:
    ///   - height: The height of the shimmering view.
    ///   - delay: The delay before the shimmering effect starts. The default value is 0.
    /// - Returns: A view with the shimmering effect applied.
    ///
    /// # Example
    /// ```
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("Loading...")
    ///             .shimmeringEffect(height: 50)
    ///             .padding()
    ///     }
    /// }
    /// ```
    func shimmeringEffect(height: CGFloat, delay: TimeInterval = .zero) -> some View {
        self.modifier(ShimmeringEffectViewModifier(height: height, delay: delay))
    }
}
