//
//  OBQuizSymptom.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/07/25.
//

import SwiftUI
import Lottie

struct OBQuizSymptom: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    let background: Color = Color(hex: 0x200107)
    
    @State private var selectedOptions: [OBOption] = []

    var body: some View {
        VStack(spacing: 0) {
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
                                    .font(.grotesk(.subheadline, weight: .medium))
//                                    .font(.subheadline.weight(.medium))
                                    .lineSpacing(4.0)
                                    .foregroundStyle(Color.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    
                    Text("Select all symptoms that apply:")
//                        .font(.subheadline.weight(.medium))
                        .font(.grotesk(.subheadline, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text("🧠 Mental")
//                                .font(.title2.weight(.semibold))
                                .font(.grotesk(.title2, weight: .semibold))
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
                                                .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color.pink.opacity(0.15))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .stroke(lineWidth: 2.0)
                                                        .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.0))
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
//                                .font(.title2.weight(.semibold))
                                .font(.grotesk(.title2, weight: .semibold))
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
                                                .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color.pink.opacity(0.15))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .stroke(lineWidth: 2.0)
                                                        .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.0))
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
//                                .font(.title2.weight(.semibold))
                                .font(.grotesk(.title2, weight: .semibold))
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
                                                .foregroundStyle(isSelected ? Color.pink.opacity(0.1) : Color.pink.opacity(0.15))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .stroke(lineWidth: 2.0)
                                                        .foregroundStyle(isSelected ? Color.pink : Color.secondary.opacity(0.0))
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            if !selectedOptions.isEmpty {
                GlassButton("Continue") {
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
        .background(background, ignoresSafeAreaEdges: .all)
        .navigationBarTitleDisplayMode(.large)
//        .toolbar(edge: .center) {
//            Text("Select symptoms")
//                .font(.grotesk(.body, weight: .semibold))
//        }
        .navigationTitle("Symptoms")
    }
    
    private func action() {
        // Check selection

        // Call MixPanel
        
        // Update UserViewModel

        // Continue
        vm.nextStep()
        
        vm.mixPanelTrack(name: "Quiz Symptom")
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

}

#Preview {
    NavigationStack {
        OBQuizSymptom()
            .environmentObject(OBUserViewModel())
    }
}
