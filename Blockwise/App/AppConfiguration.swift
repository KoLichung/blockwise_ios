//
//  AppConfiguration.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

// MARK: - Main
struct AppConfiguration {
    static let name = "Blockwise"
    
    static let appIcon = "blockr-icon"
    
    static let supportEmail = "kerlichung@gmail.com"
    
    static let appGroupID = "group.com.kolichung.blockwise.dev"
    
    static let termsURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    
    static let privacyURL = "https://joinblockr.xyz/privacy/"
    
    static let googleDeletionFormURL = "https://forms.gle/LT88mcyrgWs5Zgsc6"
    
    static let tallyFeedbackURL = "https://tally.so/r/Ek1p7q"
}

// MARK: - Keys
extension AppConfiguration {
    struct Keys {
        static let mixPanelKey = "d397042d8a2cb709bce6033b9acb9183"
        
        static let revenueCatApiKey = "appl_HVOtKdfZziDVdbhesvPWSlGcwci"
        
        static let superwallApiKey = "pk_5fbe62cf9ab6d589303b50997d9e08908b8ba0962daf4c9e"
    }
}

// MARK: - Info
extension AppConfiguration {
    struct Info {
        
        /// Returns the official version string of the app, as defined in the project settings.
        ///
        /// This value is sourced from the `CFBundleShortVersionString` key in the Info.plist file.
        ///
        /// - Returns: A string representing the app's version, or "(unknown app version)" if it cannot be retrieved.
        static var version: String {
            return readFromInfoPlist(withKey: "CFBundleShortVersionString") ?? "(unknown app version)"
        }
        
        /// Returns the official build number of the app, as defined in the project settings.
        ///
        /// This value is sourced from the `CFBundleVersion` key in the Info.plist file.
        ///
        /// - Returns: A string representing the app's build number, or "(unknown build number)" if it cannot be retrieved.
        static var build: String {
            return readFromInfoPlist(withKey: "CFBundleVersion") ?? "(unknown build number)"
        }
        
        /// Retrieves and returns values from the Info.plist file associated with a specific key.
        ///
        /// - Parameter key: The key in Info.plist to read the value from.
        /// - Returns: A string representing the value of the specified key, or `nil` if it cannot be found.
        static private func readFromInfoPlist(withKey key: String) -> String? {
            return Bundle.main.infoDictionary?[key] as? String
        }
    }
}
