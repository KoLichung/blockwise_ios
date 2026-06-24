//
//  OBTwoView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct OBTwoView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOption: OBOption?

    let question = "How old are you?"
    let subtitle = "Question #2"

    let options: [OBOption] = [
        OBOption(emoji: "", label: "Under 18", value: 8),
        OBOption(emoji: "", label: "18-24", value: 6),
        OBOption(emoji: "", label: "25-35", value: 4),
        OBOption(emoji: "", label: "Over 35", value: 3)
    ]
    
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
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    let isSelected = isSelected(option)
                    
                    VStack(spacing: 14) {
                        Button {
                            Haptics.feedback(style: .light)
                            withAnimation(.snappy(duration: 0.25)) {
                                selectedOption = option
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
                            }
                        }
                        
//                        if selectedOption == option {
//                            Text(descriptions[index])
//                                .font(.footnote)
//                                .multilineTextAlignment(.leading)
//                                .foregroundStyle(.secondary)
//                                .frame(height: 22, alignment: .top)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal)
//                        }
                        
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
                selectedOption == nil ? Color.gray : Color.secondaryOrange
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
        guard let selectedOption else { return }

        // Call MixPanel
        
        // Update UserViewModel
        vm.selections.append(selectedOption.value)
        
        // Continue
        vm.goToNextStep(step: 3)
    }
    
    private func isSelected(_ option: OBOption) -> Bool {
        selectedOption == option
    }
}

#Preview {
    OBTwoView()
        .environmentObject(OBUserViewModel())
}
