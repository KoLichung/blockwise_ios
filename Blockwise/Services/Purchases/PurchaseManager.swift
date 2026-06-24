//
//  PurchaseManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI
import SuperwallKit

/// The `PurchaseManager` class is responsible for monitoring the user's subscription status.
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var hasActiveEntitlements: Bool = false
    @Published var isOnFreeTrial: Bool = false
    
    private init() {
        // Set delegate
        Superwall.shared.delegate = self
        
        // Check initial status
        checkSubscriptionStatus()
    }
    
    private func checkSubscriptionStatus() {
        
        switch Superwall.shared.subscriptionStatus {
        case .active(let entitlements):
            Logger.debug("[SUBSCRIPTION STATUS] User has active entitlements: \(entitlements)")
            hasActiveEntitlements = true
        case .inactive:
            Logger.debug("[SUBSCRIPTION STATUS] User is free plan.")
            hasActiveEntitlements = false
        case .unknown:
            Logger.debug("[SUBSCRIPTION STATUS] User subscription status unknown.")
            hasActiveEntitlements = false
        }
    }
}

extension PurchaseManager {
    func superwall(placement: String, completion: @escaping () -> Void) {
        Superwall.shared.register(placement: placement) {
            // This will be fired even if the paywall is dismissed
            // My paywall does not have a X button so it's safe
            // To avoid this, in the paywall settings you can toggle "Gated"
            // So this completion will be only fired if they pay
            completion()
        }
    }
}

extension PurchaseManager: SuperwallDelegate {
    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        switch newValue {
        case .active(let entitlements):
            Logger.debug("[SUPERWALL] User has active entitlements: \(entitlements)")
            hasActiveEntitlements = true
        case .inactive:
            Logger.debug("[SUPERWALL] User is free plan.")
            hasActiveEntitlements = false
        case .unknown:
            Logger.debug("[SUPERWALL] User subscription status unknown.")
            hasActiveEntitlements = false
        }
        
        // Post notification when subscription ends
        if case .inactive = newValue, case .active = oldValue {
            NotificationCenter.default.post(name: .subscriptionDidEnd, object: nil)
        }
    }
}

// MARK: - Notification Handling
extension NSNotification.Name {
    static let subscriptionDidEnd = NSNotification.Name("subscriptionDidEnd")
}

extension NotificationCenter {
    func subscriptionEndedPublisher() -> NotificationCenter.Publisher {
        return self.publisher(for: .subscriptionDidEnd)
    }
}

// MARK: - View Modifier
struct SubscriptionEndedModifier: ViewModifier {
    let handler: () -> ()
    @State private var hasCheckedInitialState = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Handle case where user loads view without active subscription
                if !hasCheckedInitialState {
                    hasCheckedInitialState = true
                    if !PurchaseManager.shared.hasActiveEntitlements {
                        handler()
                    }
                }
            }
            .onReceive(NotificationCenter.default.subscriptionEndedPublisher()) { _ in
                // Handle case where subscription expires during runtime
                handler()
            }
    }
}

extension View {
    func onSubscriptionEnded(_ handler: @escaping () -> ()) -> some View {
        modifier(SubscriptionEndedModifier(handler: handler))
    }
}

// MARK: - OLD PURCHASE MANAGER

//enum Entitlements: String {
//    case pro = "pro"
//}
//
///// The `PurchaseManager` class is responsible for handling subscriptions and trial eligibility
///// within the application. It configures necessary SDKs for managing purchases and monitors
///// the user's subscription status.
//
//@MainActor
//final class PurchaseManager: ObservableObject {
//    static let shared = PurchaseManager()
//    
//    @Published var hasActiveEntitlements: Bool = false
//    @Published var isEligibleForTrial: Bool = false
//    
//    private init() {
////        listenForEntitlementUpdates()
////        isPremium = Superwall.shared.subscriptionStatus == .active(.init())
////        checkTrialEligibility()
////        
////        Logger.debug("[SUBSCRIPTION STATUS] Status: \(Superwall.shared.subscriptionStatus.description)")
//        checkSubscriptionStatus()
//    }
//    
//    private func checkSubscriptionStatus() {
//        switch Superwall.shared.subscriptionStatus {
//        case .active(let entitlements):
//            Logger.debug("[SUBSCRIPTION STATUS] User has active entitlements: \(entitlements)")
//            hasActiveEntitlements = true
//        case .inactive:
//            Logger.debug("[SUBSCRIPTION STATUS] User is free plan.")
//            hasActiveEntitlements = false
//        case .unknown:
//            Logger.debug("[SUBSCRIPTION STATUS] User is inactive.")
//            hasActiveEntitlements = false
//        }
//    }
//    
//    // MARK: - Listen for RevenueCat Updates
//    private func listenForEntitlementUpdates() {
//        Task {
//            for await customerInfo in Purchases.shared.customerInfoStream {
//                let hasPremium = customerInfo.entitlements.active.keys.contains(Entitlements.pro.rawValue)
//                self.hasActiveEntitlements = hasPremium
//            }
//        }
//    }
//    
//    // MARK: - Trial Eligibility
//    func checkTrialEligibility() {
//        Purchases.shared.getOfferings { offerings, error in
//            guard error == nil else {
//                print("❌ Error fetching offerings: \(error!)")
//                return
//            }
//            
//            if let product = offerings?.current?.availablePackages.first?.storeProduct {
//                Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product) { eligibility in
//                    DispatchQueue.main.async {
//                        self.isEligibleForTrial = (eligibility == .eligible)
//                        print("📊 Trial eligibility: \(self.isEligibleForTrial)")
//                    }
//                }
//            } else {
//                print("⚠️ No product found in current offering")
//            }
//        }
//    }
//}
//
//extension PurchaseManager: SuperwallDelegate {
//    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
//        switch newValue {
//        case .active(let entitlements):
//            Logger.debug("[SUBSCRIPTION STATUS] User has active entitlements: \(entitlements)")
//            hasActiveEntitlements = true
//        case .inactive:
//            Logger.debug("[SUBSCRIPTION STATUS] User is free plan.")
//            hasActiveEntitlements = false
//        case .unknown:
//            Logger.debug("[SUBSCRIPTION STATUS] User is inactive.")
//            hasActiveEntitlements = false
//        }
//    }
//}
//
//// MARK: - Notification Handling
//
//extension NSNotification.Name {
//    static let entitlementDidChange = NSNotification.Name("entitlementDidChange")
//}
//
//extension NotificationCenter {
//    func entitlementChangedPublisher() -> NotificationCenter.Publisher {
//        return self.publisher(for: .entitlementDidChange)
//    }
//}
//
//// MARK: View Modifier
//private struct EntitlementChangedModifier: ViewModifier {
//    // Or, change the `Bool` to `Set<Entitlement>` if you want to know which entitlements are active.
//    // This example assumes you're only using one.
//    let handler: (Bool) -> ()
//    
//    func body(content: Content) -> some View {
//        content
//            .onReceive(NotificationCenter.default.entitlementChangedPublisher(),
//                       perform: { _ in
//                switch Superwall.shared.subscriptionStatus {
//                case .active(_):
//                    handler(true)
//                case .inactive:
//                    handler(false)
//                case .unknown:
//                    handler(false)
//                }
//            })
//    }
//}
//
//// MARK: View Extensions
//
//extension View {
//    func onEntitlementChanged(_ handler: @escaping (Bool) -> ()) -> some View {
//        self.modifier(EntitlementChangedModifier(handler: handler))
//    }
//}
//
//// Then, in any view, this modifier will fire when the subscription status changes
//
////struct SomeView: View {
////    @State private var isPro: Bool = false
////
////    var body: some View {
////        VStack {
////            Text("User is pro: \(isPro ? "Yes" : "No")")
////        }
////        .onEntitlementChanged { isPro in
////            self.isPro = isPro
////        }
////    }
////}
