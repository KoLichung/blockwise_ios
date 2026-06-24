//
//  OBTVM_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/01/26.
//

import SwiftUI
import FamilyControls

final class OBTVM_V2: ObservableObject {
    @AppStorage(AppStorageKeys.User.name.key) var storedName: String = ""
    @AppStorage(AppStorageKeys.Onboarding.isNewUser.key) var isNewUser: Bool = true

    @Published var selection = FamilyActivitySelection(includeEntireCategory: true)

    // Progress bar
    @Published var progressBar: CGFloat = 0.0
    @Published var showProgressBar: Bool = false
        
    // NavigationStack path, to control the page hierarchy
    @Published var path = [Int]()
        
    // Property to avoid multiple taps on nextStep()
    @Published private var isNavigating: Bool = false

    // Delay between navigation
    let nextPageDelay: TimeInterval = 0.25
    let selectAnswerAnimation: Animation = .snappy(duration: 0.15)
    
    // MARK: - Views (ordered top-first)
    var views: [AnyView] = [
        AnyView(OBT1_V2()),
        AnyView(OBT3_V2()),
        AnyView(OBT4_V2()),
        AnyView(OBTrafficSource_V2()),
    ]
}

// MARK: - Functions
extension OBTVM_V2 {
    func nextPage(progressBar value: CGFloat = 0.0) {
        // Avoid multiple taps
        guard !isNavigating else { return }
        isNavigating = true
        
        // Update the navigation path
        path.append(path.count + 1)
        
        // Update the progressbar
        if value > 0.0 {
            progressBar = value
        }
        
        // Reset after x seconds
        SleepTask.sleep(seconds: nextPageDelay + 0.1) {
            self.isNavigating = false
        }
    }
    
    func completeTutorial() throws {
        Logger.debug("Tutorial Completed!")
        
        withAnimation {
            isNewUser = false
        }
        
        // Create block
        if let appToken = selection.applicationTokens.first {
            try CoreDataStack.shared.createBlock(appToken: appToken)
        } else {
            throw NSError(domain: "Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create block"])
        }
    }
}
