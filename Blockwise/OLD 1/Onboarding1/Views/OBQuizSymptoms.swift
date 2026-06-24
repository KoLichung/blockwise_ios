//
//  OBQuizSymptoms.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/06/25.
//

import SwiftUI
import Lottie

struct OBQuizSymptoms: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    let background: Color = Color(hex: 0x200107)
    
    @State private var selectedOptions: [OBOption] = []
    
    let mentalSymptoms: [OBOption] = [
        OBOption(emoji: "", label: "Anxiety", value: 2),
        OBOption(emoji: "", label: "Poor memory", value: 5),
        OBOption(emoji: "", label: "Low self-esteem", value: 4),
        OBOption(emoji: "", label: "Difficulty concentrating", value: 3),
    ]
    
    let physicalSymptoms: [OBOption] = [
        OBOption(emoji: "", label: "Frequent headaches", value: 2),
        OBOption(emoji: "", label: "Low energy", value: 5),
        OBOption(emoji: "", label: "Poor sleep", value: 4),
        OBOption(emoji: "", label: "Constant tiredness", value: 3),
    ]
    
    let otherSymptoms: [OBOption] = [
        OBOption(emoji: "", label: "None of the above", value: 0)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .frame(height: 80)
                    .foregroundStyle(Color.pink.opacity(0.15))
                    .overlay {
                        HStack(spacing: 14) {
                            LottieView(animation: .named("police-car-light"))
                                .looping()
                                .frame(square: 48)
                            
                            Text("Stress and bad habits can create lasting negative effects.")
                                .font(.subheadline.weight(.medium))
                                .lineSpacing(4.0)
                                .foregroundStyle(Color.pink)
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
                        Text("🧠 Mental")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        VStack(spacing: 14) {
                            ForEach(mentalSymptoms, id: \.self) { option in
                                let isSelected = isSelected(option)
                                
                                Button {
                                    Haptics.feedback(style: .light)
                                    
                                    withAnimation(.snappy(duration: 0.25)) {
                                        addRemove(option)
                                    }
                                    
                                } label: {
                                    VStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(lineWidth: 2.0)
                                                    .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.15))
                                            }
                                            .frame(height: 60)
                                            .overlay {
                                                Text(option.label)
                                                    .font(.headline)
                                                    .padding(.horizontal, 22)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .overlay(alignment: .trailing) {
                                                Checkmark(
                                                    size: 24,
                                                    trigger: .isPresent(
                                                        in: $selectedOptions,
                                                        element: option
                                                    ),
                                                    checkmarkColor: .white,
                                                    backgroundColor: .pink
                                                )
                                                .padding(.trailing, 22)
                                            }
                                    }
                                }
                            }
                        }
                    }
                        
                    VStack(spacing: 16) {
                        Text("💪 Physical")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        VStack(spacing: 14) {
                            ForEach(physicalSymptoms, id: \.self) { option in
                                let isSelected = isSelected(option)
                                
                                Button {
                                    Haptics.feedback(style: .light)
                                    
                                    withAnimation(.snappy(duration: 0.25)) {
                                        addRemove(option)
                                    }
                                    
                                } label: {
                                    VStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(lineWidth: 2.0)
                                                    .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.15))
                                            }
                                            .frame(height: 60)
                                            .overlay {
                                                Text(option.label)
                                                    .font(.headline)
                                                    .padding(.horizontal, 22)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .overlay(alignment: .trailing) {
                                                Checkmark(
                                                    size: 24,
                                                    trigger: .isPresent(
                                                        in: $selectedOptions,
                                                        element: option
                                                    ),
                                                    checkmarkColor: .white,
                                                    backgroundColor: .pink
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
                            ForEach(otherSymptoms, id: \.self) { option in
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
                                            .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(lineWidth: 2.0)
                                                    .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.15))
                                            }
                                            .frame(height: 60)
                                            .overlay {
                                                Text(option.label)
                                                    .font(.headline)
                                                    .padding(.horizontal, 22)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .overlay(alignment: .trailing) {
                                                Checkmark(
                                                    size: 24,
                                                    trigger: .isPresent(
                                                        in: $selectedOptions,
                                                        element: option
                                                    ),
                                                    checkmarkColor: .white,
                                                    backgroundColor: .pink
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
                Button("Continue") {
                    action()
                }
                .foregroundStyle(.pink)
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
        .navigationTitle("Symptoms")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func action() {
        // Check selection

        // Call MixPanel
        
        // Update UserViewModel

        // Continue
        vm.nextStep()
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
        OBQuizSymptoms()
            .environmentObject(OBUserViewModel())
    }
}
