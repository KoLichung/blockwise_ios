//
//  WasThisHelpfulButtons.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/02/26.
//

import SwiftUI

struct WasThisHelpfulButtons: View {
    let context: String
    
    @AppStorage("feedbackAnswered") private var answeredContexts: String = ""
    
    @State private var showFeedbackAlert = false
    @State private var feedbackText = ""
    @State private var isVisible = true
    
    private let opacity: CGFloat = 0.15
    private let cRadius: CGFloat = 18
    private let aspectRatio: CGFloat = 1.2
    
    var body: some View {
        VStack(spacing: 32) {
            Rectangle()
                .frame(width: 128, height: 2.0)
                .foregroundStyle(.secondary.opacity(0.15))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Was this helpful?")
                    .font(.grotesk(.title2, weight: .semibold))
                    .foregroundStyle(.textC)
                
                if isVisible {
                    HStack(spacing: 24) {
                        Button {
                            wasNotHelpful()
                        } label: {
                            RoundedRectangle(cornerRadius: cRadius, style: .continuous)
                                .foregroundStyle(.secondary.opacity(opacity))
                                .aspectRatio(aspectRatio, contentMode: .fit)
                                .overlay {
                                    VStack(spacing: 14) {
                                        Text("👎")
                                            .font(.system(size: 32))
                                        
                                        Text("No")
                                            .font(.grotesk(.title3, weight: .semibold))
                                            .foregroundStyle(.textC)
                                    }
                                }
                        }
                        
                        Button {
                            wasHelpful()
                        } label: {
                            RoundedRectangle(cornerRadius: cRadius, style: .continuous)
                                .foregroundStyle(.secondary.opacity(opacity))
                                .aspectRatio(aspectRatio, contentMode: .fit)
                                .overlay {
                                    VStack(spacing: 14) {
                                        Text("👍")
                                            .font(.system(size: 32))
                                        
                                        Text("Yes")
                                            .font(.grotesk(.title3, weight: .semibold))
                                            .foregroundStyle(.textC)
                                    }
                                }
                        }
                    }
                    .tint(.primary)
                } else {
                    HStack(spacing: 10) {
                        HStack(spacing: 10) {
                            let checkSize: CGFloat = 32.0
                            
                            CheckmarkShape(trimEnd: 1.0)
                                .trim(from: 0.0, to: 1.0)
                                .stroke(
                                    .secondary,
                                    style: StrokeStyle(
                                        lineWidth: checkSize / 12,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(square: checkSize / 2.0)
                            
                            Text("Feedback sent!")
                                .foregroundStyle(.secondary)
                                .font(.grotesk(.body, weight: .semibold))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.smooth, value: isVisible)
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 32)
            }
        }
        .alert("Tell us more", isPresented: $showFeedbackAlert) {
            TextField("What could be better?", text: $feedbackText)
            
            Button("Cancel", role: .cancel) {
                feedbackText = ""
            }
            
            Button("Send") {
                sendNegativeFeedback()
            }
        } message: {
            Text("Help us improve by sharing what went wrong")
        }
        .onAppear {
            checkIfAlreadyAnswered()
        }
    }
    
    private func checkIfAlreadyAnswered() {
        let answered = answeredContexts.split(separator: ",").map(String.init)
        if answered.contains(context) {
            isVisible = false
        }
    }
    
    private func markAsAnswered() {
        let answered = answeredContexts.split(separator: ",").map(String.init)
        if !answered.contains(context) {
            if answeredContexts.isEmpty {
                answeredContexts = context
            } else {
                answeredContexts += ",\(context)"
            }
        }
        
        withAnimation {
            isVisible = false
        }
    }
    
    private func wasHelpful() {
        markAsAnswered()
    }
    
    private func wasNotHelpful() {
        showFeedbackAlert = true
    }
    
    private func sendNegativeFeedback() {
        feedbackText = ""
        markAsAnswered()
    }
}

#Preview {
    WasThisHelpfulButtons(context: "What is XYZ?")
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
}
