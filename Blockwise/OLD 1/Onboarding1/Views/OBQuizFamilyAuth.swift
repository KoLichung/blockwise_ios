//
//  OBQuizFamilyAuth.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/06/25.
//

import SwiftUI
import FamilyControls

struct OBQuizFamilyAuth: View {
    @Environment(\.dismiss) var dismiss
    let height: CGFloat = UIScreen.main.bounds.height
    
    @State private var steps: [Bool] = .init(repeating: false, count: 4)
    @State private var isLoading: Bool = false
    @State private var showChevron: Bool = false
    @State private var showLearnMore: Bool = false
    @State private var showErrorSheet: Bool = false
    
    @State private var roll: Bool = false
    
    let completion: () -> Void
    
    init(completion: @escaping () -> Void = {}) {
        self.completion = completion
    }

    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(Color(hex: 0x181818))
                        .overlay {
                            Image("logo-256w")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                        }
                        .offset(x: steps[0] ? -84 : -32)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 55, height: 4)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 16, height: 4)
                                .phaseAnimator([true, false]) { view, phase in
                                    view
                                        .offset(x: phase ? 47 : 0)
                                } animation: { _ in
                                        .smooth(duration: 0.25)
                                }

                        }
                        .opacity(steps[0] ? 1 : 0)
                        .scaleEffect(x: steps[0] ? 1 : 0.1)
                    
                    Circle()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(.indigo)
                        .overlay {
                            Image(systemName: "hourglass")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                        .background {
                            Circle()
                                .frame(width: 78, height: 78)
                                .foregroundStyle(.background)
                        }
                        .offset(x: steps[0] ? 84 : 32)
                }
                                
                Text("Connect with Screen Time to start blocking")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25).weight(.semibold))
                    .opacity(steps[2] ? 1 : 0)
                    .offset(y: steps[2] ? 0 : 8)
                    .padding(.horizontal)

            }
            .padding(.top, 56)
            .offset(y: steps[1] ? 0 : 64)
        }
        .padding()
        .padding(.horizontal)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: steps[1] ? .top : .center
        )
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Text("Secured by Apple")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 6)
                
                Button {
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(height: 50)
                        .overlay {
                            Text("Connect Screen Time")
                                .font(.system(size: 18.5).weight(.semibold))
                                .foregroundStyle(.white)
                        }
                }
                
                Button("Learn More") {
                    showLearnMore = true
                }
                .fontWeight(.medium)
            }
            .padding(.bottom)
            .padding(.horizontal, 32)
            .opacity(steps[3] ? 1 : 0)
            .offset(y: steps[3] ? 0 : 8)
        }
        .overlay {
            VStack(spacing: 32) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "hand.raised")
                        .font(.system(size: 30, weight: .semibold))
                        .frame(square: 40)
                        .foregroundStyle(Color.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Private & Secure")
                            .font(.subheadline.weight(.medium))
                        
                        Text("Your Screen Time data stays on your device and is never shared.")
                            .font(.subheadline.weight(.regular))
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(steps[2] ? 1 : 0)
                .offset(y: steps[2] ? 0 : 16)
                .animation(.smooth(duration: 0.45).delay(0.1), value: steps[2])

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "key.viewfinder")
                        .font(.system(size: 30, weight: .medium))
                        .frame(square: 40)
                        .foregroundStyle(Color.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Control, Anytime")
                            .font(.subheadline.weight(.semibold))
                        
                        Text("You can adjust or revoke access whenever you want.")
                            .font(.subheadline.weight(.regular))
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(steps[2] ? 1 : 0)
                .offset(y: steps[2] ? 0 : 16)
                .animation(.smooth(duration: 0.45).delay(0.2), value: steps[2])

                if (height > 800) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: "nosign")
                            .font(.system(size: 30, weight: .medium))
                            .frame(square: 40)
                            .foregroundStyle(Color.primaryBlue)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Apple-Backed Security")
                                .font(.subheadline.weight(.semibold))
                            
                            Text("BLOCKR uses Apple’s secure Screen Time framework.")
                                .font(.subheadline.weight(.regular))
                                .foregroundStyle(.secondary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(steps[2] ? 1 : 0)
                    .offset(y: steps[2] ? 0 : 16)
                    .animation(.smooth(duration: 0.45).delay(0.3), value: steps[2])
                }
            }
            .frame(maxHeight: .infinity)
            .padding(32)
            .padding(.horizontal)
            .offset(y: height * 0.03)
            .onAppear {
                print(height)
            }
        }
        .overlay {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(square: 76)
                    .foregroundStyle(.thinMaterial)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isLoading ? 1 : 0.9)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: isLoading)
            }
            .opacity(isLoading ? 1 : 0)
        }
        .overlay {
            Image(systemName: "chevron.compact.up")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .phaseAnimator([true, false]) { view, phase in
                    view
                        .offset(y: phase ? -24 : 0)
                        .opacity(phase ? 1 : 0.75)
                } animation: { _ in
                        .smooth(duration: 0.5)
                }
                .offset(
                    x: -67,
                    y: height * 0.2
                )
                .opacity(showChevron ? 1 : 0)
        }
//        .sheet(isPresented: .constant(true)) {
        .sheet(isPresented: $showErrorSheet) {
            ErrorSheet()
                .presentationDetents([.medium])
                .preferredColorScheme(.light)
                .interactiveDismissDisabled()
        }
        .preferredColorScheme(.light)
        .onAppear(perform: setup)
    }
    
    @ViewBuilder
    private func ErrorSheet() -> some View {
        VStack(spacing: 32) {
//            HStack(spacing: 14) {
            ZStack {
                Circle()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(Color(hex: 0x181818))
                    .overlay {
                        Image("logo-256w")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    }
                    .rotationEffect(.degrees(roll ? -360 : 0))
                    .offset(x: roll ? -100 : 0)
                
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 25, height: 4)
                        .foregroundStyle(.secondary.opacity(0.15))
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.red)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 25, height: 4)
                        .foregroundStyle(.secondary.opacity(0.15))
                }
                .scaleEffect(roll ? 1 : 0.5)
                
                Circle()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(.indigo)
                    .overlay {
                        Image(systemName: "hourglass")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                    .background {
                        Circle()
                            .frame(width: 78, height: 78)
                            .foregroundStyle(.background)
                    }
                    .rotationEffect(.degrees(roll ? 360 : 0))
                    .offset(x: roll ? 100 : 0)
            }
            
            VStack(spacing: 14) {
                Text("Connection Failed")
                    .font(.title.weight(.bold))
                
                Text("BLOCKR needs Screen Time access to block distractions. Without it, the app won’t work as intended.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .font(.subheadline.weight(.medium))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 18) {
                
                Button {
                    // ...
                } label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(height: 50)
                        .foregroundStyle(Color.secondary.opacity(0.25))
                        .overlay {
                            Text("Help")
                                .font(.system(size: 18.5).weight(.semibold))
                                .foregroundStyle(Color.secondary)
                        }
                }
                
                Button {
                    showErrorSheet = false
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(height: 50)
                        .overlay {
                            Text("Try Again")
                                .font(.system(size: 18.5).weight(.semibold))
                                .foregroundStyle(.white)
                        }
                }

            }
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
        }
        .onAppear {
            SleepTask.sleep(seconds: 0.25) {
                withAnimation {
                    roll = true
                }
            }
            
            Haptics.errorFeedback()
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35, extraBounce: 0.15)) {
                steps[0] = true
            }
        }
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 1_700_000_000)
                Haptics.feedback(style: .rigid)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        SleepTask.sleep(seconds: 1.65) {
            withAnimation(.smooth(duration: 0.45)) {
                steps[0] = false
                steps[1] = true
            }
        }

        SleepTask.sleep(seconds: 1.70) {
            withAnimation(.smooth(duration: 0.45)) {
                steps[2] = true
            }
        }
        
        SleepTask.sleep(seconds: 1.75) {
            withAnimation(.smooth(duration: 0.45)) {
                steps[3] = true
            }
        }

    }
    
    private func setLoading(_ value: Bool) {
        withAnimation(.smooth(duration: 0.25)) {
            isLoading = value
        }
    }
    
    private func action() {
        Haptics.feedback(style: .light)
        
        setLoading(true)
        
        SleepTask.sleep(seconds: 1.55) {
            withAnimation(.smooth(duration: 0.35)) {
                showChevron = true
            }
        }
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                
                DispatchQueue.main.async {
                    setLoading(false)
                    withAnimation(.smooth(duration: 0.35)) {
                        showChevron = false
                    }
                    
                    dismiss()
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    setLoading(false)
                    withAnimation(.smooth(duration: 0.35)) {
                        showChevron = false
                    }
                    showErrorSheet = true
                }
            }
        }
    }
}

#Preview {
    OBQuizFamilyAuth()
}

#Preview {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            OBQuizFamilyAuth()
                .presentationDragIndicator(.visible)
        }
}
