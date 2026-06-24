//
//  FocusSessionPicker.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/12/25.
//

import FamilyControls
import SwiftUI
import Lottie
import ManagedSettings

struct FocusSessionPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("isFocusSession") var isFocusSession: Bool = false
    @AppStorage("focusMinutes") var focusMinutes: Int = 90
    @AppStorage("focusSessionStart") var focusSessionStart: Double = 0
    
    @State private var advancedSettings: Bool = false

    let minutes: [Int] = Array(stride(from: 5, through: 480, by: 5))
    
    var blocks: FetchedResults<BlockEntity>
    
    @State private var appExceptions = FamilyActivitySelection(includeEntireCategory: true)
    
    // MARK: - Persistence Keys
    private let exceptionsKey = "FocusAppExceptionsAppTokens"
    
    var body: some View {

        VStack(spacing: 40) {
            
            VStack(spacing: 14) {
                Text("Focus Session")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .foregroundStyle(.textC)
                
                Text("Block all your apps for a specific time.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Picker(selection: $focusMinutes) {
                ForEach(minutes, id: \.self) { min in
                    Text(TimeFormatter.display(Double(min * 60), style: .short))
                        .font(.grotesk(size: 20, weight: .regular))
                }
            } label: {
                Text("Time Picker")
            }
            .pickerStyle(.wheel)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Start Focus") {
                    dismiss()
                    
                    DeviceActivityManager.shared.blockAllApps(
                        except: appExceptions.applicationTokens,
                        blocks: blocks
                    )
                    
                    SleepTask.sleep(seconds: 0.2) {
                        withAnimation {
                            isFocusSession = true
                        }
                        
                        focusSessionStart = Date.now.timeIntervalSince1970
                    }
                }
                
                Button("Advanced Options") {
                    advancedSettings = true
                    Haptics.feedback(style: .light)
                }
                .font(.grotesk(.body, weight: .medium))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $advancedSettings) {
            FocusAdvancedSettingsView(blocks: blocks, appExceptions: $appExceptions)
        }
        // MARK: - Persistence Hooks
        .onAppear {
            loadAppExceptions()
        }
        .onChange(of: appExceptions) { _, _ in
            saveAppExceptions()
        }
        .fullScreenCover(isPresented: $isFocusSession) {
            FocusSessionView()
        }
    }
    
    // MARK: - Persistence
    private func saveAppExceptions() {
        let strings = appExceptions.applicationTokens.compactMap { $0.string }
        UserDefaultsManager.shared.set(strings, forKey: exceptionsKey)
    }
    
    private func loadAppExceptions() {
        let strings = UserDefaultsManager.shared.get(forKey: exceptionsKey, as: [String].self) ?? []
        let tokens: Set<ApplicationToken> = Set(strings.compactMap { ApplicationToken.fromRawValue($0) })
        
        var selection = FamilyActivitySelection(includeEntireCategory: true)
        selection.applicationTokens = tokens
        appExceptions = selection
    }
}

#Preview {
    FocusSessionPickerPreview()
}

struct FocusAdvancedSettingsView: View {
    @Environment(\.dismiss) var dismiss
    var blocks: FetchedResults<BlockEntity>
    
    @State private var hyperFocusConfirm: Bool = false
    
    @Binding var appExceptions: FamilyActivitySelection
    @State private var showAppPicker = false
    
    @AppStorage("isHyperFocus") private var isHyperFocus: Bool = false
    
    var appCount: String {
        appExceptions.applicationTokens.isEmpty ? "None" : "\(appExceptions.applicationTokens.count) app"
    }

    // Persistence Keys (reuse same key)
    private let exceptionsKey = "FocusAppExceptionsAppTokens"
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showAppPicker = true
                    } label: {
                        HStack(spacing: 10) {
                            Text("Allow list")
                                .font(.grotesk(.body, weight: .medium))
                            
                            Spacer()
                            
                            Text(appCount)
                                .font(.grotesk(.body, weight: .regular))
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                        .padding(.horizontal, 4)
                    }
                    .tint(.primary)
                } footer: {
                    Text("**All** your apps **except** these will be blocked")
                        .font(.grotesk(.footnote, weight: .regular))
                }
                .listRowBackground(Theme.foregroundC)
                
                Section {
                    HStack {
                        Text("Hyper Focus")
                            .font(.grotesk(.body, weight: .medium))
                        
                        Spacer()
                        
                        Toggle(isOn: $isHyperFocus) {
                            ///
                        }
                        .tint(Color.blueAccent)
                        .onChange(of: isHyperFocus) { oldValue, newValue in
                            if oldValue == false, newValue == true {
                                withAnimation {
                                    hyperFocusConfirm = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                } footer: {
                    Text("In **Hyper Focus** mode, Focus Sessions can’t be ended early. You’ll need to **wait until** the time runs out.")
                        .font(.grotesk(.footnote, weight: .regular))
                        .lineSpacing(2.0)
                }
                .listRowBackground(Theme.foregroundC)

            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
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
            .navigationTitle("Advanced Options")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAppPicker) {
                AppExceptionPicker(appExceptions: $appExceptions, blocks: blocks)
            }
        }
        .interactiveDismissDisabled(hyperFocusConfirm)
        .blur(radius: hyperFocusConfirm ? 16 : 0)
        .overlay {
            Color.black.opacity(hyperFocusConfirm ? 0.6 : 0.0)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 48) {
                LottieView(animation: .named("locked"))
                    .looping()
                    .frame(square: 128)

                VStack(alignment: .center, spacing: 14) {
                    Text("Are you sure?")
                        .font(.grotesk(size: 26, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    
                    Text("You won't be able to end Focus Session earlier. You will have to wait until the timer expires.")
                        .font(.grotesk(size: 17, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineSpacing(4.0)
                        .padding(.horizontal, 44)
                }
                
                Space(height: 10)

                VStack(alignment: .center, spacing: 48) {
                    
                    GlassButton {
                        withAnimation {
                            hyperFocusConfirm = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Yes")
                                .font(.grotesk(.title3, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 64)
                    
                    Button("No, don't enable it") {
                        withAnimation {
                            hyperFocusConfirm = false
                            isHyperFocus = false
                        }
                    }
                    .tint(Color.white)
                    .font(.grotesk(.body, weight: .medium))
                    .padding(.horizontal, 64)
                }
            }
            .opacity(hyperFocusConfirm ? 1 : 0)
            .scaleEffect(hyperFocusConfirm ? 1 : 1.2)
            .animation(.smooth, value: hyperFocusConfirm)
        }
        // Persist changes immediately when selection changes
        .onChange(of: appExceptions) { _, _ in
            saveAppExceptions()
        }

    }
    
    // MARK: - Persistence
    private func saveAppExceptions() {
        let strings = appExceptions.applicationTokens.compactMap { $0.string }
        UserDefaultsManager.shared.set(strings, forKey: exceptionsKey)
    }
}

private struct FocusSessionPickerPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>

    var body: some View {
        Text("Hello, World!")
            .sheet(isPresented: .constant(true)) {
                FocusSessionPicker(blocks: blocks)
                    .presentationDetents([.height(650)])
            }
//        FocusAdvancedSettingsView(blocks: blocks)
    }
}

struct AppExceptionPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var appExceptions: FamilyActivitySelection
    
    @State private var appExceptionSelection = FamilyActivitySelection(includeEntireCategory: true)
    
    // To check duplicates
    @State private var currentAppSelection: Set<ApplicationToken> = []
    
    @State private var isDuplicate: Bool = false
    
    var dup: Bool {
        appExceptionSelection.applicationTokens.first(where: { currentAppSelection.contains($0) }) != nil
    }
    
    var blocks: FetchedResults<BlockEntity>
    
    var body: some View {
        NavigationStack {
            FamilyActivityPicker(
                headerText: "Choose the apps NOT to block during the Focus Session",
                footerText: "",
                selection: $appExceptionSelection
            )
            .ignoresSafeArea()
            .navigationTitle("Choose Activities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(dup)
                }
            }
            .onAppear(perform: setup)
            .sheet(isPresented: $isDuplicate) {
                VStack(spacing: 18) {
                    Text("You can't allow the apps that are part of your current block list.")
                        .font(.grotesk(.title, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text("Please change your selection")
                        .font(.grotesk())
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)
                .safeAreaInset(edge: .bottom) {
                    GlassButton("Okay") {
                        isDuplicate = false
                    }
                    .padding(.horizontal, 32)
                }
                .presentationDetents([.height(400)])
            }
            .onChange(of: appExceptionSelection) { oldValue, newValue in
                handleSelection(oldValue, newValue)
            }
        }
    }
    
    private func setup() {
        loadCurrentlyBlockedApps()
        appExceptionSelection = appExceptions
    }
    
    private func handleSelection(_ oldValue: FamilyActivitySelection, _ newValue: FamilyActivitySelection) {
        // Apps newly added by the user
        let addedApps = newValue.applicationTokens.subtracting(oldValue.applicationTokens)

        // Check if any newly added app already exists
        if let duplicate = addedApps.first(where: { currentAppSelection.contains($0) }) {
            Logger.debug("Duplicate app detected: \(duplicate)")
            
            // Warn user
            isDuplicate = true
            Haptics.warningFeedback()
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
    
    private func save() {
        appExceptions = appExceptionSelection
        dismiss()
    }

}
