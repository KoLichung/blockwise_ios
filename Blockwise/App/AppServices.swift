//
//  AppServices.swift
//  Blockwise
//
//  Created by Ivan Sanna on 17/01/26.
//

import UIKit
import SwiftUI
import Mixpanel
import RevenueCat
import SuperwallKit
import FamilyControls

enum AppServices {
    static func configure(swDelegate: SWDelegate) {
        let purchaseController = RCPurchaseController()
        
        Superwall.configure(
            apiKey: AppConfiguration.Keys.superwallApiKey,
            purchaseController: purchaseController
        )
        Superwall.shared.delegate = swDelegate
        
        /// Always configure RevenueCat after Superwall
        Purchases.configure(withAPIKey: AppConfiguration.Keys.revenueCatApiKey)
        
        purchaseController.syncSubscriptionStatus()
                
        AnalyticsService.shared.configure()
    }
    
    static func requestScreenTimeAuthorization() async throws {
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
    }
    
}

@Observable
class SWDelegate: SuperwallDelegate {
    var playHaptic: Bool = false
    
    func handleCustomPaywallAction(withName name: String) {
        if name == "haptic" {
            self.playHaptic.toggle()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            print("🔵 Cold start quick action: \(shortcutItem.type)")
            handleQuickAction(shortcutItem)
        }
        
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = QuickActionSceneDelegate.self  // ← Need this!
        return sceneConfig
    }
    
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        print("🟢 Background quick action (fallback): \(shortcutItem.type)")
        handleQuickAction(shortcutItem)
        completionHandler(true)
    }
    
    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) {
        guard shortcutItem.type == "openGoogleForm" else { return }
        
        if let url = URL(string: AppConfiguration.googleDeletionFormURL) {
            print("🟢 Opening URL: \(url)")
            UIApplication.shared.open(url)
        }
    }
}

class QuickActionSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // Your existing quick action method stays here
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        print("🟡 Scene quick action: \(shortcutItem.type)")
        
        guard shortcutItem.type == "openGoogleForm" else {
            completionHandler(false)
            return
        }
        
        if let url = URL(string: AppConfiguration.googleDeletionFormURL) {
            UIApplication.shared.open(url)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    // ADD THIS NEW METHOD for Universal Links
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        
        print("🔗 Universal Link opened: \(url)")
        // The app will just open to wherever it naturally opens
        // No navigation needed if you just want the main screen
    }
}
