//
//  SubscriptionEndedSheet.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/09/25.
//

import SwiftUI
import Lottie
import SuperwallKit

struct SubscriptionEndedSheet: View {
    @EnvironmentObject var vm: UserViewModel
    
    let blocks: FetchedResults<BlockEntity>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .center, spacing: 48) {
                LottieView(animation: .named("pleading"))
                    .looping()
                    .frame(square: 128)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 6)
                
                VStack(alignment: .leading, spacing: 18) {
                    Text("We already miss you, \(vm.user?.name ?? "friend").")
                        .font(.grotesk(size: 32, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2.0)
                    
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
                    
                    Text("You’ve lost your \(vm.currentStreak)-day streak")
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
                    
                    Text("\(blocks.count) apps are now unlocked")
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
                GlassButton {
                    action()
                } label: {
                    HStack(spacing: 10) {
                        Text("Keep my streak")
                            .font(.grotesk(size: 20, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                }
                
                Text("All your blocks will be automatically activated again when you renew your subscription.")
                    .font(.grotesk(.footnote, weight: .regular))
                    .multilineTextAlignment(.center)
                    .opacity(0.65)
                    .lineSpacing(4.0)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
        .background(.thinMaterial, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        if (DeviceActivityManager.shared.store.shield.applications?.count ?? 0) > 0 {
            DeviceActivityManager.shared.deactivateAllBlocks(blocks)
        }
    }
    
    private func action() {
//        Superwall.shared.register(placement: Placements.paywallRenew.rawValue)
    }
        
}

#Preview {
    TabBarView()
        .environmentObject(LocalNotificationManager())
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
        .environmentObject(PurchaseManager.shared)
}

#Preview("Sheet Preview") {
    SubEndPreview()
}

private struct SubEndPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>

    var body: some View {
        Text("Hello, World!")
            .sheet(isPresented: .constant(true)) {
                SubscriptionEndedSheet(blocks: blocks)
                    .environmentObject(UserViewModel())
                    .interactiveDismissDisabled()
            }
    }
}
