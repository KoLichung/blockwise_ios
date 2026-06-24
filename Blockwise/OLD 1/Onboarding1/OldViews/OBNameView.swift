//
//  OBNameView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI

struct OBNameView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var name: String = ""
    let characterLimit = 20
    @FocusState private var isNameFocused: Bool
    
    let question = "Finally, what's your name?"
    let subtitle = "Final Step"

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 14) {
                Text(subtitle.uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text(question)
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 14) {
                TextField(text: $name) {
                    Text("First Name")
                        .fontWeight(.medium)
                }
                .focused($isNameFocused)
                .onChange(of: name) {
                    if name.count > characterLimit {
                        name = String(name.prefix(characterLimit))
                    }
                }
                .padding(.horizontal, 22)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .frame(height: 55)
                        .foregroundStyle(.thinMaterial)
                }
                .overlay(alignment: .trailing) {
                    Button {
                        name = ""
                        Haptics.feedback(style: .soft)
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                    .padding(.horizontal, 22)
                    .opacity(name.isEmpty ? 0 : 1)
                }
            }
        }
        .tint(.primary)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .frame(height: 60)
                    .opacity(name.count < 2 ? 0.35 : 1.0)
                    .overlay {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.background)
                    }
            }
            .padding(.horizontal)
        }
        .background {
            Circle()
                .foregroundStyle(
                    .linearGradient(
                        colors: [.green, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.25)
                .blur(radius: 144)
        }
        .padding()
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.05) {
            isNameFocused = true
        }
    }
    
    private func action() {
        // Check selection
        guard name.count >= 2 else { return }

        // Call MixPanel
        
        // Update UserViewModel
        vm.hideTabbar = true

        // Continue
        vm.goToNextStep(step: 11)
    }

}

#Preview {
    NavigationStack {
        OBNameView()
            .environmentObject(OBUserViewModel())
    }
}
