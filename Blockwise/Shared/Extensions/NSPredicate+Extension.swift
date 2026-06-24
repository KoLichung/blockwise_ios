//
//  NSPredicate+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 05/02/26.
//

import Foundation

// In a utilities file
extension NSPredicate {
    static func today(for key: String = "timestamp") -> NSPredicate {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                          key, start as CVarArg,
                          key, end as CVarArg)
    }
    
    static func dateRange(for key: String = "timestamp", from: Date, to: Date) -> NSPredicate {
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                          key, from as CVarArg,
                          key, to as CVarArg)
    }
}

/*
 
 // Usage
 @FetchRequest(sortDescriptors: [], predicate: .today(for: "timestamp"))
 private var todaysRecords: FetchedResults<RecordEntity>

 @FetchRequest(sortDescriptors: [], predicate: .today(for: "date"))
 private var todaysBlocks: FetchedResults<BlockEntity>
 
 */
