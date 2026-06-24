//
//  OBWidget.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/01/26.
//

import SwiftUI

enum OBWidgetStep: Int, CaseIterable {
    case one, two, three
    
    var title: String {
        switch self {
        case .one: return "Step 1"
        case .two: return "Step 2"
        case .three: return "Step 3"
        }
    }
}

struct OBWidget: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: OBWidgetStep = .one
    @State private var showSteps: Bool = false
    
    var buttonLabel: String {
        guard showSteps else {
            return "Add Widget"
        }
        
        switch currentStep {
        case .one: return "Next"
        case .two: return "Next"
        case .three: return "Done"
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Group {
                if showSteps {
                    Text(currentStep.title)
                        .font(.grotesk(.title3, weight: .semibold))
                        .contentTransition(.numericText())
                        .offset(y: 32)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .trailing).combined(with: .offset(x: -16)))
                } else {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Add the Widget")
                            .font(.grotesk(.title, weight: .semibold))
                    }
                    .offset(y: 18)
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .leading).combined(with: .offset(x: 16)))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .background(.background, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton(buttonLabel) {
                    advanceStep()
                }
                .contentTransition(.numericText())

                Button {
                    showSteps ? goBack() : dismiss()
                } label: {
                    Text(showSteps ? "Back" : "No thanks")
                        .font(.grotesk())
                        .contentTransition(.numericText())
                }
                .tint(Color.secondary)
            }
            .padding(.horizontal, 32)
            .padding()
        }
        .overlay(alignment: .top) {
            HStack(spacing: 10) {
                ForEach(OBWidgetStep.allCases, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .opacity(step.rawValue <= currentStep.rawValue ? 1 : 0)
                                .foregroundStyle(Color.blueAccent)
                        }
                        .frame(height: 4)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
            .padding(.horizontal)
            .opacity(showSteps ? 1 : 0)
            .offset(y: showSteps ? 0 : -32)
        }
    }
    
    // MARK: - Step Management
    private func advanceStep() {
        guard showSteps else {
            revealSteps()
            return
        }
        
        guard !isLastStep else {
            handleCompletion()
            return
        }
        
        moveToNextStep()
    }
    
    private func goBack() {
        guard isFirstStep else {
            moveToPreviousStep()
            return
        }
        
        resetToInitialState()
    }

    // MARK: - UI State
    private func revealSteps() {
        withAnimation {
            showSteps = true
        }
    }
    
    private func resetToInitialState() {
        withAnimation {
            showSteps = false
            currentStep = .one
        }
    }

    // MARK: - Step Navigation
    private func moveToNextStep() {
        guard let nextStep = OBWidgetStep(rawValue: currentStep.rawValue + 1) else { return }
        
        withAnimation {
            currentStep = nextStep
        }
    }
    
    private func moveToPreviousStep() {
        guard let previousStep = OBWidgetStep(rawValue: currentStep.rawValue - 1) else { return }
        
        withAnimation {
            currentStep = previousStep
        }
    }

    // MARK: - Step Validation
    private var isLastStep: Bool {
        currentStep.rawValue == OBWidgetStep.allCases.count - 1
    }
    
    private var isFirstStep: Bool {
        currentStep.rawValue == 0
    }

    // MARK: - Completion
    private func handleCompletion() {
        // Called when all steps are completed
        print("Onboarding completed!")
        dismiss()
    }
}

#Preview {
    OBWidget()
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            OBWidget()
                .presentationDetents([.height(600)])
        }
}

