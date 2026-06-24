//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Ivan Sanna on 04/09/25.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivity()
        TimerWidget()
    }
}
