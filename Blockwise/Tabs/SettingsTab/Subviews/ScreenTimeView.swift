//
//  ScreenTimeView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/02/26.
//

import SwiftUI
import WidgetKit

struct ScreenTimeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @FetchRequest(sortDescriptors: [], predicate: .today(for: "timestamp"))
    private var todaysRecords: FetchedResults<RecordEntity>
    
    @State private var showPicker: Bool = false
    @State private var input: TimeInterval = 0
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .frame(height: 78)
                    .foregroundStyle(Theme.foregroundC)
                    .overlay {
                        HStack {
                            Text("Current Goal")
                                .font(.grotesk(.title2, weight: .semibold))
                                .foregroundStyle(.textC)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(TimeFormatter.display(screenTimeGoal, style: .short))
                                    .font(.grotesk(.body, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        guard totalUsageToday <= 10 * 60 else {
                            showAlert = true
                            alertTitle = "Can't Change Goal Today"
                            alertMessage = "You can only change your goal if today's usage is under 10 minutes."
                            Haptics.warningFeedback()
                            return
                        }
                        showPicker = true
                    } label: {
                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .frame(height: 64)
                            .foregroundStyle(Theme.foregroundC)
                            .overlay {
                                HStack {
                                    Text("Change Goal")
                                        .font(.grotesk(.title3, weight: .semibold))
                                    
                                }
                                .padding(.horizontal, 24)
                            }
                    }
                    
                    Text("**NOTE**: To keep things fair, you're allowed to change your goal only if your screen time for today is under 10 minutes.")
                        .font(.grotesk(.footnote, weight: .regular))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .lineSpacing(4.0)
                }

            }
            .padding()
        }
        .sheet(isPresented: $showPicker) {
            ChangeGoalPicker()
                .presentationDetents([.height(400)])
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Okay", role: .cancel) {
                
            }
        } message: {
            Text(alertMessage)
        }
        .navigationTitle("Screen Time")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)

    }
    
    var totalUsageToday: TimeInterval {
        todaysRecords.reduce(0) { $0 + $1.duration }
    }
    
    var screenTimeGoal: TimeInterval {
        userViewModel.user?.goal(for: .now) ?? 3600 // 1 hour if any error
    }
    
    @ViewBuilder
    private func ChangeGoalPicker() -> some View {
        let currentValue: Double = screenTimeGoal
        let maxRange: TimeInterval = 6 * 60 // 6 hours max
        
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Screen Time Goal Picker", selection: $input) {
                    ForEach(Array(stride(from: 15, through: maxRange, by: 5)), id: \.self) { value in
                        let valueInMinutes = Double(value * 60)

                        Text("\(TimeFormatter.display(valueInMinutes, style: .spaced))")
                            .font(.grotesk(size: 18.5, weight: .regular))
                            .tag(valueInMinutes)
                    }
                }
                .pickerStyle(.wheel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Apply changes") {
                    guard let user = userViewModel.user else {
                        toastManager.error("Could not find user object")
                        return
                    }
                    
                    do {
                        try CoreDataStack.shared.setScreenTimeGoal(
                            input,
                            for: user
                        )
                        toastManager.info("Goal updated!")
                        WidgetCenter.shared.reloadAllTimelines()
                    } catch {
                        toastManager.error(error.localizedDescription)
                    }
                    
                    showPicker = false
                }
                .padding()
                .padding(.horizontal, 32)
            }
            .navigationTitle("Change Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .onAppear {
                input = currentValue
            }
        }
    }

}

#Preview {
    NavigationStack {
        ScreenTimeView()
            .environmentObject(UserViewModel())
            .environmentObject(ToastManager())
    }
}
