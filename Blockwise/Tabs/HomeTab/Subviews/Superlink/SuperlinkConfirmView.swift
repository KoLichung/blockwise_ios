//
//  SuperlinkConfirmView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI
import ManagedSettings

struct SuperlinkConfirmView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var blockViewModel: BlockViewModel
    
    @StateObject private var toastManager = ToastManager()

    @EnvironmentObject var vm: SuperlinkViewModel
    let superlink: Superlink
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 56) {
//            Space(height: 16)
            
            Text("Are these both\n\(superlink.name)?")
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.textC)
                .lineSpacing(2.0)

            HStack(spacing: 32) {
                if let tokenString = blockViewModel.block?.appTokenString, let token = ApplicationToken.fromRawValue(tokenString) {
                    Label(token)
                        .labelStyle(.iconOnly)
                        .scaleEffect(2.7)
                        .frame(square: 56)
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 28, weight: .semibold))
                
                Image(superlink.asset)
                    .resizable()
                    .scaledToFit()
                    .appIconStyle(size: 56)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 0)
            }
            
            VStack(spacing: 14) {
                
                Text("These two **must** be the same app for Superlink to work.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4.0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 18) {
                GlassButton("Yes, same app") {
                    do {
                        try superlink.canOpen()
                        action()
                    } catch {
                        alertTitle = "Something went wrong"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
                .padding(.horizontal, 32)
                
                GlassButton("No, choose again", labelColor: .primary, background: .clear) {
                    dismiss()
                }
                .padding(.horizontal, 32)
            }
        }
        .padding()
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Report", role: .cancel) {
                vm.sendReport(message: alertMessage)
                toastManager.info("Thank you for reporting!")
            }
        } message: {
            Text(alertMessage)
        }
        .toast(manager: toastManager)
    }
    
    private func action() {
        guard let block = blockViewModel.block else {
            alertTitle = "Something went wrong"
            alertMessage = "Could not find block"
            showAlert = true
            return
        }
        
        do {
            try vm.assignSuperlink(superlink, block: block)
        } catch {
            alertTitle = "Something went wrong"
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        if let dismissAll = vm.dismissAll {
            dismissAll()
        }
    }
}

#Preview {
    SuperlinkConfirmView(superlink: .apps.first!)
        .environmentObject(SuperlinkViewModel())
        .environmentObject(BlockViewModel())
        .preferredColorScheme(.light)
}
