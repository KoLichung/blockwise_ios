//
//  RemoveShield.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import Foundation
import ManagedSettings

extension DeviceActivityManager {
    func removeFromShield(appToken: ApplicationToken) {
        let appTokenSet: Set<ApplicationToken> = [appToken]
        // Remove the apps from the shield
        store.shield.applications?.subtract(appTokenSet)
    }
}
