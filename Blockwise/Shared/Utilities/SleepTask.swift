//
//  SleepTask.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import Foundation

enum SleepTask {
    /// Delays the execution of a closure for a specified number of seconds.
    ///
    /// - Parameters:
    ///   - seconds: The number of seconds to delay the execution.
    ///   - queue: The `DispatchQueue` on which to execute the closure. The default value is `.main`.
    ///   - action: The closure to be executed after the delay.
    static func sleep(seconds: TimeInterval, on queue: DispatchQueue = .main, action: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + seconds) {
            action()
        }
    }
}
