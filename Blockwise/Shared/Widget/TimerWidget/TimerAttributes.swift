//
//  TimerAttributes.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/09/25.
//

import ActivityKit
import SwiftUI

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date
        var endDate: Date
        var entityId: String
    }
}
