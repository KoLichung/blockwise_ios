//
//  ActivityPickerView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/08/25.
//

import SwiftUI
import Lottie
import FamilyControls
import ManagedSettings

struct ActivityPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selection = FamilyActivitySelection(includeEntireCategory: true)
    
    @State private var isCategorySelected: Bool = false
    @State private var isBlockedAppSelected: Bool = false
    
    @FetchRequest(sortDescriptors: [])
    private var blocks: FetchedResults<BlockEntity>
        
    @State private var currentAppSelection: Set<ApplicationToken> = []
    
    @State private var refreshID: Int = 0
    @State private var showReloadButton: Bool = false
    
    var completion: (FamilyActivitySelection) -> Void
    
    var isDisabled: Bool {
        selection.applicationTokens.isEmpty ||
        !currentAppSelection.isDisjoint(with: selection.applicationTokens)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ReloadButton()
                
                FamilyActivityPicker(
                    headerText: "Select an app to block",
                    footerText: "You can only block one app at a time.",
                    selection: $selection
                )
                .id(refreshID)
                .allowsHitTesting(false)
                .onChange(of: selection) { oldValue, newValue in
                    handleSelection(oldValue, newValue)
                }
            }
            .ignoresSafeArea()
            .sheet(isPresented: $isCategorySelected) {
                VStack(alignment: .center, spacing: 32) {
                    LottieView(animation: .named("raised-hand"))
                        .looping()
                        .frame(square: 100)
                    
                    VStack(alignment: .center, spacing: 14) {
                        Text("Please select apps individually")
                            .font(.grotesk(.title, weight: .semibold))
                            .multilineTextAlignment(.center)
                        
                        Text("(not a category)")
                            .font(.grotesk(.title3, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    GlassButton("Go back") {
                        isCategorySelected = false
                        refreshID += 1
                        selection = FamilyActivitySelection()
                        resetReloadButton()
                    }
                    .foregroundStyle(Color.accentBlue)
                }
                .padding([.horizontal, .bottom], 32)
                .padding(.top, 8)
                .background(Color.tertiaryBlue, ignoresSafeAreaEdges: .all)
                .presentationDetents([.height(450)])
            }
            .sheet(isPresented: $isBlockedAppSelected) {
                VStack(alignment: .center, spacing: 32) {
                    LottieView(animation: .named("locked"))
                        .looping()
                        .frame(square: 100)
                    
                    Text("This app is already blocked.")
                        .font(.grotesk(.title, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    GlassButton("Go back") {
                        isBlockedAppSelected = false
                        refreshID += 1
                        selection = FamilyActivitySelection()
                        resetReloadButton()
                    }
                    .foregroundStyle(Color.accentBlue)
                }
                .padding([.horizontal, .bottom], 32)
                .padding(.top, 8)
                .background(Color.tertiaryBlue, ignoresSafeAreaEdges: .all)
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled()
            }
        }
        .onAppear(perform: setup)
    }
    
    @ViewBuilder
    private func ReloadButton() -> some View {
        VStack(spacing: 56) {
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .frame(square: 72)
                        .foregroundStyle(.yellow.opacity(0.25))
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(.yellow)
                        .offset(y: -3)
                }
                
                VStack(spacing: 14) {
                    Text("Something went wrong.")
                        .font(.title2.weight(.bold))
                    
                    Text("This picker is provided by Apple and may occasionally crash. We apologize for the inconvenience.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4.0)
                }
            }
            
            Button {
                refreshID += 1
                selection = FamilyActivitySelection()
                Haptics.feedback(style: .light)
                resetReloadButton()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    
                    Text("Reload")
                }
                .font(.body.weight(.semibold))
                .padding()
                .background(.secondary.opacity(0.25), in: .capsule(style: .continuous))
            }
            .tint(.primary)
        }
        .padding(32)
        .opacity(showReloadButton ? 1 : 0)

    }
    
    private func setup() {
        addApps()
        resetReloadButton()
    }
    
    private func resetReloadButton() {
        showReloadButton = false
        
        SleepTask.sleep(seconds: 1.0) {
            showReloadButton = true
        }
    }
    
    private func handleSelection(_ oldValue: FamilyActivitySelection, _ newValue: FamilyActivitySelection) {
        
        guard newValue.applicationTokens.count <= 1 else {
            // Category warning: Selecting category is not allowed
            isCategorySelected = true
            Haptics.warningFeedback()
            return
        }
        
        if let app = newValue.applicationTokens.first {
            if isAppSelected(app) {
                // Show Warning: App already blocked
                isBlockedAppSelected = true
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
    
    private func addApps() {
        for block in blocks {
            guard let tokenString = block.appTokenString,
                  let app = ApplicationToken.fromRawValue(tokenString)
            else {
                continue // Skip this block if token is invalid or app can't be decoded
            }

            currentAppSelection.insert(app)
        }
    }

    private func isAppSelected(_ app: ApplicationToken) -> Bool {
        currentAppSelection.contains(app)
    }

}

#Preview {
    ActivityPickerView { _ in
        
    }
}

#Preview {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            ActivityPickerView { _ in
                
            }
        }
}

