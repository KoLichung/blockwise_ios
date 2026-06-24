//
//  TabBarView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/12/24.
//

import SwiftUI
import ManagedSettings
import FamilyControls
import SuperwallKit

struct TabBarView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @StateObject var superwall = Superwall.shared
    
//    @AppStorage(AppStorageKeys.firstTimeUser.rawValue) var firstTimeUser: Bool = true
//    @AppStorage(AppStorageKeys.hapticsEnabled.rawValue) var hapticsEnabled: Bool = true
//    
//    @AppStorage(AppStorageKeys.subscriptionEnded.rawValue) var subscriptionEnded: Bool = false
//    @AppStorage(AppStorageKeys.tutorialShown.rawValue) var tutorialShown: Bool = false
//    @AppStorage(AppStorageKeys.showAlarmWarning.rawValue) var showAlarmWarning: Bool = false

    @AppStorage("appearAnimation") var appearAnimation: Bool = false

    @State private var tabSelection: Int = 0
    
    @State private var showUnlockView: Bool = false
    @State private var appToken: ApplicationToken?
    
    var profileTabName: String {
        vm.user?.name ?? "Profile"
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    init() {
        applyGroteskFont()
    }
            
    var body: some View {
        TabView(selection: $tabSelection) {
            HomepageView(blocks: blocks)
                .tabItem {
                    Label("Today", image: "home")
                        .font(.grotesk(.caption, weight: .medium))
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label(profileTabName, systemImage: "person.crop.circle")
                }
                .tag(2)
//                .badge(showAlarmWarning ? (!lnManager.isAlarmAuthGranted ? "!" : nil) : nil)
        }
        .tint(.primary)
//        .sensoryFeedback(.selection, trigger: hapticsEnabled ? tabSelection : nil)
        .overlay {
            #if !targetEnvironment(simulator)
            Group {
//                if !tutorialShown {
//                    OBTutorial()
//                        .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
//                }
            }
//            .animation(.smooth, value: tutorialShown)
            #endif
        }
        .overlay {
            #if !targetEnvironment(simulator)
            // If first time user, show onboarding
//            if firstTimeUser {
//                OBWelcomeOneView()
//                    .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
//            }
            #endif
        }
        .fullScreenCover(isPresented: $showUnlockView) {
            NewUnblockView()
        }
        .fullScreenCover(item: $lnManager.notificationView) { nLink in
            nLink.linkView.view(notificationId: nLink.notificationId)
        }
//        .onChange(of: firstTimeUser) { oldValue, newValue in
//            if oldValue == true, newValue == false {
//                vm.getUser()
//                SleepTask.sleep(seconds: 0.20) {
//                    appearAnimation = true
//                }
//            }
//        }
//        .overlay {
//            Group {
//                if subscriptionEnded {
//                    SubscriptionEndedSheet(blocks: blocks)
//                        .transition(.move(edge: .bottom).combined(with: .offset(y: 64)))
//                }
//            }
//            .animation(.smooth, value: tutorialShown)
//        }
        .onChange(of: scenePhase) {
            showUnlockView = UserDefaultsManager.shared.hasToken()
        }
        .onChange(of: superwall.subscriptionStatus) { oldValue, newValue in
//            handleSubscriptionChange(oldValue, newValue)
        }
    }
    
//    private func handleSubscriptionChange(_ oldValue: SubscriptionStatus, _ newValue: SubscriptionStatus) {
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
    
            
    private func applyGroteskFont() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 34)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 17)!]
    }
}

#Preview {
    TabBarView()
        .environmentObject(LocalNotificationManager())
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
        .environmentObject(PurchaseManager.shared)
}

/*
 
 .fullScreenCover(item: $lnManager.notificationView) { nLink in
     nLink.linkView.view(notificationId: nLink.notificationId)
         .presentationBackground(.thinMaterial)
 }
 
 */

/*
 
 .fullScreenCover(isPresented: $showUnlockView) {
     NewUnlockView(appToken: $appToken)
         .presentationBackground(.thinMaterial)
 }
 .onChange(of: scenePhase) { oldValue, newValue in
     observeScenePhase()
 }
 
 private func observeScenePhase() {
     // Get the defer status
     if UserDefaultsManager.shared.deferValue() {
         showUnlockView = true
     }
     
     appToken = UserDefaultsManager.shared.deferValueApp()
 }

 */
