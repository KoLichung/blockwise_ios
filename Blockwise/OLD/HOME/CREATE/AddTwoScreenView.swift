//
//  AddTwoScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/12/25.
//

import Lottie
import SwiftUI
import FamilyControls
import ManagedSettings

struct AddTwoScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var fas = FamilyActivitySelection(includeEntireCategory: true)
    
    // Warnings
    @State private var isCategory: Bool = false
    @State private var isDuplicate: Bool = false
    
    // To check duplicates
    @State private var currentAppSelection: Set<ApplicationToken> = []
    
    // Load current blocks
    @FetchRequest(sortDescriptors: [])
    private var blocks: FetchedResults<BlockEntity>
    
    // Trigger action
    var completion: (FamilyActivitySelection) -> Void
    
    // Reload screen
    @State private var id: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                FamilyActivityPicker(
                    headerText: "Select 1 app, tap '>' to expand",
                    footerText: "",
                    selection: $fas
                )
                .id(id)
                .onChange(of: fas) { oldValue, newValue in
                    handleSelection(oldValue, newValue)
                }
                .ignoresSafeArea()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(Color.primary)
                }
            }
            .sheet(isPresented: $isCategory) {
                CategoryWarning()
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $isDuplicate) {
                DuplicateWarning()
                    .interactiveDismissDisabled()
            }
        }
        .onAppear(perform: setup)
    }
    
    // MARK: - Functions
    private func setup() {
        loadCurrentlyBlockedApps()
    }
    
    private func handleSelection(_ oldValue: FamilyActivitySelection, _ newValue: FamilyActivitySelection) {
                
        guard newValue.applicationTokens.count <= 1 else {
            // Category warning: Selecting category is not allowed
            isCategory = true
            Haptics.warningFeedback()
            return
        }
        
        if let app = newValue.applicationTokens.first {
            if currentAppSelection.contains(app) {
                // Show Warning: App already blocked
                isDuplicate = true
                Haptics.warningFeedback()
            } else {
                dismiss()
                completion(newValue)
                Logger.debug("NEXT PAGE: TRUE")
            }
        } else {
            Logger.error("applicationTokens.first NOT FOUND")
        }

    }

    private func loadCurrentlyBlockedApps() {
        for block in blocks {
            guard let tokenString = block.appTokenString,
                  let app = ApplicationToken.fromRawValue(tokenString)
            else {
                continue // Skip this block if token is invalid or app can't be decoded
            }

            currentAppSelection.insert(app)
        }
    }
    
    // MARK: - UI components
    @ViewBuilder
    private func CategoryWarning() -> some View {
        VStack(alignment: .center, spacing: 32) {
            LottieView(animation: .named("raised-hand"))
                .looping()
                .frame(square: 100)
            
            VStack(alignment: .center, spacing: 14) {
                Text("Please select apps individually")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textC)
                    .lineSpacing(2.0)
                
                Text("(not a category)")
                    .font(.grotesk(.title3, weight: .regular))
                    .foregroundStyle(.textC.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Okay") {
                isCategory = false
                id += 1
                fas = FamilyActivitySelection()
            }
            .foregroundStyle(Color.blueAccent)
        }
        .padding(.horizontal, 32)
        .padding(.bottom)
        .presentationDetents([.height(450)])
    }
    
    @ViewBuilder
    private func DuplicateWarning() -> some View {
        VStack(alignment: .center, spacing: 32) {
            LottieView(animation: .named("locked"))
                .looping()
                .frame(square: 100)
            
            VStack(alignment: .center, spacing: 14) {
                Text("This app is already blocked")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textC)
                    .lineSpacing(2.0)
                
                Text("(you've already handled this, boss)")
                    .font(.grotesk(.title3, weight: .regular))
                    .foregroundStyle(.textC.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Okay") {
                isDuplicate = false
                id += 1
                fas = FamilyActivitySelection()
            }
            .foregroundStyle(Color.blueAccent)
        }
        .padding(.horizontal, 32)
        .padding(.bottom)
        .presentationDetents([.height(450)])
    }
}

#Preview {
    AddTwoScreenView { activity in
        
    }
}
