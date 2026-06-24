//
//  StreaksView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/12/25.
//

import SwiftUI
import Lottie

struct StreaksView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    
    @State private var appearAnimation: Bool = false
    
    var streakCount: Int {
        vm.currentStreak
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                LottieView(animation: .named("fire"))
                    .looping()
                    .frame(square: 128)
                    .background {
                        LottieView(animation: .named("fire"))
                            .looping()
                            .frame(square: 128)
                            .scaleEffect(1.1)
                            .brightness(1.0)
                            .shadow(radius: 8)
                            .offset(y: -2)
                    }
                    .padding(.bottom)

                VStack(spacing: 0) {
                    Text(streakCount.description)
                        .font(.grotesk(size: 100, weight: .semibold))
                        .contentTransition(.numericText(value: Double(streakCount)))
                        .foregroundStyle(Color.primaryOrange)
                        .offset(y: -32)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        .animation(.smooth, value: appearAnimation)
                        .frame(height: 90, alignment: .top)
                    
                    Text("Day Streak")
                        .font(.grotesk(size: 32, weight: .bold))
                        .foregroundStyle(Color.primaryOrange)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        .animation(.smooth, value: appearAnimation)
                }
                .grayscale(streakCount == 0 ? 1 : 0)
                
                Space(height: 20)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                Text("Keep your screen time under your goal to maintain your streak!")
                    .font(.grotesk(.subheadline))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .padding(.horizontal, 32)
                    .padding(.vertical)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .onAppear(perform: setup)
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
}

#Preview {
    StreaksView()
        .environmentObject(UserViewModel())
}
