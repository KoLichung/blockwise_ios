//
//  OBEightView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct OBEightView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOptions: [OBOption] = []
    
    let question = "What triggers you to check your phone?"
    let subtitle = "Question #8"
    
    let options: [OBOption] = [
        OBOption(emoji: "😐", label: "Boredom", value: 2),
        OBOption(emoji: "📚", label: "Work/study", value: 5),
        OBOption(emoji: "⏰", label: "Habit", value: 4),
        OBOption(emoji: "😔", label: "Fear of missing out", value: 3)
    ]

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 14) {
//                Text(subtitle.uppercased())
//                    .font(.footnote.weight(.semibold))
//                    .foregroundStyle(.secondary)
//                    .kerning(1.0)
                
                Text(question)
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 14) {
                ForEach(options, id: \.self) { option in
                    let isSelected = isSelected(option)
                    
                    Button {
                        Haptics.feedback(style: .light)
                        
                        withAnimation(.snappy(duration: 0.25)) {
                            addRemove(option)
                        }
                        
                    } label: {
                        VStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 140, style: .continuous)
                                .frame(height: 55)
                                .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                .background {
                                    RoundedRectangle(cornerRadius: 140, style: .continuous)
                                        .frame(height: 55)
                                        .opacity(isSelected ? 1.0 : 0.0)
                                }
                                .overlay {
                                    HStack(spacing: 12) {
                                        if option.emoji != "" {
                                            Text(option.emoji)
                                                .font(.title2)
                                        }
                                        
                                        Text(option.label)
                                            .font(.headline)
                                            .foregroundStyle(isSelected ? Color(UIColor.systemBackground) : Color.primary)
                                    }
                                    .padding(.horizontal, 22)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .overlay(alignment: .trailing) {
                                    Checkmark(
                                        size: 22,
                                        trigger: .isPresent(
                                            in: $selectedOptions,
                                            element: option
                                        ),
                                        checkmarkColor: .white,
                                        backgroundColor: Color.secondaryOrange
                                    )
                                    .padding(.trailing, 22)
                                }
                        }
                    }
                }
            }
        }
        .tint(.primary)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: 32)
        .safeAreaInset(edge: .bottom) {
            Button("Continue") {
                action()
            }
            .foregroundStyle(
                selectedOptions.isEmpty ? Color.gray : Color.secondaryOrange
            )
            .padding(.horizontal)
        }
        .padding()
        .overlay(alignment: .top) {
            Image("ob-bg")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .offset(y: -164)
        }
        .background {
            Color.primaryOrange.opacity(0.1)
                .ignoresSafeArea()
        }

    }
    
    private func action() {
        // Check selection
        guard !selectedOptions.isEmpty else { return }

        // Call MixPanel
        
        // Update UserViewModel
        for option in selectedOptions {
            vm.selections.append(option.value)
        }

        // Continue
        vm.goToNextStep(step: 9)
    }
    
    private func isSelected(_ option: OBOption) -> Bool {
        selectedOptions.firstIndex(where: { $0 == option }) != nil
    }
    
    private func addRemove(_ option: OBOption) {
        if let index = selectedOptions.firstIndex(where: { $0 == option }) {
            selectedOptions.remove(at: index)
        } else {
            selectedOptions.append(option)
        }
    }

}

#Preview {
    NavigationStack {
        OBEightView()
            .environmentObject(OBUserViewModel())
    }
}
