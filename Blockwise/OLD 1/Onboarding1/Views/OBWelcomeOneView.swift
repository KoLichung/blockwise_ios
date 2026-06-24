//
//  OBWelcomeOneView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/06/25.
//

import SwiftUI
import Lottie

struct OBWelcomeOneView: View {
    @Environment(\.openURL) var openURL
    @StateObject private var vm = OBUserViewModel()

    // MARK: - State properties
    @State private var phoneOffsetY: CGFloat = .zero
    @State private var startPosition: CGRect = .zero {
        didSet { calculateOffsetIfReady() }
    }
    @State private var endPosition: CGRect = .zero {
        didSet { calculateOffsetIfReady() }
    }
    @State private var logoOffsetX: CGFloat = .zero
    @State private var logoOffsetY: CGFloat = .zero
    
    @State private var appearAnimation: Bool = false

    @State private var startAnimation: Bool = false
    @State private var endAnimation: Bool = false

    // MARK: - Fixed properties
    private let logoSize: CGFloat = 56
    private let phoneHPadding: CGFloat = 32
    private let phoneCornerRadius: CGFloat = 56
    private let phoneDockCornerRadius: CGFloat = 30
    private let phoneLineWidth: CGFloat = 7.0
    private let dockHeight: CGFloat = 76
    
    let appIcon: String = AppConfiguration.appIcon
    
    var body: some View {
        ZStack {
            if vm.paywallReached {
                OBQuizPaywall()
            } else {
                GeometryReader { geo in
                    let height: CGFloat = geo.size.height
                    let width: CGFloat = geo.size.width
                    
                    VStack(spacing: 0) {
                        Image(.iphoneShape)
                            .resizable()
                            .scaledToFit()
                            .brightness(0.1)
                            .overlay(alignment: .bottom) {
                                BottomPhoneDock(geo: geo)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: phoneCornerRadius, style: .continuous)
                                    .foregroundStyle(.thinMaterial.opacity(startAnimation ? 0.0 : 0.25))
                                    .animation(.smooth(duration: 0.35).delay(1.75), value: startAnimation)
                            }
                            .offset(y: -height * 0.5)
                            .padding(.horizontal, phoneHPadding)
                            .opacity(endAnimation ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .bottom) {
                        BottomContent(geo: geo)
                    }
                    .mainKeyframeAnimation(trigger: startAnimation, offsetY: height * 0.5)
                    .iphoneShapeKeyframeAnimation(startAnimation)
                    .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
                    .overlay {
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
        //            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        //            .background {
        //                Color.primaryOrange.opacity(0.1)
        //                    .ignoresSafeArea()
        //
        //                Image("ob-bg")
        //                    .resizable()
        //                    .scaledToFit()
        //                    .frame(maxHeight: .infinity, alignment: .top)
        //                    .ignoresSafeArea()
        //                    .offset(y: startAnimation ? 0 : -100)
        //            }
                }
                .overlay {
                    if endAnimation {
                        OBWelcomeView2()
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                }
                .onAppear(perform: setup)

            }
        }
        .environmentObject(vm)
    }
    
    // MARK: - View Components
    @ViewBuilder
    private func BottomPhoneDock(geo: GeometryProxy) -> some View {
        let appIconSize: CGFloat = dockHeight * 0.65
        let cornerRadius: CGFloat = 3.8

        RoundedRectangle(cornerRadius: phoneDockCornerRadius, style: .continuous)
            .foregroundStyle(Color.tertiaryBlue)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .overlay {
                ZStack {
//                    Image("instagram-icon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(square: appIconSize)
//                        .clipShape(RoundedRectangle(cornerRadius: appIconSize / cornerRadius))
//                        .offset(x: appIconSize * 0.65)
//                        .opacity(0.65)
//
//                    Image("tiktok-icon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(square: appIconSize)
//                        .clipShape(RoundedRectangle(cornerRadius: appIconSize / cornerRadius))
//                        .offset(x: -appIconSize * 0.65)
//                        .opacity(0.65)

                    RoundedRectangle(cornerRadius: appIconSize / 3.8)
                        .frame(square: appIconSize)
                        .foregroundStyle(Color.tertiaryBlue)
                        .brightness(0.1)
                        .offset(x: appIconSize * 0.65)
                        .iconKeyframeAnimation(startAnimation, edge: .leading)

                    RoundedRectangle(cornerRadius: appIconSize / 3.8)
                        .frame(square: appIconSize)
                        .foregroundStyle(Color.tertiaryBlue)
                        .brightness(0.1)
                        .offset(x: -appIconSize * 0.65)
                        .iconKeyframeAnimation(startAnimation, edge: .trailing)
                }
                .frame(square: appIconSize)
                .background {
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            endPosition = geo.frame(in: .global)
                            Logger.debug("End Position: \(endPosition)")
                        }
                    }
                }

            }
            .frame(height: dockHeight)
            .padding(28)
//            .dockKeyframeAnimation(startAnimation)
    }
    
    @ViewBuilder
    private func BottomContent(geo: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 32) {
                Image(appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(square: dockHeight * 0.65)
                    .clipShape(.rect(cornerRadius: logoSize / 4.4, style: .continuous))
                    .scaleEffect(startAnimation ? 1.0 : 1.15)
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
                    Text("A Science-Based Journey to ") +
                    Text("Quit Phone Addiction.").foregroundStyle(Color.primaryBlue)
                }
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
            }
            
            VStack(spacing: 22) {
                GlassButton("Start your Journey") {
                    action()
                }
                .foregroundStyle(Color.accentBlue)
                
                VStack(spacing: 4) {
                    Text("By continuing, you accept our")
                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            if let url = URL(string: AppConfiguration.termsURL) {
                                openURL(url)
                            }
                        }
                        .bold()
                        
                        Text("and")
                        
                        Button("Privacy Policy") {
                            if let url = URL(string: AppConfiguration.privacyURL) {
                                openURL(url)
                            }
                        }
                        .bold()
                    }
                }
                .multilineTextAlignment(.center)
                .font(.grotesk(.footnote, weight: .regular))
                .padding(.horizontal, 32)
                .padding(.horizontal)
                .opacity(0.8)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
    }

    // MARK: - Functions
    private func setup() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
            appearAnimation = true
        }
    }
    
    private func action() {
        withAnimation {
            startAnimation = true
        }
        
        SleepTask.sleep(seconds: 1.9) {
            withAnimation(.smooth(duration: 0.5)) {
                endAnimation = true
            }
        }
    }
    
    private func calculateOffsetIfReady() {
        // Check if both positions have been set (not zero)
        if startPosition != .zero && endPosition != .zero {
            logoOffsetX = endPosition.origin.x - startPosition.origin.x
            logoOffsetY = endPosition.origin.y - startPosition.origin.y
            Logger.debug("Calculated offset: x=\(logoOffsetX), y=\(logoOffsetY)")
        }
    }

        
}

#Preview {
    OBWelcomeOneView()
        .environmentObject(LocalNotificationManager())
}

//// MARK: - Keyframe Animations
//extension View {
//    
//    func appIconKeyframeAnimation(trigger: Bool, offsetX: CGFloat, offsetY: CGFloat) -> some View {
//        self.keyframeAnimator(initialValue: AppIconKeyframe(), trigger: trigger) { view, frame in
//            view
//                .rotation3DEffect(.degrees(frame.rotation3d), axis: (1.0, 0.0, 0.0))
//                .scaleEffect(frame.scale)
//                .offset(x: frame.offsetX, y: frame.offsetY)
//                .brightness(frame.brightness)
//        } keyframes: { frame in
//            KeyframeTrack(\.offsetY) {
//                CubicKeyframe(.zero, duration: 0.25)
//                CubicKeyframe(offsetY * 2, duration: 0.55)
//                CubicKeyframe(offsetY, duration: 0.5)
//            }
//            
//            KeyframeTrack(\.offsetX) {
//                CubicKeyframe(.zero, duration: 0.25)
//                CubicKeyframe(offsetX, duration: 1.05)
//            }
//            
//            KeyframeTrack(\.scale) {
//                CubicKeyframe(1.0, duration: 0.1)
//                CubicKeyframe(0.95, duration: 0.15)
//                CubicKeyframe(3, duration: 0.45)
//                
//                CubicKeyframe(1.0, duration: 0.6)
//                CubicKeyframe(0.9, duration: 0.15)
//                CubicKeyframe(1.0, duration: 0.15)
//            }
//            
//            KeyframeTrack(\.rotation3d) {
//                CubicKeyframe(.zero, duration: 0.35)
//                CubicKeyframe(360, duration: 0.95)
//            }
//            
//            KeyframeTrack(\.brightness) {
//                CubicKeyframe(.zero, duration: 0.55)
//                CubicKeyframe(0.8, duration: 0.5)
//                CubicKeyframe(.zero, duration: 0.25)
//            }
//        }
//    }
//    
//    func mainKeyframeAnimation(trigger: Bool, offsetY: CGFloat) -> some View {
//        self.keyframeAnimator(initialValue: MainContentKeyframe(), trigger: trigger) { view, frame in
//            view
//                .scaleEffect(frame.scale)
//                .offset(y: frame.offsetY)
//        } keyframes: { frame in
//            KeyframeTrack(\.offsetY) {
//                CubicKeyframe(-20, duration: 0.15)
//                CubicKeyframe(.zero, duration: 0.20)
//                SpringKeyframe(offsetY, spring: .smooth(duration: 0.45, extraBounce: 0.15))
//            }
//            
//            KeyframeTrack(\.scale) {
//                CubicKeyframe(1.0, duration: 0.35)
//                SpringKeyframe(1.1, spring: .smooth(duration: 0.5, extraBounce: 0.15))
//                CubicKeyframe(1.08, duration: 0.15)
//                SpringKeyframe(1.1, spring: .smooth(duration: 0.6, extraBounce: 0.15))
//            }
//        }
//    }
//
//}
//
//// MARK: - Keyframes
//struct AppIconKeyframe {
//    var offsetY: CGFloat = .zero
//    var offsetX: CGFloat = .zero
//    var scale: CGFloat = 1.0
//    var rotation3d: CGFloat = .zero
//    var brightness: Double = .zero
//}
//
//struct MainContentKeyframe {
//    var scale: CGFloat = 1.0
//    var offsetY: CGFloat = .zero
//}
