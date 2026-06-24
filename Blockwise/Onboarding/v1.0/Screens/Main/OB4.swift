//
//  OB4.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OB4: View {
    @EnvironmentObject var toastManager: ToastManager
    
    @EnvironmentObject var vm: OBVM
    @Environment(\.openURL) private var openURL

    @State private var appearAnimation: Bool = false
    
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 32) {
                    ForEach(Array(Review.reviews.enumerated()), id: \.offset) { (index, review) in
                        ReviewRow(review)
                            .id(index)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .scrollTransition { view, phase in
                                view
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 20)
            .padding(.horizontal, -32)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrollPosition)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            
//            Image(.beforeAfter)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 10)
//                .padding(.vertical)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
            
            HStack(spacing: 10) {
                ForEach(Array(Review.reviews.enumerated()), id: \.offset) { (index, review) in
                    Circle()
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay {
                            Circle()
                                .opacity(index == scrollPosition ? 1 : 0)
                                .foregroundStyle(.secondary)
                        }
                        .frame(square: 6)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
            .animation(.smooth, value: scrollPosition)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
            
            VStack(alignment: .center, spacing: 32) {
//                Group {
//                    Text("Your life") +
//                    Text("\nshouldn't be all\n")
//                        .foregroundStyle(Color.blueAccent) +
//                    Text("about your phone.")
//                }
//                .font(.grotesk(size: 30, weight: .semibold))
//                .multilineTextAlignment(.center)
//                .lineSpacing(2.0)
//                .padding(.horizontal)

//                    Group {
//                        Text("If you're here, you") +
//                        Text("\nfeel like something\n")
//                            .foregroundStyle(Color.blueAccent) +
//                        Text("needs to change.")
//                    }
//                    .font(.grotesk(size: 30, weight: .semibold))
//                    .multilineTextAlignment(.center)
//                    .lineSpacing(2.0)
//                    .padding(.horizontal)

                Group {
//                    Text("Break the cycle and") +
//                    Text(" live a more present ")
//                        .foregroundStyle(Color.blueAccent) +
//                    Text("life today.")

                    Text("Live a healthier and") +
                    Text(" more present life ")
                        .foregroundStyle(Color.blueAccent) +
                    Text("with \(AppConfiguration.name).")
                }
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Let's begin") {
                    action()
                }
                
                VStack(spacing: 5) {
                    Text("By continuing, you agree to \(AppConfiguration.name)'s")
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 5) {
                        Button {
                            openExternalURL(AppConfiguration.termsURL)
                        } label: {
                            Text("Terms of Use").fontWeight(.medium)
                        }
                        .tint(.primary)
                        .opacity(0.8)
                        
                        Text("&").foregroundStyle(.secondary)
                        
                        Button {
                            openExternalURL(AppConfiguration.privacyURL)
                        } label: {
                            Text("Privacy Policy").fontWeight(.medium)
                        }
                        .tint(.primary)
                        .opacity(0.8)
                    }
                }
                .font(.caption)
            }
            .padding()
            .padding(.horizontal, 32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        // View specific action
        vm.welcomeProgress = .three

        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.showWelcomeProgress = false
        vm.nextPage()
        
        // Mixpanel - (WS1: Welcome Step 3)
        AnalyticsService.shared.track("Onboarding > WS3")
    }
    
    // MARK: - External URL Helper
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

    // MARK: - UI components
    @ViewBuilder
    private func ReviewRow(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.yellow)
                            .font(.system(size: 20))
                    }
                }
                
                Text(review.title)
                    .font(.grotesk(.title2, weight: .semibold))
            }
            
            Text(review.body)
                .font(.grotesk(.body, weight: .regular))
                .lineSpacing(4.0)
                .opacity(0.8)
            
            HStack(spacing: 10) {
                Image(review.asset)
                    .resizable()
                    .scaledToFit()
                    .frame(square: 32)
                
                Text(review.name)
                    .font(.grotesk(.body, weight: .medium))
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(lineWidth: 2.0)
                .foregroundStyle(.secondary.opacity(0.15))
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

}

#Preview {
    OB4()
        .environmentObject(OBVM())
        .environmentObject(ToastManager())
}
