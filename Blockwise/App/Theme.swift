//
//  Theme.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/02/26.
//

import SwiftUI

enum Theme {
    @AppStorage(AppStorageKeys.Settings.appTheme.key)
    private static var appTheme: AppTheme = .automatic
    
    @AppStorage("darkModeVariant")
    private static var darkModeVariant: DarkModeVariant = .dim
    
    // Convenience properties
    static var foregroundC: Color {
        return darkModeVariant == .midnight ? .foregroundCMidnight : .foregroundC
    }
    
    static var backgroundC: Color {
        return darkModeVariant == .midnight ? .backgroundCMidnight : .backgroundC

    }
    
    static var textC: Color {
        return .textC
    }
}

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case automatic = "automatic"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .automatic: nil
        }
    }
}

enum DarkModeVariant: String, CaseIterable {
    case dim = "dim"
    case midnight = "midnight"
    
    var displayName: String {
        switch self {
        case .dim: return "Dim"
        case .midnight: return "Midnight"
        }
    }
}
