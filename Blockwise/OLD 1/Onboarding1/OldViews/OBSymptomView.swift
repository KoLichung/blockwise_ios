//
//  OBSymptomView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI
import Lottie

struct OBSymptomView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var selectedOptions: [OBOption] = []
    
    let question = "Symptoms"
    let subtitle = "Question #2"
    
    let options1: [OBOption] = [
        OBOption(emoji: "", label: "Feeling unmotivated", value: 2),
        OBOption(emoji: "", label: "Lack of ambition", value: 5),
        OBOption(emoji: "", label: "Poor memory", value: 4),
        OBOption(emoji: "", label: "Difficulty concentrating", value: 3),
    ]
    
    let options2: [OBOption] = [
        OBOption(emoji: "", label: "Frequent headaches", value: 2),
        OBOption(emoji: "", label: "Low energy", value: 5),
        OBOption(emoji: "", label: "Poor sleep", value: 4),
        OBOption(emoji: "", label: "Constant tiredness", value: 3),
    ]
    
    let options3: [OBOption] = [
        OBOption(emoji: "", label: "None of the above", value: 0)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(height: 80)
                    .foregroundStyle(.red)
                    .opacity(0.25)
                    .overlay {
                        HStack(spacing: 14) {
                            LottieView(animation: .named("police-car-light"))
                                .looping()
                                .frame(square: 48)
                            
                            Text("Stress and bad habits can create lasting negative effects.")
                                .font(.subheadline.weight(.medium))
                                .lineSpacing(2.0)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                
                Text("Select any symptoms below:")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Mental")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        VStack(spacing: 14) {
                            ForEach(options1, id: \.self) { option in
                                let isSelected = isSelected(option)
                                
                                Button {
                                    Haptics.feedback(style: .light)
                                    
                                    withAnimation(.snappy(duration: 0.25)) {
                                        addRemove(option)
                                    }
                                    
                                } label: {
                                    VStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .frame(height: 55)
                                            .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                            .background {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
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
                                                    backgroundColor: .black
                                                )
                                                .padding(.trailing, 22)
                                            }
                                    }
                                }
                            }
                        }
                    }
                        
                    VStack(spacing: 16) {
                        Text("Physical")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        VStack(spacing: 14) {
                            ForEach(options2, id: \.self) { option in
                                let isSelected = isSelected(option)
                                
                                Button {
                                    Haptics.feedback(style: .light)
                                    
                                    withAnimation(.snappy(duration: 0.25)) {
                                        addRemove(option)
                                    }
                                    
                                } label: {
                                    VStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .frame(height: 55)
                                            .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                            .background {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
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
                                                    backgroundColor: .black
                                                )
                                                .padding(.trailing, 22)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("More")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        VStack(spacing: 14) {
                            ForEach(options3, id: \.self) { option in
                                let isSelected = isSelected(option)
                                
                                Button {
                                    Haptics.feedback(style: .light)
                                    
                                    if selectedOptions.contains(option) {
                                        withAnimation(.snappy(duration: 0.25)) {
                                            selectedOptions = []
                                        }
                                    } else {
                                        withAnimation(.snappy(duration: 0.25)) {
                                            selectedOptions = [option]
                                        }
                                    }
                                    
                                } label: {
                                    VStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .frame(height: 55)
                                            .foregroundStyle(.thinMaterial.opacity(isSelected ? 0.0 : 1.0))
                                            .background {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
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
                                                    backgroundColor: .black
                                                )
                                                .padding(.trailing, 22)
                                            }
                                    }
                                }
                                .onChange(of: selectedOptions) {
                                    if selectedOptions.contains(option) && selectedOptions.count > 1 {
                                        addRemove(option)
                                    }
                                }
                            }
                        }
                    }

                }
            }
            .tint(.primary)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            if !selectedOptions.isEmpty {
                Button {
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .frame(height: 60)
                        .overlay {
                            Text("Continue")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.background)
                        }
                }
                .padding(.horizontal)
                .padding()
                .background {
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                        .ignoresSafeArea()
                        .overlay(alignment: .top) {
                            Rectangle()
                                .foregroundStyle(.secondary.opacity(0.1))
                                .frame(height: 1.5)
                        }
                }
                .transition(
                    .asymmetric(
                        insertion: .push(from: .bottom),
                        removal: .push(from: .top)
                    )
                )
            }
        }
//        .background {
//            Circle()
//                .foregroundStyle(
//                    .linearGradient(
//                        colors: [.red, .pink],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .opacity(0.25)
//                .blur(radius: 144)
//                .padding()
//        }
        .navigationTitle("Symptoms")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func action() {
        // Check selection

        // Call MixPanel
        
        // Update UserViewModel

        // Continue
        vm.goToNextStep(step: 16)
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
        OBSymptomView()
            .environmentObject(OBUserViewModel())
    }
}
