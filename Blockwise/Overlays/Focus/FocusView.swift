//
//  FocusView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/02/26.
//

import SwiftUI

struct FocusView: View {
    @EnvironmentObject var focusViewModel: FocusViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showThemePicker = false
    @State private var showAppList = false
    @State private var isComplete: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @AppStorage("is_focus_active", store: UserDefaultsManager.shared.userDefault) var isFocusActive: Bool = false
    
    private func timeRemaining(at date: Date) -> TimeInterval {
        let elapsed = date.timeIntervalSince(focusViewModel.startTime)
        return max(0, focusViewModel.duration - elapsed)
    }
    
    private func progress(at date: Date) -> Double {
        guard focusViewModel.duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(focusViewModel.startTime)
        return min(1.0, elapsed / focusViewModel.duration)
    }
    
    private var endTime: Date {
        focusViewModel.startTime.addingTimeInterval(focusViewModel.duration)
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            contentView(currentDate: context.date)
        }
        .sheet(isPresented: $showAppList) {
            AppListView()
        }
        .onChange(of: isFocusActive) { oldValue, newValue in
            if oldValue == true, newValue == false {
                isComplete = true
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Give up") {
                endSession()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    @ViewBuilder
    private func contentView(currentDate: Date) -> some View {
        let currentProgress = progress(at: currentDate)
        let remaining = timeRemaining(at: currentDate)
        let complete = remaining <= 0
        
        VStack(spacing: 32) {
            progressCircle(progress: currentProgress, isComplete: complete)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                appList
                
                Button {
                    Haptics.warningFeedback()
                    showAlert = true
                    alertTitle = "Are you sure?"
                    alertMessage = "You're about to end this focus session early"
                } label: {
                    Text("Give up")
                        .font(.grotesk(.body, weight: .medium))
                }
                .tint(Color.secondary)
            }
            .padding()
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
    }
    
    @ViewBuilder
    private func progressCircle(progress: Double, isComplete: Bool) -> some View {
        ZStack {
            // Outer stroke
            Circle()
                .stroke(lineWidth: 2.0)
                .foregroundStyle(.secondary.opacity(0.15))
            
            // Background progress ring
            Circle()
                .stroke(lineWidth: 38)
                .foregroundStyle(.secondary.opacity(0.15))
                .padding(.horizontal, 26)
            
            // Active progress ring
            Circle()
                .trim(from: progress, to: 1)
                .stroke(lineWidth: 38)
                .foregroundStyle(isComplete ? .green : .blue)
                .padding(.horizontal, 26)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            VStack(spacing: 8) {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Complete!")
                        .font(.grotesk(.title3, weight: .medium))
                        .foregroundStyle(.textC)
                } else {
                    Text(endTime, style: .timer)
                        .foregroundStyle(.textC)
                        .font(.grotesk(size: 48, weight: .regular))
                        .monospacedDigit()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 11))
                        Text(endTime, style: .time)
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(44)
    }
    
    @ViewBuilder
    private var appList: some View {
        Button {
            showAppList = true
        } label: {
            VStack(spacing: 10) {
                if focusViewModel.blockingType == .allApps {
                    if !focusViewModel.allowedApps.applicationTokens.isEmpty {
                        Text("Allowed apps".uppercased())
                            .kerning(1.5)
                            .font(.grotesk(.footnote, weight: .medium))
                            .foregroundStyle(.secondary)
                        
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
                        .frame(maxWidth: .infinity)
                        .overlay {
                            if focusViewModel.allowedApps.applicationTokens.count > 5 {
                                Text("+\(focusViewModel.allowedApps.applicationTokens.count - 5)")
                                    .font(.grotesk(.subheadline, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                                    .offset(x: 90)
                            }
                        }
                    }
                } else {
                    if !focusViewModel.blockedApps.applicationTokens.isEmpty {
                        Text("Blocked apps".uppercased())
                            .kerning(1.5)
                            .font(.grotesk(.footnote, weight: .medium))
                            .foregroundStyle(.secondary)
                        
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
                        .frame(maxWidth: .infinity)
                        .overlay {
                            if focusViewModel.blockedApps.applicationTokens.count > 5 {
                                Text("+\(focusViewModel.blockedApps.applicationTokens.count - 5)")
                                    .font(.grotesk(.subheadline, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                                    .offset(x: 90)
                            }
                        }
                    }
                }
            }
        }
        .tint(.primary)
    }
    
    private func endSession() {
        focusViewModel.stopSession()
        dismiss()
    }
    
    @ViewBuilder
    private func AppListView() -> some View {
        NavigationStack {
            List {
                if focusViewModel.blockingType == .allApps {
                    Section {
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
                    } header: {
                        Text("These apps are unlocked during your focus session")
                            .font(.grotesk(.body, weight: .regular))
                    }
                    .listRowBackground(Theme.foregroundC)
                } else {
                    Section {
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
                    } header: {
                        Text("These apps are blocked during your focus session")
                            .font(.grotesk(.body, weight: .regular))
                    }
                    .listRowBackground(Theme.foregroundC)
                }
            }
            .navigationTitle(focusViewModel.blockingType == .allApps ? "Allowed Apps" : "Blocked Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAppList = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        }
    }
}
