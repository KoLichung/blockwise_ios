//
//  EditAppSelection.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/02/26.
//

import SwiftUI
import FamilyControls

struct EditAppSelection: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    var selectionCount: Int {
        selection.applicationTokens.count
    }
    
    @State private var selection = FamilyActivitySelection(includeEntireCategory: true)
    
    var selectionLimit: Int = 49
    
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
                    
                    Text("Choose up to 49 apps • \(selectionCount) selected")
                        .font(.grotesk(.subheadline, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            .navigationTitle("Block List")
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
        selection = scheduleViewModel.familySelection
    }
    
    private func action() {
        // Check if selection is empty
        guard selectionCount > 0 else {
            alertTitle = "Choose at least one app"
            alertMessage = "To choose an app, open the drop down menu of one of the categories and select an app"
            showAlert = true
            return
        }
        
        // Check if selection exceeds limit
        guard selectionCount <= selectionLimit else {
            alertTitle = "You can only select up to 49 apps"
            alertMessage = "Please remove \(selectionCount - selectionLimit) apps from your selection to continue"
            showAlert = true
            return
        }
        
        // Save to userDefaults
        // Coredata only keeps the key
        UserDefaultsManager.shared.set(selection, forKey: scheduleViewModel.schedule?.selectionKey ?? "")
        scheduleViewModel.familySelection = selection
        
        scheduleViewModel.showBlocks = false
    }
}

#Preview {
    EditAppSelection()
        .environmentObject(ScheduleViewModel())
        .environmentObject(ToastManager())
}
