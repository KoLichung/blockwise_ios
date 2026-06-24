//
//  FamilySelectionView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/02/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct FamilySelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var toastManager: ToastManager
    
    @FetchRequest(sortDescriptors: [])
    private var blocks: FetchedResults<BlockEntity>
    
    @State private var existingTokens = Set<String>() // Use Set for O(1) lookup
    @State private var selection = FamilyActivitySelection(includeEntireCategory: true)
    
    var selectionCount: Int {
        selection.applicationTokens.count
    }
    
    var selectionLimit: Int = 1
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FamilyActivityPicker(
                    headerText: "",
                    footerText: "Tap “>“ to expand a category",
                    selection: $selection
                )
                .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 24) {
                    GlassButton("Done") {
                        #if targetEnvironment(simulator)
                        dismiss()
                        #else
                        action()
                        #endif
                    }
                    
                    Text("Choose 1 distracting app to block")
                        .font(.grotesk(.subheadline, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            .navigationTitle("Choose an App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        // Use Set for O(1) lookup instead of array with O(n) lookup
        existingTokens = Set(blocks.compactMap { $0.appTokenString })
    }
    
    private func action() {
        // Check if selection is empty
        guard selectionCount > 0 else {
            alertTitle = "Choose an app"
            alertMessage = "To choose an app, open the drop down menu of one of the categories and select an app"
            showAlert = true
            return
        }

        // Check if selection exceeds limit
        guard selectionCount == selectionLimit else {
            alertTitle = "Please choose only 1 app"
            alertMessage = "You'll have the opportunity to add more app limits later"
            showAlert = true
            return
        }
        
        // Safely get the selected app token
        guard let selectedToken = selection.applicationTokens.first else {
            alertTitle = "Error"
            alertMessage = "Unable to get the selected app. Please try again."
            showAlert = true
            return
        }
        
        // Get it's string value for lookup
        guard let tokenString = selectedToken.string else {
            alertTitle = "Error"
            alertMessage = "Unable to get the selected app (string). Please try again."
            showAlert = true
            return
        }
        
        // Check if the selected app is already blocked
        if existingTokens.contains(tokenString) {
            alertTitle = "Already blocked"
            alertMessage = "This app is already in your block list. Please choose a different app."
            showAlert = true
            return
        }
        
        do {
            try CoreDataStack.shared.createBlock(appToken: selectedToken)
        } catch {
            toastManager.error(error.localizedDescription)
        }
        
        toastManager.info("New app blocked")

        dismiss()
    }
}

#Preview {
    FamilySelectionView()
        .environmentObject(ToastManager())
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            FamilySelectionView()
                .environmentObject(ToastManager())
        }
}
