//
//  OBFamilySelection_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/01/26.
//

import SwiftUI
import FamilyControls

struct OBFamilySelection_V2: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: OBTVM_V2
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var selectionCount: Int {
        vm.selection.applicationTokens.count
    }
    
    var selectionLimit: Int = 1
    
    var completion: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FamilyActivityPicker(
                    headerText: "",
                    footerText: "Tap “>“ to expand a category",
                    selection: $vm.selection
                )
                
                VStack(alignment: .center, spacing: 24) {
                    GlassButton("Done") {
                        #if targetEnvironment(simulator)
                        dismiss()
                        completion()
                        #else
                        action()
                        #endif
                    }
                    .grayscale(selectionCount == selectionLimit ? 0 : 1)
                    
                    Text("Choose 1 distracting app. You can always add more later.")
                        .font(.grotesk(.subheadline, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func action() {
        guard selectionCount > 0 else {
            alertTitle = "Choose an app"
            alertMessage = "To choose an app, open the drop down menu of one of the categories and select an app"
            showAlert = true
            return
        }
        
        guard selectionCount == selectionLimit else {
            alertTitle = "Please choose only 1 app"
            alertMessage = "You'll have the opportunity to add more app limits later"
            showAlert = true
            return
        }
        
        dismiss()
        completion()
    }
}

#Preview {
    OBFamilySelection_V2 {
        
    }
    .environmentObject(OBTVM_V2())
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            OBFamilySelection_V2 {
                
            }
            .environmentObject(OBTVM_V2())
        }
}
