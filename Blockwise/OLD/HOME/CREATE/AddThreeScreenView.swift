//
//  AddThreeScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/12/25.
//

import SwiftUI

struct AddThreeScreenView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: AddVM
    @EnvironmentObject var toastManager: ToastManager
        
    var body: some View {
        VStack(spacing: 56) {
            AppView()
            
            VStack(spacing: 14) {
                
                Text("Step 2".uppercased())
                    .font(.grotesk(.footnote, weight: .semibold))
                    .kerning(1.0)
                    .foregroundStyle(.secondary)
                
                Text("Do you want to restrict access to this app?")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.textC)
            }
                            
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                    .offset(y: 1)

                Text("We'll blur this app on your Home Screen and let you control how much time you spend on it.")
                    .font(.grotesk(.body, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.blue)
                    .lineSpacing(4.0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundStyle(.blue.opacity(0.15))
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton {
                    action()
                } label: {
                    HStack(spacing: 12) {
                        let checkSize: CGFloat = 36.0
                        
                        CheckmarkShape(trimEnd: 1.0)
                            .trim(from: 0.0, to: 1.0)
                            .stroke(
                                .white,
                                style: StrokeStyle(
                                    lineWidth: checkSize / 12,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(square: checkSize / 2.0)
                        
                        Text("Yes, Confirm")
                    }
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                }
                
                Button("No, change app") {
                    dismiss()
                    Haptics.feedback(style: .rigid)
                }
                .font(.grotesk(.body, weight: .medium))
                .opacity(0.75)
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let dismiss = vm.dismiss {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func AppView() -> some View {
        if let token = vm.familyActivitySelection.applicationTokens.first {
            Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(3.0)
                .frame(square: 56)
        }
    }
    
    private func action() {
        do {
            try vm.createBlock()
            if let dismiss = vm.dismiss {
                dismiss()
            }
            toastManager.info("Block created!")
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error("Something went wrong :(")
        }
    }
}

#Preview {
    NavigationStack {
        AddThreeScreenView()
            .environmentObject(AddVM())
            .environmentObject(ToastManager())
    }
}
