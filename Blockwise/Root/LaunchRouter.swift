//
//  LaunchRouter.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/01/26.
//

import SwiftUI
import WidgetKit
import FamilyControls
import ManagedSettings

struct LaunchRouter: View {
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var center = AuthorizationCenter.shared
    
    @AppStorage(AppStorageKeys.Settings.appTheme.key) var appTheme: AppTheme = .light
    @AppStorage(AppStorageKeys.Onboarding.isNewUser.key) var isNewUser: Bool = true
    @AppStorage(AppStorageKeys.Main.showDuration.key) var showDuration: Bool = false

    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var focusViewModel = FocusViewModel()
    @StateObject private var toastManager = ToastManager()
        
    @State private var showSubEndedView: Bool = false
    @State private var showScreenTimeError: Bool = false
    
    // MARK: - NEVER REMOVE THIS
    // The 1.3 update changed the database structure.
    // If you remove this line, all users who didn't update yet, when they do,
    // they won't be able to retain data and the app will crash
    @AppStorage("MIGRATE_COREDATA_FOR_UPDATE_1_3") var MIGRATION_WAS_PERFORMED: Bool = false
    
    @FetchRequest(sortDescriptors: [])
    private var blocks: FetchedResults<BlockEntity>
    
    @FetchRequest(sortDescriptors: [])
    private var schedules: FetchedResults<ScheduleEntity>
    
    var body: some View {
        Group {
            RootView()
                .overlay {
                    if isNewUser {
                        OnboardingView()
                            .transition(.move(edge: .bottom).combined(with: .offset(y: 100)))
                    }
                }
        }
        .scaleEffect(showDuration ? 1.05 : 1.0)
        .overlay {
            ScreenTimeErrorOverlay()
        }
        .overlay {
            if focusViewModel.showFocus {
                FocusView()
                    .transition(.move(edge: .bottom).combined(with: .offset(y: 100)))
            }
        }
        .overlay {
            if showDuration {
                DurationView()
                    .transition(.move(edge: .bottom).combined(with: .offset(y: 100)))
            }
        }
        .animation(.smooth, value: focusViewModel.showFocus)
        .fullScreenCover(isPresented: $showSubEndedView) {
            SubscriptionEndedView(blocks: blocks, schedules: schedules)
        }
        .animation(.smooth, value: showDuration)
        .onSubscriptionEnded(handleSubscription)
        .environmentObject(userViewModel)
        .environmentObject(focusViewModel)
        .environmentObject(toastManager)
        .toast(manager: toastManager)
        .onChange(of: center.authorizationStatus, checkScreenTimeAuth)
        .onChange(of: scenePhase, handleSceneUpdate)
        .preferredColorScheme(appTheme.colorScheme)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        checkScreenTimeAuth()
        checkForMigrations()
        logCurrentRoute()
    }
    
    private func checkForMigrations() {
        PERFORM_MIGRATION_VERSION_1_3()
    }
    
    private func checkScreenTimeAuth() {
        #if targetEnvironment(simulator)
        return
        #endif
        
        // Make sure the user is not on the onboarding
        guard !isNewUser else {
            Logger.debug("User is new, skipping “checkScreenTimeAuth“")
            return
        }
                
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                Logger.debug("Screen Time is enabled")
                showScreenTimeError = false
            } catch {
                Logger.error("Screen Time authorization failed: \(error.localizedDescription)")
                
                // Set error message and show alert
                await MainActor.run {
                    showScreenTimeError = true
                }
            }
        }
    }
        
    private func handleSubscription() {
        #if targetEnvironment(simulator)
        // Nothing happens
        #else
        
        // Make sure the user is not on the onboarding
        guard !isNewUser else {
            Logger.debug("User is new, skipping “handleSubscription“")
            return
        }
        
        Logger.debug("Subscription ended!")
        
        showSubEndedView = true
        
        #endif
    }
            
    private func logCurrentRoute() {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering LaunchRouter")
        Logger.debug("")
        Logger.debug("State:")
        Logger.debug("  • isNewUser: \(isNewUser)")
        Logger.debug("")
        
        if isNewUser {
            Logger.debug("→ Showing: OnboardingView")
        } else {
            Logger.debug("→ Showing: RootView")
        }
        
        Logger.debug("-----------------------------------------------------------")
    }
    
    private func handleSceneUpdate() {
        showDuration = UserDefaultsManager.shared.hasToken()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @ViewBuilder
    private func ScreenTimeErrorOverlay() -> some View {
        ZStack {
            Theme.backgroundC.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(.connectScreenTime)
                    .resizable()
                    .scaledToFit()
                    .frame(square: 180)
                
                VStack(spacing: 12) {
                    Text("Screen Time Required")
                        .font(.grotesk(size: 28, weight: .bold))
                        .foregroundStyle(.textC)
                    
                    Text("We need your permission to set app limits and block apps.")
                        .font(.grotesk(.body, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    GlassButton("Allow Screen Time") {
                        checkScreenTimeAuth()
                    }
                    .font(.grotesk(.body, weight: .semibold))
                    .padding(.horizontal, 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                ContactSupportButton {
                    Text("Contact Support")
                }
                .font(.grotesk(.body, weight: .medium))
                .padding()
            }

        }
        .opacity(showScreenTimeError ? 1 : 0)
        .animation(.smooth(duration: 0.35), value: showScreenTimeError)
    }

}

#Preview {
    LaunchRouter()
}

extension LaunchRouter {
    // MARK: - Important for the update 1.3
    private func PERFORM_MIGRATION_VERSION_1_3() {
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ MIGRATION v1.3 - START")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 1: Check if migration already performed
        // ─────────────────────────────────────────────────────────────────────
        
        guard !MIGRATION_WAS_PERFORMED else {
            Logger.debug("✅ Migration already performed, skipping")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        Logger.debug("🔄 Migration not yet performed, proceeding...")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // MIGRATION PURPOSE:
        // Goal storage location changed in v1.3. Previously, screenTimeGoal was
        // stored directly on UserEntity. Now it's stored in GoalEntity with
        // date tracking, allowing historical goal values per day.
        // UserEntity.screenTimeGoal still exists (unused) to avoid migration issues.
        // ─────────────────────────────────────────────────────────────────────
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 2: Validate user exists
        // ─────────────────────────────────────────────────────────────────────
        
        guard let user = userViewModel.user else {
            Logger.error("❌ ERROR: UserEntity not found, cannot perform migration")
            Logger.debug("═════════════════════════════════════════════════════════════════════")
            return
        }
        
        Logger.debug("✅ UserEntity found")
        Logger.debug("   └─ User ID: \(user.objectID)")
        Logger.debug("")
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 3: Determine if user is from pre-v1.3 or new user
        // ─────────────────────────────────────────────────────────────────────
        
        let userEntityGoal = user.screenTimeGoal
        Logger.debug("📊 User's screenTimeGoal value: \(userEntityGoal.formattedDuration())")
        Logger.debug("")
        
        // If screenTimeGoal is 0, this is a new user who installed v1.3+
        // No migration needed since they never had the old data structure
        let isOldUser = userEntityGoal > 0
        
        if isOldUser {
            Logger.debug("👤 OLD USER DETECTED (pre-v1.3)")
            Logger.debug("   └─ Migration required")
            Logger.debug("")
            
            // ─────────────────────────────────────────────────────────────────────
            // STEP 4: Migrate goal data to new GoalEntity structure
            // ─────────────────────────────────────────────────────────────────────
            
            Logger.debug("🎯 Creating new GoalEntity...")
            
            let goalEntity = GoalEntity(context: CoreDataStack.shared.persistentContainer.viewContext)
            goalEntity.goal = userEntityGoal
            goalEntity.startDate = user.dateCreated ?? Date.now
            goalEntity.endDate = nil
            goalEntity.user = user
            
            Logger.debug("   ├─ Goal value: \(userEntityGoal.formattedDuration())")
            Logger.debug("   ├─ Start date: \((user.dateCreated ?? Date.now).localTimeZone)")
            Logger.debug("   ├─ End date: nil (current goal)")
            Logger.debug("   └─ Linked to user: ✅")
            Logger.debug("")
            
            user.addToGoals(goalEntity)
            Logger.debug("✅ GoalEntity added to user's goals relationship")
            Logger.debug("")
            
            // ─────────────────────────────────────────────────────────────────────
            // STEP 5: Add default values to existing blocks
            // ─────────────────────────────────────────────────────────────────────
            
            Logger.debug("🔧 Updating existing blocks with default values...")
            Logger.debug("   └─ Total blocks to update: \(blocks.count)")
            Logger.debug("")
            
            if blocks.isEmpty {
                Logger.debug("   ℹ️  No blocks found, skipping block updates")
                Logger.debug("")
            } else {
                for (index, block) in blocks.enumerated() {
                    let blockIdentifier = block.identifier ?? "unknown"
                    Logger.debug("   Block \(index + 1)/\(blocks.count): \(blockIdentifier)")
                    
                    block.maxDuration = 15 * 60 // Default to 15 minutes
                    block.buttonDelay = 10 // Default to 10 seconds
                    block.cooldown = 60 // Default to 60 seconds
                    
                    Logger.debug("      ├─ maxDuration: \((15 * 60).formattedDuration())")
                    Logger.debug("      └─ buttonDelay: \(10.formattedDuration())")
                    Logger.debug("      └─ cooldown: \(60.formattedDuration())")
                }
                Logger.debug("")
                Logger.debug("   ✅ All \(blocks.count) blocks updated")
                Logger.debug("")
            }
            
            // ─────────────────────────────────────────────────────────────────────
            // STEP 6: Save Core Data context
            // ─────────────────────────────────────────────────────────────────────
            
            Logger.debug("💾 Saving Core Data context...")
            
            do {
                try CoreDataStack.shared.saveContext()
                Logger.debug("✅ Core Data context saved successfully")
                Logger.debug("")
            } catch {
                Logger.error("❌ ERROR: Core Data save failed")
                Logger.error("   └─ Error: \(error.localizedDescription)")
                Logger.debug("")
                toastManager.error("Database migration failed. Please contact support")
                
                // Don't set MIGRATION_WAS_PERFORMED to true if save failed
                // This allows retry on next launch
                Logger.debug("⚠️  Migration flag NOT set due to save failure")
                Logger.debug("═════════════════════════════════════════════════════════════════════")
                return
            }
            
        } else {
            Logger.debug("🆕 NEW USER DETECTED (v1.3+)")
            Logger.debug("   └─ No migration needed (user never had old data structure)")
            Logger.debug("")
        }
        
        // ─────────────────────────────────────────────────────────────────────
        // STEP 7: Mark migration as complete
        // ─────────────────────────────────────────────────────────────────────
        
        MIGRATION_WAS_PERFORMED = true
        Logger.debug("✅ Migration flag set to true")
        Logger.debug("")
        
        Logger.debug("═════════════════════════════════════════════════════════════════════")
        Logger.debug("║ MIGRATION v1.3 - COMPLETE ✅")
        Logger.debug("═════════════════════════════════════════════════════════════════════")
    }
}
