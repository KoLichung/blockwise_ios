//
//  CreateBlockTwoView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/08/25.
//

import SwiftUI
import Lottie
import FamilyControls

struct CreateBlockTwoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AddBlockUserViewModel
    @EnvironmentObject var toastManager: ToastManager

    var body: some View {
        VStack(spacing: 56) {
            
            VStack(spacing: 56) {
                HStack(spacing: 32) {
                    
                    if let appToken = vm.familyActivitySelection.applicationTokens.first {
                        VStack(spacing: 8) {
                            Label(appToken)
                                .labelStyle(.iconOnly)
                                .scaleEffect(3.0)
                                .frame(square: 56)
                            
//                            Label(appToken)
//                                .labelStyle(.titleOnly)
//                                .scaleEffect(0.8)
                        }
                    }
                    
                }
                
                Text("Do you want to restrict access to this app?")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                                
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.primaryBlue)
                        .offset(y: 1)

                    Text("We'll blur this app on your Home Screen and let you control how much time you spend on it.")
                        .font(.grotesk(.body, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.primaryBlue)
                        .lineSpacing(4.0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Theme.foregroundC, in: .rect(cornerRadius: 18, style: .continuous))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton {
                    action()
                } label: {
                    HStack(spacing: 10) {
                        let checkSize: CGFloat = 36.0
                        
                        CheckmarkShape(trimEnd: 1.0)
                            .trim(from: 0.0, to: 1.0)
                            .stroke(
                                .white,
                                style: StrokeStyle(
                                    lineWidth: checkSize / 14,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(square: checkSize / 2.0)
                        
                        Text("Confirm")
                    }
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                }
                
                Button("No, switch app") {
                    dismiss()
                    Haptics.feedback(style: .rigid)
                }
                .font(.grotesk(.body, weight: .medium))
                .opacity(0.65)
            }
        }
        .padding(32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
//        .toolbar(edge: .trailing) {
//            if let dismiss = vm.dismiss {
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                }
//            }
//        }
    }
    
    private func action() {
        do {
            try vm.createBlock()
            if let dismiss = vm.dismiss {
                dismiss()
            }
            toastManager.info("Block applied.")
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        CreateBlockTwoView()
            .environmentObject(AddBlockUserViewModel())
            .environmentObject(ToastManager())
    }
}
