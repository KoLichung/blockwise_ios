//
//  AnalyticsService.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/01/26.
//

import Foundation
import Mixpanel

/// Centralized analytics service for tracking events across the app
final class AnalyticsService {
    
    // MARK: - Singleton
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Types
    enum TrackingMode {
        case once
        case multiple
    }
    
    // MARK: - Configuration
    #if DEBUG
    let service: String = "🟣 MIXPANEL (🐞 DEBUG)"
    #else
    let service: String = "🟣 MIXPANEL"
    #endif
    
    // MARK: - UserDefaults Key
    private let trackedOnceKey = "analytics_tracked_once_events"
    
    func configure() {
        #if DEBUG
        Logger.debug("[ANALYTICS] [\(service)]: Events logged only")
        #else
        let token = AppConfiguration.Keys.mixPanelKey
        Mixpanel.initialize(token: token)
        Logger.debug("[ANALYTICS] [\(service)]: Initialized")
        #endif
    }
    
    // MARK: - Event Tracking
    
    /// Track an analytics event
    /// - Parameters:
    ///   - event: Event name
    ///   - properties: Optional dictionary of event properties
    ///   - mode: Whether to track once or multiple times (default: .once)
    func track(_ event: String, properties: [String: String]? = nil, mode: TrackingMode = .once) {
        // If mode is .once, check if already tracked
        if mode == .once {
            if hasBeenTracked(event) {
                Logger.debug("[ANALYTICS] [\(service)]: \(event) - 🟡 Skipping (already tracked)")
                return
            }
            markAsTracked(event)
        }
        
        #if DEBUG
        if let properties = properties {
            Logger.debug("[ANALYTICS] [\(service)]: \(event) | Properties: \(properties)")
        } else {
            Logger.debug("[ANALYTICS] [\(service)]: \(event)")
        }
        #else
        Logger.debug("[ANALYTICS] [\(service)]: Tracked: \(event)")
        Mixpanel.mainInstance().track(event: event, properties: properties)
        #endif
    }
    
    // MARK: - Private Helpers
    
    private func hasBeenTracked(_ event: String) -> Bool {
        let trackedEvents = UserDefaults.standard.stringArray(forKey: trackedOnceKey) ?? []
        return trackedEvents.contains(event)
    }
    
    private func markAsTracked(_ event: String) {
        var trackedEvents = UserDefaults.standard.stringArray(forKey: trackedOnceKey) ?? []
        trackedEvents.append(event)
        UserDefaults.standard.set(trackedEvents, forKey: trackedOnceKey)
    }
}
