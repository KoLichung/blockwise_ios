//
//  AddToShield.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import SwiftUI
import ManagedSettings

extension DeviceActivityManager {
    /// Adds an application token to the activity shield.
    ///
    /// This method ensures that the specified application token is included in the shield. If the shield is
    /// currently uninitialized (`nil`), the method initializes it with the provided token. If the shield already
    /// contains a set of application tokens, the new token will be added to the existing set.
    ///
    /// - Parameter appToken: The `ApplicationToken` representing the application to be added to the shield.
    ///
    /// - Important:
    ///   - This method ensures that `store.shield.applications` is properly initialized before attempting to add to it.
    ///   - A runtime crash will occur if `.formUnion` is called on a `nil` set, so this method prevents that scenario.
    ///
    /// - Example:
    ///   ```
    ///   let appToken: ApplicationToken = ...
    ///   try deviceActivityManager.addToShield(appToken: appToken)
    ///   ```
    func addToShield(appToken: ApplicationToken) {
        // Wrap the token in a Set for compatibility
        let appTokenSet: Set<ApplicationToken> = [appToken]
        
        if store.shield.applications == nil {
            // Initialize the shield if it is nil
            store.shield.applications = appTokenSet
            Logger.success("🔹 Shield is empty. The app has been ASSIGNED to the shield.")
        } else {
            // Add to the existing shield
            store.shield.applications?.formUnion(appTokenSet)
            Logger.success("🔸 Shield is populated. The app has been ADDED to the shield.")
        }
    }
}
