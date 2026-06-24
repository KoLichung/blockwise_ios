//
//  UpdateTransactionHelper.swift
//  ProdApp
//
//  Created by Ivan Sanna on 01/10/24.
//

import SwiftUI

extension UserDefaults {
    /// Get the latest timestamp from all app actors' last timestamps
    /// Only delete transactions before the latest timestamp to ensure that other appActors
    /// can normally obtain unprocessed transactions
    /// Set a 7-day limit. Even if some appActors do not use (no userdefaults created),
    /// it will retain transactions for no more than 7 days
    /// - Parameter appActors: app roles, such as healthnote, widget
    /// - Returns: Date (timestamp), nil return value will process all unprocessed transactions
    func lastCommonTransactionTimestamp(in appActors: [AppActor]) -> Date? {
        // Seven days ago
        let sevenDaysAgo = Date().addingTimeInterval(-604800)
        let lasttimestamps = appActors
            .compactMap {
                lastHistoryTransactionTimestamp(for: $0)
            }
        // All actors have no set value
        guard !lasttimestamps.isEmpty else {return nil}
        let minTimestamp = lasttimestamps.min()!
        // Check if all actors have set values
        guard lasttimestamps.count != appActors.count else {
            // Return the latest timestamp
            return minTimestamp
        }
        // If it has been more than 7 days without receiving values from all actors, return seven days to prevent some actors from never being set
        if minTimestamp < sevenDaysAgo {
            return sevenDaysAgo
        }
        else {
            return nil
        }
    }
    
    /// Get the timestamp of the last processed transaction for the specified appActor
    /// - Parameter appActor: app role, such as healthnote, widget
    /// - Returns: Date (timestamp), nil return value will process all unprocessed transactions
    func lastHistoryTransactionTimestamp(for appActor: AppActor) -> Date? {
        let key = "PersistentHistoryTracker.lastToken.\(appActor.rawValue)"
        return object(forKey: key) as? Date
    }
    
    /// Set the latest transaction timestamp for the specified appActor
    /// - Parameters:
    ///   - appActor: app role, such as healthnote, widget
    ///   - newDate: Date (timestamp)
    func updateLastHistoryTransactionTimestamp(for appActor: AppActor, to newDate: Date?) {
        let key = "PersistentHistoryTracker.lastToken.\(appActor.rawValue)"
        set(newDate, forKey: key)
    }
}
