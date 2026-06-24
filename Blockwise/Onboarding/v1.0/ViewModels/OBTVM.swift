//
//  OBTVM.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/01/26.
//

import SwiftUI
import FamilyControls

final class OBTVM: ObservableObject {
    @AppStorage(AppStorageKeys.User.name.key) var storedName: String = ""
    
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
        AnyView(OBT1()),
        AnyView(OBT7()),
        AnyView(OBT2()),
//        AnyView(OBT3()),
        AnyView(OBT4()),
        AnyView(OBT5()),
        AnyView(OBT6()),
    ]
}

// MARK: - Functions
extension OBTVM {
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
}
