//
//  OBQuizName.swift
//  Blockwise
//
//  Created by Ivan Sanna on 25/06/25.
//

import SwiftUI

struct OBQuizName: View {
    @EnvironmentObject var vm: OBUserViewModel
        
    let questionNumber: Int = 10
    let question: String = "What's your name?"
    
    let color1: Color = Color.primaryBlue
    let color2: Color = Color.primaryOrange
    
    @FocusState private var isNameFocused: Bool
    @State private var name: String = ""
    private let characterLimit = 20

    // Computed property to check if name is valid
    private var isNameValid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    @State private var warning: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Space(height: 20)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Final Question".uppercased())
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(color1)
                        .kerning(1.0)

                    Text(question)
                        .font(.system(size: 30, weight: .semibold))
                        .lineSpacing(2.0)
                }

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
                            .frame(height: 64)
                            .foregroundStyle(Theme.foregroundC)
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
            .foregroundStyle(Color.accentBlue)
            .offset(y: !isNameValid ? 128 : 0)
            .opacity(!isNameValid ? 0 : 1)
            .animation(.smooth(duration: 0.25), value: isNameValid)

//            Button("Done") {
//                action()
//            }
//            .padding(.horizontal, 32)
//            .padding(.vertical)
//            .foregroundStyle(isNameValid ? color1 : Color.gray)
        }
        .scrollDisabled(true)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        #if targetEnvironment(simulator)
        name = "Test User"
        #endif
        
        SleepTask.sleep(seconds: 0.02) {
            isNameFocused = true
        }
    }
    
    private func action() {
        guard isNameValid else {
            Haptics.warningFeedback()
            warning.toggle()
            return
        }
        
        vm.nextStep()
        vm.hideTabbar = true
        // Trim whitespace before saving
        vm.username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        vm.mixPanelTrack(name: "Quiz 11 - Name")
    }
    
}

#Preview {
    OBQuizName()
}
