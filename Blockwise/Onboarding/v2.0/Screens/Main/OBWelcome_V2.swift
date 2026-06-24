//
//  OBWelcome_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/01/26.
//

import SwiftUI

struct OBWelcome_V2: View {
    // MARK: - Environment
    @Environment(\.openURL) var openURL
    @EnvironmentObject var vm: OBVM_V2
    @EnvironmentObject var toastManager: ToastManager
    
    // MARK: - Animation State
    @State private var appearAnimation: Bool = false
    @State private var startAnimation: Bool = false
    @State private var endAnimation: Bool = false
    
    // MARK: - Position State
    @State private var startPosition: CGRect = .zero {
        didSet { calculateOffsetIfReady() }
    }
    @State private var endPosition: CGRect = .zero {
        didSet { calculateOffsetIfReady() }
    }
    @State private var logoOffsetX: CGFloat = .zero
    @State private var logoOffsetY: CGFloat = .zero
    
    // MARK: - Constants
    private let logoSize: CGFloat = 56
    private let phoneHPadding: CGFloat = 32
    private let phoneCornerRadius: CGFloat = 56
    private let phoneDockCornerRadius: CGFloat = 30
    private let dockHeight: CGFloat = 76
    private let appIcon: String = AppConfiguration.appIcon
    
    let geometryReaderDelay: TimeInterval = 0.4
    
    @State private var isButtonActive: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            
            VStack(spacing: 0) {
                phonePreview(height: height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                BottomContent(geo: geo)
            }
            .mainKeyframeAnimation(trigger: startAnimation, offsetY: height * 0.5)
            .iphoneShapeKeyframeAnimation(startAnimation)
            .overlay {
                topGradientOverlay
            }
            .overlay {
                completionOverlay
            }
        }
        .coordinateSpace(name: "root")
        .onAppear(perform: setup)
        .environmentObject(vm)
    }
    
    // MARK: - Phone Preview
    @ViewBuilder
    private func phonePreview(height: CGFloat) -> some View {
        Image(.iphoneShape)
            .resizable()
            .scaledToFit()
            .brightness(0.8)
            .overlay(alignment: .bottom) {
                phoneDock
            }
            .offset(y: -height * 0.5)
            .padding(.horizontal, phoneHPadding)
            .opacity(endAnimation ? 0 : 1)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : -32)
            .scaleEffect(appearAnimation ? 1 : 1.05)
            .animation(.smooth, value: appearAnimation)
    }
    
    // MARK: - Phone Dock
    @ViewBuilder
    private var phoneDock: some View {
        let appIconSize: CGFloat = dockHeight * 0.65
        
        RoundedRectangle(cornerRadius: phoneDockCornerRadius, style: .continuous)
            .foregroundStyle(.secondary.opacity(0.15))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .overlay {
                dockIcons(appIconSize: appIconSize)
            }
            .frame(height: dockHeight)
            .padding(28)
    }
    
    @ViewBuilder
    private func dockIcons(appIconSize: CGFloat) -> some View {
        ZStack {
            // Leading icon placeholder
            RoundedRectangle(cornerRadius: appIconSize / 3.8)
                .frame(square: appIconSize)
                .foregroundStyle(Color.secondary.opacity(0.3))
                .brightness(0.1)
                .offset(x: -appIconSize * 0.65)
                .iconKeyframeAnimation(startAnimation, edge: .trailing)
            
            // Trailing icon placeholder
            RoundedRectangle(cornerRadius: appIconSize / 3.8)
                .frame(square: appIconSize)
                .foregroundStyle(Color.secondary.opacity(0.3))
                .brightness(0.1)
                .offset(x: appIconSize * 0.65)
                .iconKeyframeAnimation(startAnimation, edge: .leading)
        }
        .frame(square: appIconSize)
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + geometryReaderDelay) {
                            endPosition = geo.frame(in: .named("root"))
//                            Logger.debug("End Position: \(endPosition)")
                        }
                    }
            }
        }
    }
    
    // MARK: - Bottom Content
    @ViewBuilder
    private func BottomContent(geo: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            headerSection
            actionSection
        }
        .padding()
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 38) {
            appIconView
            titleText
        }
    }
    
    @ViewBuilder
    private var appIconView: some View {
        Image(appIcon)
            .resizable()
            .scaledToFit()
            .frame(square: dockHeight * 0.65)
            .clipShape(.rect(cornerRadius: logoSize / 4.0, style: .continuous))
            .scaleEffect(startAnimation ? 1.0 : 1.15)
//            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + geometryReaderDelay) {
                                startPosition = geo.frame(in: .named("root"))
//                                Logger.debug("Start Position: \(startPosition)")
                            }
                        }
                }
            }
            .appIconKeyframeAnimation(
                trigger: startAnimation,
                offsetX: logoOffsetX,
                offsetY: logoOffsetY
            )
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
    }
    
    @ViewBuilder
    private var titleText: some View {
//        Group {
//            Text("A smarter way to use your phone.")
//        }
//        .font(.grotesk(size: 30, weight: .semibold))
//        .multilineTextAlignment(.center)
//        .lineSpacing(2.0)
        
        VStack(spacing: 14) {
//            Text("Find peace,\nin a world of noise.")
//                .font(.grotesk(size: 32, weight: .semibold))
            
            Group {
                Text({
                    var result = AttributedString()
                    
//                    result.append(AttributedString("Find "))
                    var highlighted = AttributedString("Find peace,")
                    highlighted.foregroundColor = Color.orange
                    highlighted.backgroundColor = Color.orange.opacity(0.15)
                    result.append(highlighted)
                    
                    result.append(AttributedString("\nin a world of noise."))
                    
                    return result
                }())
            }
            .foregroundStyle(.textC)
            .font(.grotesk(size: 32, weight: .semibold))
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

            Text("Take back your attention in a world built to steal it.")
                .font(.grotesk(.body, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(2.0)
                .padding(.horizontal)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.15), value: appearAnimation)
        }
        .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var actionSection: some View {
        VStack(spacing: 22) {
            startButton
            legalText
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth.delay(0.2), value: appearAnimation)
    }
    
    @ViewBuilder
    private var startButton: some View {
        GlassButton("Get Started") {
            guard isButtonActive else { return }
            action()
        }
    }
    
    @ViewBuilder
    private var legalText: some View {
        VStack(spacing: 5) {
            Text("By continuing, you agree to \(AppConfiguration.name)'s")
                .foregroundStyle(.secondary)
            
            HStack(spacing: 5) {
                Button {
                    openExternalURL(AppConfiguration.termsURL)
                } label: {
                    Text("Terms of Use").fontWeight(.semibold)
                }
                .tint(.primary)
                .opacity(0.6)
                
                Text("&").foregroundStyle(.secondary)
                
                Button {
                    openExternalURL(AppConfiguration.privacyURL)
                } label: {
                    Text("Privacy Policy").fontWeight(.semibold)
                }
                .tint(.primary)
                .opacity(0.6)
            }
        }
        .font(.caption)
        .multilineTextAlignment(.center)
        .font(.grotesk(.footnote, weight: .regular))
    }
    
    // MARK: - Overlays
    @ViewBuilder
    private var topGradientOverlay: some View {
        LinearGradient(
            colors: [
                Theme.backgroundC,
                .clear,
                .clear,
                .clear,
                .clear,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .opacity(startAnimation ? 0 : 1)
    }
    
    @ViewBuilder
    private var completionOverlay: some View {
        if endAnimation {
            OBAccolades_V2()
                .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
    
    // MARK: - Functions
    private func setup() {
        appearAnimation = true
        
        SleepTask.sleep(seconds: geometryReaderDelay) {
            isButtonActive = true
        }
    }
    
    private func action() {
        withAnimation {
            startAnimation = true
        }
        
        SleepTask.sleep(seconds: 1.6) {
            withAnimation(.smooth(duration: 0.35)) {
                endAnimation = true
            }
        }
        
        SleepTask.sleep(seconds: 1.3) {
            Haptics.feedback(style: .rigid)
        }
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Welcome")
    }
    
    private func calculateOffsetIfReady() {
        guard startPosition != .zero && endPosition != .zero else { return }
        
        logoOffsetX = endPosition.origin.x - startPosition.origin.x
        logoOffsetY = endPosition.origin.y - startPosition.origin.y
//        Logger.debug("Calculated offset: x=\(logoOffsetX), y=\(logoOffsetY)")
    }
    
    private func openExternalURL(_ url: URL) {
        openURL(url) { accepted in
            if !accepted {
                toastManager.error("Unable to open link.")
            }
        }
    }
    
    private func openExternalURL(_ string: String) {
        guard let url = URL(string: string) else {
            toastManager.error("Invalid link.")
            return
        }
        openExternalURL(url)
    }
}

struct OBAccolades_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            HStack(spacing: 10) {
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.6).delay(0.2), value: appearAnimation)
                
                VStack(spacing: 14) {
                    HStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    Text("“I feel like I'm living a brand new life!”")
                        .font(.grotesk(.title2, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.25), value: appearAnimation)
                
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1.0, z: 0))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.6).delay(0.2), value: appearAnimation)
            }
            
            HStack(spacing: 10) {
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.6).delay(0.3), value: appearAnimation)
                
                VStack(spacing: 14) {
                    Text("Science-inspired approach")
                        .font(.grotesk(.title2, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.35), value: appearAnimation)
                
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1.0, z: 0))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.6).delay(0.3), value: appearAnimation)
            }

            HStack(spacing: 10) {
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.5).delay(0.4), value: appearAnimation)
                
                VStack(spacing: 14) {
                    Text("Save 15 hours weekly")
                        .font(.grotesk(.title2, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.45), value: appearAnimation)
                
                Image("laurel.leading")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1.0, z: 0))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 1.25)
                    .animation(.smooth(duration: 0.4).delay(0.4), value: appearAnimation)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 48) {
                VStack(spacing: 14) {
                    Text("Welcome to \(AppConfiguration.name)!")
                        .font(.grotesk(size: 28, weight: .semibold))
                    
                    Text("Make time for what matters most in your life.")
                        .font(.grotesk(.body, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineSpacing(2.0)
                }
                .multilineTextAlignment(.center)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)

                GlassButton("Continue") {
                    action()
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
            }
            .padding(.horizontal, 32)
            .padding()
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        appearAnimation = true
    }
    
    private func action() {
        vm.nextPage()
    }
}

// MARK: - Preview
#Preview {
    OBWelcome_V2()
        .environmentObject(OBVM_V2())
        .environmentObject(ToastManager())
}

#Preview("OBAccolades_V2") {
    OBAccolades_V2()
        .environmentObject(OBVM_V2())
}

// MARK: - Keyframe Animations
extension View {
    
    func appIconKeyframeAnimation(trigger: Bool, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        self.keyframeAnimator(initialValue: AppIconKeyframe(), trigger: trigger) { view, frame in
            view
                .rotation3DEffect(.degrees(frame.rotation3d), axis: (1.0, 0.0, 0.0))
                .scaleEffect(frame.scale)
                .offset(x: frame.offsetX, y: frame.offsetY)
                .brightness(frame.brightness)
        } keyframes: { frame in
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(.zero, duration: 0.25)
                CubicKeyframe(offsetY * 2.0, duration: 0.5)
                CubicKeyframe(offsetY, duration: 0.5)
            }
            
            KeyframeTrack(\.offsetX) {
                CubicKeyframe(.zero, duration: 0.25)
                CubicKeyframe(offsetX, duration: 1.05)
            }
            
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.0, duration: 0.1)
                CubicKeyframe(0.95, duration: 0.15)
                CubicKeyframe(3, duration: 0.35)
                
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
                CubicKeyframe(0.2, duration: 0.2)
                CubicKeyframe(.zero, duration: 0.4)
            }
        }
    }
    
    func mainKeyframeAnimation(trigger: Bool, offsetY: CGFloat) -> some View {
        self.keyframeAnimator(initialValue: MainContentKeyframe(), trigger: trigger) { view, frame in
            view
                .scaleEffect(frame.scale)
                .offset(y: frame.offsetY)
        } keyframes: { frame in
            KeyframeTrack(\.offsetY) {
                CubicKeyframe(-20, duration: 0.15)
                CubicKeyframe(.zero, duration: 0.20)
                SpringKeyframe(offsetY, spring: .smooth(duration: 0.45, extraBounce: 0.15))
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

// MARK: - Keyframes
struct AppIconKeyframe {
    var offsetY: CGFloat = .zero
    var offsetX: CGFloat = .zero
    var scale: CGFloat = 1.0
    var rotation3d: CGFloat = .zero
    var brightness: Double = .zero
}

struct MainContentKeyframe {
    var scale: CGFloat = 1.0
    var offsetY: CGFloat = .zero
}

/*
 
 func appIconKeyframeAnimation(trigger: Bool, offsetX: CGFloat, offsetY: CGFloat) -> some View {
     self.keyframeAnimator(initialValue: AppIconKeyframe(), trigger: trigger) { view, frame in
         view
             .rotation3DEffect(.degrees(frame.rotation3d), axis: (1.0, 0.0, 0.0))
             .scaleEffect(frame.scale)
             .offset(x: frame.offsetX, y: frame.offsetY)
             .brightness(frame.brightness)
     } keyframes: { frame in
         KeyframeTrack(\.offsetY) {
             CubicKeyframe(.zero, duration: 0.25)
             CubicKeyframe(offsetY * 2.0, duration: 0.5)
             CubicKeyframe(offsetY, duration: 0.5)
         }
         
         KeyframeTrack(\.offsetX) {
             CubicKeyframe(.zero, duration: 0.25)
             CubicKeyframe(offsetX, duration: 1.05)
         }
         
         KeyframeTrack(\.scale) {
             CubicKeyframe(1.0, duration: 0.1)
             CubicKeyframe(0.95, duration: 0.15)
             CubicKeyframe(3, duration: 0.35)
             
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
             CubicKeyframe(0.2, duration: 0.2)
             CubicKeyframe(.zero, duration: 0.4)
         }
     }
 }
 
 */


/*
struct OBWelcome_V2: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject var vm: OBVM_V2
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var appearAnimation: Bool = false

    let defaultDelay: TimeInterval = 0.3
        
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
            Image(.blockrIconTransparent)
                .resizable()
                .scaledToFit()
                .frame(square: 92)
                .rotationEffect(.degrees(180))
                .rotationEffect(.degrees(appearAnimation ? -180 : 0))
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)

            VStack(spacing: 14) {
                Text("Find peace,\nin a world of noise.")
                    .font(.grotesk(size: 32, weight: .semibold))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                
//                        Text("Your time.\nYour control.")
//                            .font(.grotesk(size: 36, weight: .semibold))
                
                Text("Take back your attention in a world built to steal it.")
                    .font(.grotesk(.body, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.15), value: appearAnimation)
            }
            .foregroundStyle(.textC)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                
                HStack(spacing: 10) {
                    Image("laurel.leading")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                        .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 1.25)
                        .animation(.smooth(duration: 0.6).delay(0.2), value: appearAnimation)
                    
                    VStack(spacing: 14) {
                        HStack(spacing: 0) {
                            ForEach(0..<5) { index in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        Text("“I feel like I'm living a brand new life!”")
                            .font(.grotesk(.body, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.25), value: appearAnimation)
                    
                    Image("laurel.leading")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                        .symbolEffect(.wiggle.byLayer, options: .nonRepeating)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1.0, z: 0))
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 1.25)
                        .animation(.smooth(duration: 0.6).delay(0.2), value: appearAnimation)
                }
                .padding(.horizontal, 32)

//                VStack(spacing: 14) {
//                    Text("Find peace,\nin a world of noise.")
//                        .font(.grotesk(size: 32, weight: .semibold))
//                        .opacity(appearAnimation ? 1 : 0)
//                        .offset(y: appearAnimation ? 0 : 56)
//                        .scaleEffect(appearAnimation ? 1 : 0.85)
//                        .animation(.smooth.delay(defaultDelay + 0.1), value: appearAnimation)
//
////                        Text("Your time.\nYour control.")
////                            .font(.grotesk(size: 36, weight: .semibold))
//
//                    Text("Take back your attention in a world built to steal it.")
//                        .font(.grotesk(.body, weight: .medium))
//                        .foregroundStyle(.secondary)
//                        .padding(.horizontal)
//                        .opacity(appearAnimation ? 1 : 0)
//                        .offset(y: appearAnimation ? 0 : 56)
//                        .scaleEffect(appearAnimation ? 1 : 0.85)
//                        .animation(.smooth.delay(defaultDelay + 0.15), value: appearAnimation)
//                }
//                .foregroundStyle(.textC)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 32)

//                HStack {
//                    HStack(spacing: -10) {
//                        Image(systemName: "laurel.leading")
//                            .font(.system(size: 50))
//                            .foregroundStyle(.yellow)
//
//                        Text("Save 14 hours weekly")
//                            .font(.grotesk(.subheadline, weight: .semibold))
//                            .multilineTextAlignment(.center)
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal, 8)
//
//                        Image(systemName: "laurel.trailing")
//                            .font(.system(size: 50))
//                            .foregroundStyle(.yellow)
//                    }
//
//                    HStack(spacing: -10) {
//                        Image(systemName: "laurel.leading")
//                            .font(.system(size: 50))
//                            .foregroundStyle(.yellow)
//
//                        Text("Science inspired approach")
//                            .font(.grotesk(.subheadline, weight: .semibold))
//                            .multilineTextAlignment(.center)
//                            .frame(maxWidth: .infinity)
//                            .padding(.horizontal, 8)
//
//                        Image(systemName: "laurel.trailing")
//                            .font(.system(size: 50))
//                            .foregroundStyle(.yellow)
//                    }
//
//                }
//                .foregroundStyle(.textC)
//                .padding(.horizontal, 32)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 56)
//                .scaleEffect(appearAnimation ? 1 : 0.85)
//                .animation(.smooth.delay(defaultDelay + 0.2), value: appearAnimation)

                VStack(spacing: 12) {
                    GlassButton("Let's Begin!") {
                        action()
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.horizontal, 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.3), value: appearAnimation)
                    
                    VStack(spacing: 5) {
                        Text("By continuing, you agree to \(AppConfiguration.name)'s")
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 5) {
                            Button {
                                openExternalURL(AppConfiguration.termsURL)
                            } label: {
                                Text("Terms of Use").fontWeight(.semibold)
                            }
                            .tint(.primary)
                            .opacity(0.6)
                            
                            Text("&").foregroundStyle(.secondary)
                            
                            Button {
                                openExternalURL(AppConfiguration.privacyURL)
                            } label: {
                                Text("Privacy Policy").fontWeight(.semibold)
                            }
                            .tint(.primary)
                            .opacity(0.6)
                        }
                    }
                    .font(.caption)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.3), value: appearAnimation)
                    .padding(.bottom)
                }
            }
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextPage()
    }
    
    private func openExternalURL(_ url: URL) {
        openURL(url) { accepted in
            if !accepted {
                toastManager.error("Unable to open link.")
            }
        }
    }
    
    private func openExternalURL(_ string: String) {
        guard let url = URL(string: string) else {
            toastManager.error("Invalid link.")
            return
        }
        openExternalURL(url)
    }
}
 */


/*
 
 struct OBWelcome_V2: View {
     @Namespace var nspace
     
     @Environment(\.colorScheme) var colorScheme
     @Environment(\.openURL) private var openURL
     
     @EnvironmentObject var vm: OBVM_V2
     @EnvironmentObject var toastManager: ToastManager
     
     @State private var appearAnimation: Bool = false
     @State private var appearAnimationTwo: Bool = false

     @State private var scaleEffect: CGFloat = 1.0
     @State private var showNext: Bool = false
     
     @State private var selectedAnswers: [OBAnswer] = []

     let defaultDelay: TimeInterval = 0.3
     
     let answers: [OBAnswer] = [
         OBAnswer(title: "To build healthier habits"),
         OBAnswer(title: "To reduce distractions"),
         OBAnswer(title: "To stop doom-scrolling"),
         OBAnswer(title: "To improve sleep"),
         OBAnswer(title: "To be more present"),
         OBAnswer(title: "Other"),
     ]
         
     var body: some View {
         VStack(spacing: 32) {
             Image(.ghost)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 128)
                 .opacity(appearAnimation ? 1 : 0)
                 .scaleEffect(appearAnimation ? 1 : 0.25)
                 .offset(y: appearAnimation ? 0 : 128)
                 .animation(.smooth(extraBounce: 0.25).delay(0.25), value: appearAnimation)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: phase ? 4 : 0)
                 } animation: { _ in
                         .smooth(duration: 1.0)
                 }
         }
         .overlay {
             Circle()
                 .frame(square: 16)
                 .foregroundStyle(.blue)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: 10)
                         .rotationEffect(.degrees(phase ? -360 : 0))
                 } animation: { _ in
                         .linear(duration: 10.0).repeatForever(autoreverses: false)
                 }
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? 128 : 0,
                     y: appearAnimation ? 0 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25), value: appearAnimation)

             Circle()
                 .frame(square: 30)
                 .foregroundStyle(.yellow)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: 10)
                         .rotationEffect(.degrees(phase ? 360 : 0))
                 } animation: { _ in
                         .linear(duration: 6.0).repeatForever(autoreverses: false)
                 }
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -128 : 0,
                     y: appearAnimation ? -32 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.05), value: appearAnimation)
             
             Image(.flower)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 56)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .rotationEffect(.degrees(phase ? 360 : 0))
                 } animation: { _ in
                         .linear(duration: 6.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -32 : 0,
                     y: appearAnimation ? -128 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)
             
             Image(.flower)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 32)
                 .hueRotation(.degrees(-20))
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .rotationEffect(.degrees(phase ? -360 : 0))
                 } animation: { _ in
                         .linear(duration: 9.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -158 : 0,
                     y: appearAnimation ? 40 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)
             
             Image(.lock)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 56)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: phase ? -10 : 0)
                         .rotationEffect(.degrees(phase ? -10 : 10))
                 } animation: { _ in
                         .smooth(duration: 5.0).repeatForever(autoreverses: true)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? 128 : 0,
                     y: appearAnimation ? -108 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)
             
             Image(.shield)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 40)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: phase ? 10 : 0)
                         .rotationEffect(.degrees(phase ? 10 : -10))
                 } animation: { _ in
                         .smooth(duration: 3.0).repeatForever(autoreverses: true)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -8 : 0,
                     y: appearAnimation ? 128 : 160
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.03), value: appearAnimation)
             
             Image(.star4)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 20)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .rotationEffect(.degrees(phase ? -360 : 0))
                 } animation: { _ in
                         .linear(duration: 16.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? 56 : 0,
                     y: appearAnimation ? -128 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)
             
             Image(.star4)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 20)
                 .hueRotation(.degrees(40))
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .rotationEffect(.degrees(phase ? -360 : 0))
                 } animation: { _ in
                         .linear(duration: 16.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? 156 : 0,
                     y: appearAnimation ? -30 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)

             Image(.star4)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 32)
                 .brightness(0.2)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: -10)
                         .rotationEffect(.degrees(phase ? -360 : 0))
                 } animation: { _ in
                         .linear(duration: 16.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -108 : 0,
                     y: appearAnimation ? 108 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.02), value: appearAnimation)
             
             Image(.star)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 40)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: 10)
                         .rotationEffect(.degrees(phase ? 360 : 0))
                 } animation: { _ in
                         .linear(duration: 16.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? 100 : 0,
                     y: appearAnimation ? 100 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.08), value: appearAnimation)
             
             Image(.star)
                 .resizable()
                 .scaledToFit()
                 .frame(square: 18)
                 .phaseAnimator([true, false]) { view, phase in
                     view
                         .offset(y: -10)
                         .rotationEffect(.degrees(phase ? 360 : 0))
                 } animation: { _ in
                         .linear(duration: 10.0).repeatForever(autoreverses: false)
                 }
                 .foregroundStyle(.yellow)
                 .scaleEffect(appearAnimation ? 1 : 0.45)
                 .offset(
                     x: appearAnimation ? -100 : 0,
                     y: appearAnimation ? -100 : 128
                 )
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(extraBounce: 0.25).delay(0.05), value: appearAnimation)

         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .scaleEffect(scaleEffect)
         .safeAreaInset(edge: .bottom) {
             VStack(spacing: 32) {
                 VStack(spacing: 14) {
                     Text("Find peace,\nin a world of noise.")
                         .font(.grotesk(size: 32, weight: .semibold))
                         .opacity(appearAnimation ? 1 : 0)
                         .offset(y: appearAnimation ? 0 : 56)
                         .scaleEffect(appearAnimation ? 1 : 0.85)
                         .animation(.smooth.delay(defaultDelay + 0.1), value: appearAnimation)
                     
 //                        Text("Your time.\nYour control.")
 //                            .font(.grotesk(size: 36, weight: .semibold))
                     
                     Text("Take back your attention in a world built to steal it.")
                         .font(.grotesk(.body, weight: .medium))
                         .foregroundStyle(.secondary)
                         .padding(.horizontal)
                         .opacity(appearAnimation ? 1 : 0)
                         .offset(y: appearAnimation ? 0 : 56)
                         .scaleEffect(appearAnimation ? 1 : 0.85)
                         .animation(.smooth.delay(defaultDelay + 0.15), value: appearAnimation)
                 }
                 .foregroundStyle(.textC)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal, 32)
                 .scaleEffect(scaleEffect)

                 HStack {
                     HStack(spacing: -10) {
                         Image(systemName: "laurel.leading")
                             .font(.system(size: 50))
                             .foregroundStyle(.yellow)
                         
                         Text("Save 14 hours weekly")
                             .font(.grotesk(.subheadline, weight: .semibold))
                             .multilineTextAlignment(.center)
                             .frame(maxWidth: .infinity)
                             .padding(.horizontal, 8)
                         
                         Image(systemName: "laurel.trailing")
                             .font(.system(size: 50))
                             .foregroundStyle(.yellow)
                     }
                     
                     HStack(spacing: -10) {
                         Image(systemName: "laurel.leading")
                             .font(.system(size: 50))
                             .foregroundStyle(.yellow)
                         
                         Text("Science based approach")
                             .font(.grotesk(.subheadline, weight: .semibold))
                             .multilineTextAlignment(.center)
                             .frame(maxWidth: .infinity)
                             .padding(.horizontal, 8)
                         
                         Image(systemName: "laurel.trailing")
                             .font(.system(size: 50))
                             .foregroundStyle(.yellow)
                     }

                 }
                 .foregroundStyle(.textC)
                 .padding(.horizontal, 32)
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 56)
                 .scaleEffect(appearAnimation ? 1 : 0.85)
                 .animation(.smooth.delay(defaultDelay + 0.2), value: appearAnimation)
                 .scaleEffect(scaleEffect)

                 VStack(spacing: 12) {
                     GlassButton("Let's Begin!", labelColor: colorScheme == .light ? .white : .black, background: colorScheme == .light ? Color(hex: 0x00B4FF) : .white) {
                         action()
                     }
                     .matchedGeometryEffect(id: "glassButton", in: nspace)
                     .padding([.horizontal, .bottom])
                     .padding(.horizontal, 32)
                     .opacity(appearAnimation ? 1 : 0)
                     .offset(y: appearAnimation ? 0 : 56)
                     .scaleEffect(appearAnimation ? 1 : 0.85)
                     .animation(.smooth.delay(defaultDelay + 0.3), value: appearAnimation)
                     
                     VStack(spacing: 5) {
                         Text("By continuing, you agree to \(AppConfiguration.name)'s")
                             .foregroundStyle(.secondary)
                         
                         HStack(spacing: 5) {
                             Button {
                                 openExternalURL(AppConfiguration.termsURL)
                             } label: {
                                 Text("Terms of Use").fontWeight(.semibold)
                             }
                             .tint(.primary)
                             .opacity(0.6)
                             
                             Text("&").foregroundStyle(.secondary)
                             
                             Button {
                                 openExternalURL(AppConfiguration.privacyURL)
                             } label: {
                                 Text("Privacy Policy").fontWeight(.semibold)
                             }
                             .tint(.primary)
                             .opacity(0.6)
                         }
                     }
                     .font(.caption)
                     .opacity(appearAnimation ? 1 : 0)
                     .offset(y: appearAnimation ? 0 : 56)
                     .scaleEffect(appearAnimation ? 1 : 0.85)
                     .animation(.smooth.delay(defaultDelay + 0.4), value: appearAnimation)
                     .padding(.bottom)
                 }
             }
         }
         .overlay {
             Color(UIColor.systemBackground).ignoresSafeArea()
                 .opacity(showNext ? 1 : 0)
             
             if showNext {
                 VStack {
                     Text("Why are you here?")
                         .font(.grotesk(size: 26, weight: .semibold))
                         .padding(.trailing)
                         .lineSpacing(2.0)
                         .opacity(appearAnimationTwo ? 1 : 0)
                         .offset(y: appearAnimationTwo ? 0 : 32)
                         .scaleEffect(appearAnimationTwo ? 1 : 0.95)
                         .animation(.smooth, value: appearAnimationTwo)
                     
                     ForEach(Array(answers.enumerated()), id: \.offset) { (index, answer) in
                         let isSelected = selectedAnswers.contains(answer)
                         
                         Button {
                             addRemove(answer)
                         } label: {
                             RoundedRectangle(cornerRadius: 18, style: .continuous)
                                 .frame(height: 64)
                                 .foregroundStyle(isSelected ? Color.blueAccent.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                                 .overlay {
                                     RoundedRectangle(cornerRadius: 18, style: .continuous)
                                         .stroke(lineWidth: 2.0)
                                         .frame(height: 64)
                                         .foregroundStyle(isSelected ? Color.blueAccent : Color.gray.opacity(0.15))
                                 }
                                 .overlay(alignment: .leading) {
                                     Text(answer.title)
                                         .font(.grotesk(.body, weight: .medium))
                                         .padding(.horizontal)
                                 }
                                 .overlay(alignment: .trailing) {
                                     Checkmark(
                                         size: 24,
                                         trigger: .isPresent(
                                             in: $selectedAnswers,
                                             element: answer
                                         ),
                                         backgroundColor: Color.blueAccent
                                     )
                                     .padding(.trailing, 22)
                                 }
                         }
                         .tint(.primary)
                         .opacity(appearAnimationTwo ? 1 : 0)
                         .offset(y: appearAnimationTwo ? 0 : 32)
                         .scaleEffect(appearAnimationTwo ? 1 : 0.95)
                         .animation(.smooth.delay(TimeInterval(index + 1) * 0.1), value: appearAnimationTwo)
                     }

                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Continue", labelColor: colorScheme == .light ? .white : .black, background: colorScheme == .light ? Color(hex: 0x00B4FF) : .white) {
                         vm.nextPage()
                     }
                     .matchedGeometryEffect(id: "glassButton", in: nspace)
                     .padding([.horizontal, .bottom])
                     .padding(.horizontal, 32)
                 }
                 .transition(.scale(0.9).combined(with: .opacity))
             }
         }
         .onAppear(perform: setup)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.1) {
             appearAnimation = true
         }
     }
     
     private func action() {
         withAnimation(.smooth(duration: 0.45)) {
             scaleEffect = 1.1
             
             showNext = true
         }
         
         SleepTask.sleep(seconds: 0.1) {
             appearAnimationTwo = true
         }
     }
     
     private func openExternalURL(_ url: URL) {
         openURL(url) { accepted in
             if !accepted {
                 toastManager.error("Unable to open link.")
             }
         }
     }
     
     private func openExternalURL(_ string: String) {
         guard let url = URL(string: string) else {
             toastManager.error("Invalid link.")
             return
         }
         openExternalURL(url)
     }
     
     private func addRemove(_ answer: OBAnswer) {
         if let index = selectedAnswers.firstIndex(where: { $0.title == answer.title }) {
             selectedAnswers.remove(at: index)
         } else {
             selectedAnswers.append(answer)
         }
         Haptics.feedback(style: .light)
     }
 }

 
 */
