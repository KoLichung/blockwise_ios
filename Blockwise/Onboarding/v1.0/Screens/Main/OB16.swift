//
//  OB16.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OB16: View {
    @EnvironmentObject var vm: OBVM
        
    let question: String = "How can we call you?"
        
    @FocusState private var isNameFocused: Bool
    @State private var name: String = ""
    private let characterLimit = 20

    // Computed property to check if name is valid
    private var isNameValid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    @State private var warning: Bool = false
    
    @State private var appearAnimation: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Space(height: 20)
                
                VStack(alignment: .leading, spacing: 14) {

                    Text(question)
                        .font(.grotesk(size: 26, weight: .semibold))
                        .padding(.trailing)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)

                VStack(spacing: 14) {
                    TextField(text: $name) {
                        Text("First Name")
                            .fontWeight(.medium)
                    }
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                    .focused($isNameFocused)
                    .onChange(of: name) {
                        if name.count > characterLimit {
                            name = String(name.prefix(characterLimit))
                        }
                    }
                    .padding(.horizontal, 22)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(lineWidth: 2.0)
                            .frame(height: 64)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .frame(height: 64)
                                    .phaseAnimator([false, true], trigger: warning) { view, phase in
                                        view
                                            .foregroundStyle(phase ? Color.red.opacity(0.5) : Color.white.opacity(0.0))
                                    } animation: { _ in
                                            .smooth
                                    }

                            }
                    }
                    .overlay(alignment: .trailing) {
                        Button {
                            name = ""
                            Haptics.feedback(style: .soft)
                        } label: {
                            Image(systemName: "xmark")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.secondary.opacity(0.6))
                        }
                        .padding(.horizontal, 22)
                        .opacity(name.isEmpty ? 0 : 1)
                    }
                    .padding(.vertical)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .offset(y: !isNameValid ? 128 : 0)
            .opacity(!isNameValid ? 0 : 1)
            .animation(.smooth(duration: 0.25), value: isNameValid)
        }
        .scrollDisabled(true)
        .onAppear(perform: setup)
    }
    
    private func setup() {
#if targetEnvironment(simulator)
        name = "Ivan"
#endif
        
        SleepTask.sleep(seconds: 0.02) {
            isNameFocused = true
        }

        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        guard isNameValid else {
            Haptics.warningFeedback()
            warning.toggle()
            return
        }
        
        vm.nextPage()
        
        vm.showProgressBar = false
        
        // Trim whitespace before saving
        vm.username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Name")
    }
    
}

#Preview {
    OB16()
        .environmentObject(OBVM())
}
