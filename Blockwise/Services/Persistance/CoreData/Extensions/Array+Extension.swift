//
//  Array+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/12/24.
//

import Foundation
import CoreData
import SwiftUI

extension BlockEntity {
    var records: [RecordEntity] {
        self.recordRelationship?.allObjects as? [RecordEntity] ?? []
    }
}

extension UserEntity {
    var goalsHistory: [GoalEntity] {
        self.goals?.allObjects as? [GoalEntity] ?? []
    }
}

extension Array where Element == RecordEntity {
    
    /// Sorts the records by timestamp in descending order (most recent first)
    func sortedByMostRecent() -> [RecordEntity] {
        return self.sorted { (record1, record2) in
            guard let date1 = record1.timestamp, let date2 = record2.timestamp else {
                return false // Keep invalid or missing timestamps at the end
            }
            return date1 > date2
        }
    }
    
    /// Filters records that match a specific day (ignores time components)
    /// - Parameter day: The target day to filter by
    func filtered(by day: Date) -> [RecordEntity] {
        let calendar = Calendar.current
        return self.filter { record in
            guard let timestamp = record.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: day)
        }
    }
}
