//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Ivan Sanna on 26/10/24.
//

import Foundation
import ActivityKit
import ManagedSettings
import UIKit
import SwiftUI
import MobileCoreServices

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)

        case .secondaryButtonPressed:
            
            openParentApp()
            UserDefaultsManager.shared.setToken(token: application, value: true)

            completionHandler(.defer)

        @unknown default:
            fatalError()
        }
    }
    
    private func handlePrimaryButtonPressed(for appToken: ApplicationToken) {
        
//        Task {
//            // Run your intent
//            _ = try? await OpenBlockrIntent().perform()
//        }

        //        Step 1: Update Shield Status
//                UserDefaultsManager.shared.defer(with: applicationToken, value: true)
        
        //         Step 2: Send Notification with Link
        //        sendNotification(applicationToken)
        
        //         Step 3: Reset Shield Status
        //        Task {
        //            try? await Task.sleep(nanoseconds: 1_000_000_000)
        //            UserDefaultsManager.shared.s
        
        
        // Update shield status
        
        
        // Send notification with link
        sendNotification(appToken)
    }
    
    private func sendNotification(_ appToken: ApplicationToken) {
        Task {
            let identifier = UUID().uuidString
            
            var notification = LocalNotification(
                identifier: identifier,
                title: "Tap to set duration",
                body: "",
                timeInterval: 0.025,
                repeats: false,
                timeSensitive: true
            )
            
            notification.userInfo = ["link_key" : LinkView.unlock.rawValue]
            
            /// The app will be retrieved with this notification ID
            UserDefaultsManager.shared.set(appToken, forKey: identifier)
            
            await LocalNotificationManager.shared.schedule(localNotification: notification)
        }
    }
}

extension ShieldActionExtension {
    // GPT function to open parent app
    
    /// Decode a Base64-encoded string
    func decode(_ encoded: String) -> String {
        guard let data = Data(base64Encoded: encoded),
              let decoded = String(data: data, encoding: .utf8) else {
            return ""
        }
        return decoded
    }

    func openParentApp() {
        Task {
            let encodedClassName = "TFNBcHBsaWNhdGlvbldvcmtzcGFjZQ=="
            let encodedSelector = "b3BlbkFwcGxpY2F0aW9uV2l0aEJ1bmRsZUlEOg=="

            let className = decode(encodedClassName)
            let selectorName = decode(encodedSelector)

            if let workspaceClass = NSClassFromString(className) as? NSObject.Type,
               let workspace = workspaceClass.perform(NSSelectorFromString("defaultWorkspace"))?.takeUnretainedValue() {
                
                let selector = NSSelectorFromString(selectorName)
                if workspace.responds(to: selector) {
                    let _ = workspace.perform(selector, with: "com.ivansanna.ProductionAppBoundify")
                    print("Attempted to open app")
                }
            }
        }
    }
}
