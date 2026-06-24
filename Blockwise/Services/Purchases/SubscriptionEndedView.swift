//
//  SubscriptionEndedView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/02/26.
//

import SwiftUI

struct SubscriptionEndedView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var isLoading: Bool = false
    
    @AppStorage(AppStorageKeys.User.name.key) var name: String = ""
    
    let blocks: FetchedResults<BlockEntity>
    let schedules: FetchedResults<ScheduleEntity>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .center, spacing: 48) {
                
                VStack(alignment: .leading, spacing: 18) {
                    Text("Subscription expired".uppercased())
                        .font(.grotesk(.footnote, weight: .semibold))
                        .kerning(1.5)
                        .foregroundStyle(.orange)
                    
                    Text("We already miss you, \(name) :(")
                        .font(.grotesk(size: 32, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2.0)
                        .foregroundStyle(.textC)
                    
                    Text("Your subscription has expired, your blocks have been deactivated.")
                        .font(.grotesk(.body, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .opacity(0.65)
                        .lineSpacing(4.0)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                    
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .opacity(0.15)
                    
                    Text("You’ll lose your \(userViewModel.currentStreak)-day streak")
                }
                .foregroundStyle(Color.gray)
                .font(.grotesk(.subheadline, weight: .semibold))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background {
                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.15))
                }

                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                    
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .opacity(0.15)
                    
                    Text("\(blocks.count) apps are now open")
                }
                .foregroundStyle(Color.gray)
                .font(.grotesk(.subheadline, weight: .semibold))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background {
                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.15))
                }
                
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .center, spacing: 18) {
                GlassButton("Relock my apps", labelColor: .white, background: .skyBlue) {
                    action()
                }
                
                Text("All your blocks will be automatically activated again when you renew your subscription.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .multilineTextAlignment(.center)
                    .opacity(0.65)
                    .lineSpacing(4.0)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .overlay {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(square: 76)
                    .foregroundStyle(.thinMaterial)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isLoading ? 1 : 0.9)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: isLoading)
            }
            .opacity(isLoading ? 1 : 0)
        }
        .animation(.smooth, value: isLoading)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        // Deactivate blocks
        DeviceActivityManager.shared.deactivateAllBlocks(blocks)
        DeviceActivityManager.shared.store.shield.applications?.removeAll()
        
        // Deactivate schedules
        DeviceActivityManager.shared.deactivateAllSchedules(schedules)
    }
    
    private func action() {
        isLoading = true
        
        PurchaseManager.shared.superwall(placement: Placements.subscriptionExpired.rawValue) {
            // This paywall should be gated, meaning dismissing it
            // should not run the code inside this closure
            
            // Reactivate the blocks
            DeviceActivityManager.shared.activateAllBlocks(blocks)
            
            // Reactivate the schedules
            do {
                try DeviceActivityManager.shared.activateAllSchedules(schedules)
                toastManager.info("Subscription active!")
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }

            // Set loading false
            isLoading = false
            
            // Dismiss
            dismiss()
        }
    }
}

#Preview {
    SubscriptionEndedViewPreview()
        .environmentObject(UserViewModel())
}

private struct SubscriptionEndedViewPreview: View {
    @FetchRequest(sortDescriptors: [])
    private var blocks: FetchedResults<BlockEntity>
    
    @FetchRequest(sortDescriptors: [])
    private var schedules: FetchedResults<ScheduleEntity>

    var body: some View {
        SubscriptionEndedView(blocks: blocks, schedules: schedules)
    }
}
