//
//  AppStorage.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

enum AppStorageKeys {
    enum Onboarding: String {
        case showTutorial = "showTutorial"
        case hasFinishedOnboarding = "hasFinishedOnboarding"
        case isNewUser = "first_time_user"
        
        var key: String { rawValue }
    }
    
    enum Main: String {
        case showDuration = "showDuration"
        
        var key: String { rawValue }
    }
    
    enum Focus: String {
        case showFocus = "showFocus"
        case duration = "duration"
        case startTime = "startTime"
        
        var key: String { rawValue }
    }
    
    enum Monetization: String {
        case isSubscribed = "isSubscribed"
        
        var key: String { rawValue }
    }
    
    enum Settings: String {
        case appTheme = "appTheme"
        case isHapticsEnabled = "isHapticsEnabled"
        
        var key: String { rawValue }
    }
    
    enum User: String {
        case name = "user_name"
        
        var key: String { rawValue }
    }
    
}
