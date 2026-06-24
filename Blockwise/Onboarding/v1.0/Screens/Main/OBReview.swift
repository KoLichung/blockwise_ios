//
//  OBReview.swift
//  Blockwise
//
//  Created by Ivan Sanna on 22/11/25.
//

import SwiftUI

struct OBReview: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var vm: OBVM

    @State private var appearAnimation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                Space(height: 10)
                
                Text("We're a small team, so a rating goes a long way")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
                HStack(spacing: 10) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 24))
                        }
                    }
                    
                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
                .padding(.bottom)
                
                Text("\(AppConfiguration.name) was designed for people like you")
                    .font(.grotesk(.subheadline))
                    .opacity(0.8)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.15), value: appearAnimation)
                
                VStack(spacing: 18) {
                    HStack(spacing: -16) {
                        Image(.userFeedbackPhoto1)
                            .resizable()
                            .scaledToFit()
                            .frame(square: 64)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            }

                        Image(.userFeedbackPhoto2)
                            .resizable()
                            .scaledToFit()
                            .frame(square: 64)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            }
                        
                        Image(.userFeedbackPhoto3)
                            .resizable()
                            .scaledToFit()
                            .frame(square: 64)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            }
                    }
                    
                    Text("+ 1000 happy people")
                        .foregroundStyle(.secondary)
                        .font(.grotesk())
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.15), value: appearAnimation)
                .padding(.bottom)

                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(.userFeedbackPhoto1)
                                .resizable()
                                .frame(square: 40)
                            
                            Text("Igor S.")
                                .font(.grotesk(.body, weight: .medium))
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My phone made me anxious, but I couldn’t stop checking it. This app honestly lowered my stress more than anything else I’ve tried. I didn’t expect it to help this much.")
                                .font(.grotesk(.subheadline, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4.0)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.15))
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.15), value: appearAnimation)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(.userFeedbackPhoto3)
                                .resizable()
                                .frame(square: 40)
                            
                            Text("Michael T.")
                                .font(.grotesk(.body, weight: .medium))
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My phone made me anxious, but I couldn’t stop checking it. This app honestly lowered my stress more than anything else I’ve tried. I didn’t expect it to help this much.")
                                .font(.grotesk(.subheadline, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4.0)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.15))
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.15), value: appearAnimation)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(.userFeedbackPhoto2)
                                .resizable()
                                .frame(square: 40)
                            
                            Text("Ivan S.")
                                .font(.grotesk(.body, weight: .medium))
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My phone made me anxious, but I couldn’t stop checking it. This app honestly lowered my stress more than anything else I’ve tried. I didn’t expect it to help this much.")
                                .font(.grotesk(.subheadline, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4.0)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(.secondary.opacity(0.15))
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.15), value: appearAnimation)

                }
                .animation(.smooth.delay(0.30), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.35), value: appearAnimation)
            .background {
                LinearGradient(
                    colors: [.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        requestReview()

        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Review")

    }
    
}

#Preview {
    OBReview()
        .environmentObject(OBVM())
}
