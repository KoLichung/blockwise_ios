//
//  FamilySchedulePicker.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct FamilySchedulePicker: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: CreateScheduleViewModel
    @EnvironmentObject var toastManager: ToastManager
        
    var selectionCount: Int {
        vm.familySelection.applicationTokens.count
    }
    
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
                    selection: $vm.familySelection
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
        guard selectionCount <= selectionLimit else {
            alertTitle = "You can only select up to 49 apps"
            alertMessage = "Please remove \(selectionCount - selectionLimit) apps from your selection to continue"
            showAlert = true
            return
        }
        
        dismiss()
    }
}

#Preview {
    FamilySchedulePicker()
        .environmentObject(ToastManager())
        .environmentObject(CreateScheduleViewModel())
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            FamilySchedulePicker()
                .environmentObject(ToastManager())
                .environmentObject(CreateScheduleViewModel())
        }
}
