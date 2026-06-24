//
//  FocusSetupView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI

struct FocusSetupView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var focusViewModel: FocusViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    private let minInterval: Int = 15
    private let maxInterval: Int = 2 * 60
    
    private var range: ClosedRange<Int> {
        minInterval...maxInterval
    }
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 18) {
                        Button {
                            focusViewModel.showDurationPicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Duration")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text(TimeFormatter.display(focusViewModel.duration, style: .short))
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.trailing, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .foregroundStyle(Theme.foregroundC)
                                    .border(cornerRadius: 28)
                            }
                        }
                        .tint(.primary)

                    }
                    
                    VStack(spacing: 18) {
                        Button {
                            focusViewModel.showBlockingTypePicker = true
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 0) {
                                    Text("Blocking Type")
                                        .font(.grotesk(.title3, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Text(focusViewModel.blockingType.rawValue)
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.trailing, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .foregroundStyle(Theme.foregroundC)
                                    .border(cornerRadius: 28)
                            }
                        }
                        .tint(.primary)

                        if focusViewModel.blockingType == .allApps {
                            Button {
                                focusViewModel.showAllowList = true
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Allow List")
                                                .font(.grotesk(.title3, weight: .semibold))
                                                .foregroundStyle(.textC)
                                            
                                            Text("All apps except these will be blocked")
                                                .font(.grotesk(.footnote, weight: .regular))
                                                .foregroundStyle(.textC).opacity(0.5)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(focusViewModel.allowedApps.applications.isEmpty ? "None" : "")
                                            .font(.grotesk(.body, weight: .regular))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if !focusViewModel.allowedApps.applications.isEmpty {
                                        HStack(spacing: -10) {
                                            ForEach(Array(focusViewModel.allowedApps.applicationTokens.prefix(5).enumerated()), id: \.offset) { (index, appToken) in
                                                Label(appToken)
                                                    .labelStyle(.iconOnly)
                                                    .scaleEffect(1.5)
                                                    .padding(2)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .foregroundStyle(.thinMaterial)
                                                    }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .overlay {
                                            if focusViewModel.allowedApps.applicationTokens.count > 5 {
                                                Text("+\(focusViewModel.allowedApps.applicationTokens.count - 5)")
                                                    .font(.grotesk(.subheadline, weight: .medium))
                                                    .foregroundStyle(Color.secondary)
                                                    .offset(x: 16)
                                            }
                                        }
                                    }
                                }
                                .padding(.trailing, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(alignment: .trailing) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .foregroundStyle(Theme.foregroundC)
                                        .border(cornerRadius: 28)
                                }
                            }
                            .tint(.primary)
                        } else {
                            Button {
                                focusViewModel.showBlockList = true
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Block List")
                                                .font(.grotesk(.title3, weight: .semibold))
                                                .foregroundStyle(.textC)
                                            
                                            Text("Only these apps will be blocked")
                                                .font(.grotesk(.footnote, weight: .regular))
                                                .foregroundStyle(.textC).opacity(0.5)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(focusViewModel.blockedApps.applications.isEmpty ? "None" : "")
                                            .font(.grotesk(.body, weight: .regular))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if !focusViewModel.blockedApps.applications.isEmpty {
                                        HStack(spacing: -10) {
                                            ForEach(Array(focusViewModel.blockedApps.applicationTokens.prefix(5).enumerated()), id: \.offset) { (index, appToken) in
                                                Label(appToken)
                                                    .labelStyle(.iconOnly)
                                                    .scaleEffect(1.5)
                                                    .padding(2)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .foregroundStyle(.thinMaterial)
                                                    }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .overlay {
                                            if focusViewModel.blockedApps.applicationTokens.count > 5 {
                                                Text("+\(focusViewModel.blockedApps.applicationTokens.count - 5)")
                                                    .font(.grotesk(.subheadline, weight: .medium))
                                                    .foregroundStyle(Color.secondary)
                                                    .offset(x: 16)
                                            }
                                        }
                                    }
                                }
                                .padding(.trailing, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(alignment: .trailing) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .foregroundStyle(Theme.foregroundC)
                                        .border(cornerRadius: 28)
                                }
                            }
                            .tint(.primary)
                        }

                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Start") {
                    action()
                }
                .padding()
                .padding(.horizontal, 32)
            }
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
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $focusViewModel.showDurationPicker) {
                DurationPicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $focusViewModel.showBlockingTypePicker) {
                BlockingTypePicker()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $focusViewModel.showAllowList) {
                AllowListSheet()
            }
            .sheet(isPresented: $focusViewModel.showBlockList) {
                BlockListSheet()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Focus Session")
            .onAppear(perform: setup)
        }

    }
    
    private func setup() {
        focusViewModel.inputDuration = Int(focusViewModel.duration / 60)
    }
    
    private func action() {
        if focusViewModel.blockingType == .specificApps && focusViewModel.blockedApps.applications.isEmpty {
            Haptics.warningFeedback()
            showAlert = true
            alertTitle = "No apps selected"
            alertMessage = "Please select at least 1 app to block during your focus session"
            return
        }
        
        switch focusViewModel.blockingType {
        case .allApps:
            do {
                try focusViewModel.startSession(allExcept: focusViewModel.allowedApps)
            } catch {
                toastManager.error(error.localizedDescription)
            }
        case .specificApps:
            do {
                try focusViewModel.startSession(selection: focusViewModel.blockedApps)
            } catch {
                toastManager.error(error.localizedDescription)
            }
        }
        
        dismiss()
        
    }
    
    @ViewBuilder
    private func DurationPicker() -> some View {
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Duration Picker", selection: $focusViewModel.inputDuration) {
                    ForEach(range, id: \.self) { minute in
                        Text(TimeFormatter.display(Double(minute) * 60, style: .spaced))
                            .font(.grotesk(.title3, weight: .medium))
                            .tag(Double(minute) * 60)
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    focusViewModel.duration = TimeInterval(focusViewModel.inputDuration * 60)
                    focusViewModel.showDurationPicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        focusViewModel.showDurationPicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
    }

    @ViewBuilder
    private func BlockingTypePicker() -> some View {
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Blocking Type Picker", selection: $focusViewModel.blockingType) {
                    ForEach(BlockingType.allCases, id: \.self) { type in
                        let tagValue = type.rawValue

                        Text(type.rawValue)
                            .font(.grotesk(size: 18.5, weight: .regular))
                            .tag(tagValue)

                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    focusViewModel.showBlockingTypePicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Blocking Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        focusViewModel.showBlockingTypePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func AllowListSheet() -> some View {
        
        NavigationStack {
            List {
                Section {
                    if focusViewModel.allowedApps.applicationTokens.isEmpty {
                        Button {
                            focusViewModel.showAllowListPicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20, weight: .medium))

                                Text("Add apps to the allow list")
                                    .font(.grotesk(.body, weight: .medium))
                            }
                        }
                    } else {
                        ForEach(Array(focusViewModel.allowedApps.applicationTokens.enumerated()), id: \.offset) { (i, token) in
                            HStack(spacing: 14) {
                                Label(token)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.75)
                                
                                Label(token)
                                    .labelStyle(.titleOnly)
                                    .scaleEffect(0.9, anchor: .leading)
                            }
                        }
                    }
                } header: {
                    Text("These apps will remain unblocked during your focus session")
                        .font(.grotesk(.body, weight: .regular))
                }
                .listRowBackground(Theme.foregroundC)
            }
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    focusViewModel.showAllowList = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Allow List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !focusViewModel.allowedApps.applicationTokens.isEmpty {
                        Button {
                            focusViewModel.showAllowListPicker = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        focusViewModel.showAllowList = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(isPresented: $focusViewModel.showAllowListPicker) {
                AllowListPicker()
                    .environmentObject(focusViewModel)
            }
        }
    }

    @ViewBuilder
    private func BlockListSheet() -> some View {
        
        NavigationStack {
            List {
                Section {
                    if focusViewModel.blockedApps.applicationTokens.isEmpty {
                        Button {
                            focusViewModel.showBlockListPicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20, weight: .medium))

                                Text("Add apps to block")
                                    .font(.grotesk(.body, weight: .medium))
                            }
                        }
                    } else {
                        ForEach(Array(focusViewModel.blockedApps.applicationTokens.enumerated()), id: \.offset) { (i, token) in
                            HStack(spacing: 14) {
                                Label(token)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.75)
                                
                                Label(token)
                                    .labelStyle(.titleOnly)
                                    .scaleEffect(0.9, anchor: .leading)
                            }
                        }
                    }
                } header: {
                    Text("These apps will remain blocked during your focus session")
                        .font(.grotesk(.body, weight: .regular))
                }
                .listRowBackground(Theme.foregroundC)
            }
            .safeAreaInset(edge: .bottom) {
                GlassButton("Done") {
                    focusViewModel.showBlockList = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Block List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !focusViewModel.blockedApps.applicationTokens.isEmpty {
                        Button {
                            focusViewModel.showBlockListPicker = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        focusViewModel.showBlockList = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(isPresented: $focusViewModel.showBlockListPicker) {
                BlockListPicker()
                    .environmentObject(focusViewModel)
            }
        }
    }

}

#Preview {
    FocusSetupView()
        .environmentObject(FocusViewModel())
        .environmentObject(ToastManager())
}
