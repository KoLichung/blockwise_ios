//
//  Logger.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

enum Logger {
    
    enum LogLevel: String {
        case debug = "🐞 DEBUG"
        case success = "✅ SUCCESS"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
    }

    /// Logs a message at the specified log level.
    /// - Parameters:
    ///   - level: The log level for the message.
    ///   - message: The message to log.
    static func log(_ level: LogLevel, _ message: String) {
        print("[Logger] [\(level.rawValue)] \(message)")
    }
    
    static func debug(_ message: String) {
        log(.debug, message)
    }
    
    static func success(_ message: String) {
        log(.success, message)
    }
    
    static func warning(_ message: String) {
        log(.warning, message)
    }
    
    static func error(_ message: String) {
        log(.error, message)
    }
}
