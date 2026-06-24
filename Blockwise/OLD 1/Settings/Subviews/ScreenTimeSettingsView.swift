//
//  ScreenTimeSettingsView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 22/08/25.
//

import SwiftUI

struct ScreenTimeSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var showEditGoalView: Bool = false
        
    var screenTimeGoal: TimeInterval {
        vm.user?.goal(for: .now) ?? 3600
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    var totalUsageToday: TimeInterval {
        blocks.reduce(0) { usage, block in
            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    @State private var goal: TimeInterval = 0
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Screen Time Goal")
                        .font(.grotesk(.body, weight: .semibold))
                    
                    Spacer()
                    
                    Text(TimeFormatter.display(screenTimeGoal, style: .short))
                        .font(.grotesk())
                        .opacity(0.65)
                }
                
                Button("Change your goal") {
                    showEditGoalView = true
                    Haptics.feedback(style: .light)
                }.disabled(totalUsageToday > (10 * 60))
                .font(.grotesk(.body, weight: .semibold))
                .tint(Color.primaryBlue)
            } footer: {
                Text("**NOTE**: To prevent misuse, you're allowed to change your goal only if your screen time for today is under 10 minutes.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .lineSpacing(2.0)
            }
            .listRowBackground(Theme.foregroundC)
        }
        .navigationTitle("Screen Time")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $showEditGoalView) {
            ChangeGoalSheet()
                .presentationDetents([.height(500)])
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        goal = screenTimeGoal
    }
        
    private func action() {
        guard let user = vm.user else { return }
        do {
            try CoreDataStack.shared.setScreenTimeGoal(goal, for: user)
            toastManager.info("Goal updated.")
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error(error.localizedDescription)
        }
        showEditGoalView = false
    }
    
    @ViewBuilder
    private func ChangeGoalSheet() -> some View {
        VStack(spacing: 32) {
            Text("Change you Screen Time Goal")
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
            
            VStack(spacing: 32) {
                let triangleWidth: CGFloat = 18
                
//                Triangle()
//                    .frame(width: triangleWidth, height: triangleWidth * 0.7)
//                    .rotationEffect(.degrees(180))
//                    .foregroundStyle(Color.secondary.opacity(0.15))
                
                ScreenTimeSelector()
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            ZStack {
                Button {
                    showEditGoalView = false
                    Haptics.feedback(style: .rigid)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .regular))
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Apply Changes") {
                action()
            }
            .foregroundStyle(Color.accentBlue)
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
    }
    
    @ViewBuilder
    private func ScreenTimeSelector() -> some View {
        let color: Color = Color.primaryBlue
        
        HStack(spacing: 28) {
            Button {
                guard goal > 15 * 60 else { return }
                withAnimation {
                    goal -= 15 * 60
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .opacity(goal <= 15 * 60 ? 0.35 : 1.0)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Text(TimeFormatter.display(goal, style: .short))
                .font(.grotesk(size: 40, weight: .bold))
//                .font(.system(size: 40, weight: .bold))
                .contentTransition(.numericText(value: goal))
                .foregroundStyle(color)
            
            Button {
                guard goal < 7 * 3600 else { return }
                
                withAnimation {
                    goal += 15 * 60
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .opacity(goal >= 7 * 3600 ? 0.35 : 1.0)
                    .foregroundStyle(color)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }

}

#Preview {
    NavigationStack {
        ScreenTimeSettingsView()
            .environmentObject(UserViewModel())
            .environmentObject(ToastManager())
    }
}
