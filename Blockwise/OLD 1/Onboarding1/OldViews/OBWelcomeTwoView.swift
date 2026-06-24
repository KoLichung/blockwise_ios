//
//  OBWelcomeTwoView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/06/25.
//

import SwiftUI
import Lottie

struct OBWelcomeTwoView: View {
    @State private var show: Bool = false

    @State private var appearAnimation: Bool = false
    @State private var phaseOne: Bool = false
    @State private var phaseTwo: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            ZStack {
                Group {
                    Text("Hey") +
                    Text(" there!").foregroundStyle(Color.primaryBlue)
                }
                .font(.system(size: 30, weight: .semibold))
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.8)
                .opacity(phaseOne ? 0 : 1)
                .offset(y: phaseOne ? -44 : 0)

                Text("Before we start,")
                    .font(.system(size: 30, weight: .semibold))
                    .opacity(phaseOne ? 1 : 0)
                    .offset(y: phaseOne ? 0 : 44)
                    .opacity(phaseTwo ? 0 : 1)
                    .offset(y: phaseTwo ? -44 : 0)

                Text("We're so proud of you.")
                    .font(.system(size: 30, weight: .semibold))
                    .opacity(phaseTwo ? 1 : 0)
                    .offset(y: phaseTwo ? 0 : 44)
                    .overlay(alignment: .bottom) {
                        Text("This isn't a easy habit to break")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .opacity(phaseTwo ? 1 : 0)
                            .offset(y: phaseTwo ? 44 : 100)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                Button("Start your Journey") {
                    action()
                }
                .foregroundStyle(Color.secondaryOrange)
                
//                Button {
//                    action()
//                } label: {
//                    RoundedRectangle(cornerRadius: 100, style: .continuous)
//                        .foregroundStyle(Color.primaryBlue)
//                        .frame(height: 60)
//                        .overlay {
//                            Text("Start your Journey")
//                                .font(.title3.weight(.semibold))
//                                .foregroundStyle(.white)
//                        }
//                }
                
                Text("By continuing, you accept our \(terms) and \(privacy)")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .tint(Color.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
            .opacity(phaseTwo ? 1 : 0)
            .offset(y: phaseTwo ? 0 : 144)
        }
        .background {
            ZStack {
                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.1)
                    .blur(radius: phaseTwo ? 88 : 32)
                    .opacity(phaseTwo ? 1 : 0)
                    .offset(x: phaseTwo ? 100 : 0, y: phaseTwo ? 100 : 0)

                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color.primaryBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.1)
                    .blur(radius: phaseTwo ? 88 : 32)
                    .opacity(phaseTwo ? 1 : 0)
                    .offset(x: phaseTwo ? -100 : 0, y: phaseTwo ? -100 : 0)
                
                ZStack {
                }
                .opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(phaseTwo ? 1 : 2.0)
                .opacity(phaseTwo ? 1 : 0)
                
            }
            .ignoresSafeArea()

        }
        .fullScreenCover(isPresented: $show) {
            OBRoadmapView()
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
                appearAnimation = true
            }
        }
        
        SleepTask.sleep(seconds: 1.0) {
            withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
                phaseOne = true
            }
            
            Haptics.feedback(style: .light)
        }

        SleepTask.sleep(seconds: 2.5) {
            withAnimation(.smooth(duration: 0.5, extraBounce: 0)) {
                phaseTwo = true
            }
            
            Haptics.feedback(style: .light)
        }

    }
    
    private func action() {
        show = true
    }
    
    @ViewBuilder
    private var privacy: Text {
        Text("**[Privacy Policy](\(AppConfiguration.privacyURL))**")
    }
    
    @ViewBuilder
    private var terms: Text {
        Text("**[Terms of Service](\(AppConfiguration.privacyURL))**")
    }
    
}

#Preview {
    OBWelcomeTwoView()
        .environmentObject(OBUserViewModel())
}
