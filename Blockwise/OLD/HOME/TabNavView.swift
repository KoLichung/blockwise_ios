//
//  TabNavView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/11/25.
//

import SwiftUI
import SuperwallKit
import FamilyControls
import ManagedSettings

struct TabNavView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @StateObject var superwall = Superwall.shared
    
    @AppStorage(AppStorageKeys.Onboarding.isNewUser.rawValue) var firstTimeUser: Bool = true
    @AppStorage(AppStorageKeys.Settings.isHapticsEnabled.rawValue) var hapticsEnabled: Bool = true
    
//    @AppStorage(AppStorageKeys.Monetization.isSubscribed.rawValue) var isSubscribed: Bool = false
//    @AppStorage(AppStorageKeys.tutorialShown.rawValue) var tutorialShown: Bool = false
//    @AppStorage(AppStorageKeys.showAlarmWarning.rawValue) var showAlarmWarning: Bool = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    // Computed properties
    var totalUsageToday: TimeInterval {
        blocks.reduce(0) { usage, block in
            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    var isAnyOpen: Bool {
        (blocks.first(where: { $0.isOpen == true }) != nil)
    }
    
    var openCount: Int {
        blocks.filter { $0.isOpen }.count
    }
    
    // Triggers
    @State private var showUnlockView: Bool = false

    @State private var showReload: Bool = false
    @State private var isReload: Bool = false
    
    @AppStorage("isFocusSession") var isFocusSession: Bool = false
    
    @AppStorage("PERFORM_MIGRATION") var PERFORM_MIGRATION: Bool = false
    
    @State private var tabSelection: Int = 0

    init() {
        applyGroteskFont()
    }
    
    var profileTabName: String {
        vm.user?.name ?? "Me"
    }

    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Today", image: "circle.progress", value: 0) {
                HomeScreenView(blocks: blocks, tabSelection: $tabSelection)
            }

            Tab("Blocks", image: "shield.circle", value: 1) {
                BlocksScreenView(
                    blocks: blocks,
                    showReload: $showReload,
                    isReload: $isReload
                )
            }
            
            Tab(profileTabName, systemImage: "person.crop.circle", value: 2) {
                SettingScreenView()
            }
        }
        .tint(Color.blueAccent)
        .fullScreenCover(isPresented: $showUnlockView) {
            UnlockScreenView()
        }
        .onChange(of: scenePhase) {
            showUnlockView = UserDefaultsManager.shared.hasToken()
            vm.usage = totalUsageToday
        }
        .blur(radius: showReload ? 16 : 0)
        .overlay {
            Color.black.opacity(showReload ? 0.6 : 0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    guard !isReload else { return }
                    withAnimation {
                        showReload = false
                        Haptics.feedback(style: .light)
                    }
                }
            
            VStack(alignment: .center, spacing: 48) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isReload ? -360 : 0))

                VStack(alignment: .center, spacing: 14) {
                    Text("Something feels off?")
                        .font(.grotesk(size: 26, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    
                    Text("Your blocks stay in sync with Apple Screen Time. If something seems off, manually reload your blocks to get everything back on track.")
                        .font(.grotesk(size: 17, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineSpacing(4.0)
                        .padding(.horizontal, 44)
                }

                GlassButton {
                    Haptics.feedback(style: .rigid)
                    withAnimation {
                        isReload = true
                    }
                    
                    reloadBlocks()
                    
                    SleepTask.sleep(seconds: 0.55) {
                        withAnimation {
                            showReload = false
                        }
                        isReload = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Reload")
                            .font(.grotesk(.title3, weight: .semibold))
                    }
                }
                .padding(.horizontal, 64)
            }
            .opacity(showReload ? 1 : 0)
            .scaleEffect(showReload ? 1 : 1.2)
            .animation(.smooth, value: showReload)
            .offset(y: -32)
            
            Text("Tap anywhere to dismiss")
                .font(.grotesk(.body, weight: .medium))
                .frame(maxHeight: .infinity, alignment: .bottom)
                .foregroundStyle(.white.opacity(0.65))
                .padding(.bottom)
                .opacity(showReload ? 1.0 : 0.0)
        }
        .fullScreenCover(isPresented: $isFocusSession) {
            FocusSessionView()
        }
        .onChange(of: isFocusSession) { oldValue, newValue in
            if oldValue == true, newValue == false {
                DeviceActivityManager.shared.unblockAllApps(blocks: blocks)
                toastManager.info("Focus Session ended.")
            }
        }
        .onAppear {
            
            // MARK: PERFORM DATABASE MIGRATION - ONE TIME ONLY
            // Add goal entity, add cooldown
            if PERFORM_MIGRATION == false {
                Logger.debug("Performing migration")
                                
                for block in blocks {
                    block.cooldown = 5 * 60 // 5 minutes
                }
                
                do {
                    if let user = vm.user {
                        try CoreDataStack.shared.migrateGoal(user: user)
                    }

                    try CoreDataStack.shared.saveContext()
                    Logger.success("DONE!")
                    PERFORM_MIGRATION = true
                } catch {
                    toastManager.error("There was an error initializing database. Contact support")
                    Logger.error("Error migrating: \(error.localizedDescription)")
                }
            } else {
                Logger.debug("Migration already performed")
            }
        }
        .onAppear {
            checkAuth()
        }
        .overlay {
            #if !targetEnvironment(simulator)
            // If first time user, show onboarding
            if firstTimeUser {
                OBStack()
                    .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
            }
            #endif
        }
        .onChange(of: firstTimeUser) { oldValue, newValue in
            if oldValue == true, newValue == false {
                vm.getUser()
            }
        }
        .onChange(of: superwall.subscriptionStatus) { oldValue, newValue in
            handleSubscriptionChange(oldValue, newValue)
        }
        .overlay {
            Group {
//                if subscriptionEnded {
//                    SubscriptionEndedSheet(blocks: blocks)
//                        .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
//                }
            }
//            .animation(.smooth, value: tutorialShown)
        }
    }
    
    private func checkAuth() {
        guard !firstTimeUser else { return }
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                Logger.success("[Family Controls] Auth granted")
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }
        }
    }
    
    private func applyGroteskFont() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 34)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 17)!]
    }
    
    private func reloadBlocks() {
        for block in blocks {
            if let tokenString = block.appTokenString, let appToken = ApplicationToken.fromRawValue(tokenString) {
                
                // Check if the shield is applied
                let isShieldApplied: Bool = DeviceActivityManager.shared.isCurrentlyShielded(token: appToken)

                // If the shield is on, there wouldn't be any issue
                
                guard !isShieldApplied else {
                    Logger.debug("[RESTORE] Shield is applied, no errors to restore.")
                    return
                }
                
                // We need to check if endTime is passed. If it is, and the shield is still open, we do have a problem to solve.
                guard let endTime = block.openEndTime else {
                    return
                }
                
                guard Date.now > endTime else {
                    Logger.debug("[RESTORE] The shield is currently opened but endTime hasn't passed, no errors to restore.\nEndTime: \(endTime.localTimeZone)\nCurrent Time: \(Date.now.localTimeZone)")
                    return
                }
                
                Logger.debug("[RESTORE] Error found. Restoring...")
                        
                block.isOpen = false
                try? CoreDataStack.shared.saveContext()
                
                DeviceActivityManager.shared.restoreShield(appToken: appToken)
            }
        }
    }
    
    private func handleSubscriptionChange(_ oldValue: SubscriptionStatus, _ newValue: SubscriptionStatus) {
//        // it should only happen if the user is not new (account > 1 day)
//        guard tutorialShown else {
//            Logger.debug("New user, won't udpate blocks based on subscription status")
//            return
//        }
//        
//        if ((oldValue != .inactive) && (oldValue != .unknown)) && ((newValue == .inactive) || (newValue == .unknown)) {
//            subscriptionEnded = true
//            
//            DeviceActivityManager.shared.deactivateAllBlocks(blocks)
//            Logger.debug("BLOCKS DEACTIVATED")
//        }
//        
//        if ((oldValue == .inactive) || (oldValue == .unknown)) && ((newValue != .inactive) && (newValue != .unknown)) {
//            subscriptionEnded = false
//            
//            DeviceActivityManager.shared.activateAllBlocks(blocks)
//            toastManager.info("🎉 Subscription Active • \(blocks.count) Blocks restored")
//            Logger.debug("BLOCKS ACTIVATED")
//        }
    }
    
}

#Preview {
    TabNavView()
        .tint(.primary)
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
        .environmentObject(LocalNotificationManager())
}
