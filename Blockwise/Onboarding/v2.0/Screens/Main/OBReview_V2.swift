//
//  OBReview_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 20/01/26.
//

import SwiftUI

struct OBReview_V2: View {
    @EnvironmentObject var vm: OBVM_V2

    @State private var appearAnimation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                Space(height: 10)
                
                Text("We're a small team, so a rating goes a long way!")
                    .font(.grotesk(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                
//                HStack(spacing: 10) {
//                    Image(systemName: "laurel.leading")
//                        .font(.system(size: 40))
//                        .foregroundStyle(.yellow)
//                    
//                    HStack(spacing: 0) {
//                        ForEach(0..<5) { index in
//                            Image(systemName: "star.fill")
//                                .foregroundStyle(.yellow)
//                                .font(.system(size: 24))
//                        }
//                    }
//                    
//                    Image(systemName: "laurel.trailing")
//                        .font(.system(size: 40))
//                        .foregroundStyle(.yellow)
//                }
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)
//                .padding(.bottom)
                
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
                            .scaledToFill()
                            .frame(square: 64)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            }
                            .clipShape(Circle())
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
                            Text("Honestly thought this would be easy to ignore like every other screen time app. But the way it makes you think before opening apps is an absolute game changer.")
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
                                .clipShape(Circle())
                            
                            Text("Sarah L.")
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
                            Text("This app helped me realize I was checking Instagram without even thinking about it. Two weeks in and I'm way more present with my friends and family! 100% recommend.")
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
//                            Image(.userFeedbackPhoto2)
//                                .resizable()
//                                .frame(square: 40)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .frame(square: 40)
                                .foregroundStyle(.secondary)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("Anonymous")
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
                            Text("It helps me to cut back on doom scrolling and improve my social media “health”. I use it for my ADHD and tendency to doom scroll and lose complete lack of time. It’s made a HUGE impact for me. I haven’t been able to find anything else like it. ")
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
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextPage(progressTwo: 0.7)
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Ask Review")

    }
    
}

#Preview {
    OBReview_V2()
        .environmentObject(OBVM_V2())
}
