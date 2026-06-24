//
//  OBRatingPrompt.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/09/25.
//

import SwiftUI
import Lottie

struct OBRatingPrompt: View {
    @Environment(\.requestReview) var requestReview
    
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var appearAnimation: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                LottieView(animation: .named("blue-heart"))
                    .looping()
                    .frame(square: 50)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.0), value: appearAnimation)

                VStack(spacing: 32) {
                    VStack(spacing: 14) {
                        Text("\(AppConfiguration.name) was designed for people like you.")
                            .font(.grotesk(.title, weight: .semibold))
                            .multilineTextAlignment(.center)
                        
                        Text("Give us a rating!")
                            .font(.grotesk(.body, weight: .regular))
                            .opacity(0.65)
                    }
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.15), value: appearAnimation)
                    
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 64, weight: .medium))
                        
                        HStack(spacing: 8) {
                            ForEach(0..<5) { star in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        Image(systemName: "laurel.trailing")
                            .font(.system(size: 64, weight: .medium))
                    }
                    .padding(.horizontal)
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.35), value: appearAnimation)
                }
                
                VStack(spacing: 32) {
                    ReviewRow(
                        stars: 5,
                        title: "Changed my life",
                        description: "BLOCKR has been a lifesaver for me. I’ve tried so many apps before, but this is the only one that actually stuck. I honestly can’t imagine my life without it now.\nThank you guys so much!"
                    )
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.45), value: appearAnimation)
                    
                    ReviewRow(
                        stars: 5,
                        title: "Highly recommend",
                        description: "I think blockr is literally the most effective way for me to be off of distracting apps and helping me take control of my time. I highly recommend it!"
                    )
                    .offset(y: appearAnimation ? 0 : 32)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.smooth(duration: 0.35).delay(0.5), value: appearAnimation)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top)
            .padding(.horizontal, 32)
            .padding(.vertical)
            .padding(.bottom, 32)
        }
        .overlay {
            LinearGradient(colors: [
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                Theme.backgroundC,
                Theme.backgroundC
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding(.horizontal, 32)
            .padding(.vertical)
            .offset(y: appearAnimation ? 0 : 32)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.35).delay(1.0), value: appearAnimation)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.8) {
            requestReview()
        }
        
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextStep()
    }
    
    @ViewBuilder
    private func ReviewRow(stars: Int, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .leading) {
                HStack(spacing: 6) {
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.secondary.opacity(0.5))
                            .frame(square: 18)
                    }
                }
                
                HStack(spacing: 6) {
                    ForEach(0..<stars, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.yellow)
                            .frame(square: 18)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.grotesk(.title3, weight: .semibold))
                
                Text(description)
                    .font(.grotesk(.body, weight: .regular))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.foregroundC, in: .rect(cornerRadius: 18, style: .continuous))

    }
}

#Preview {
    OBRatingPrompt()
        .environmentObject(OBUserViewModel())
}
