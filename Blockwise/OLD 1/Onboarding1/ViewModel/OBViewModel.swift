//
//  OBUserViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI
import Mixpanel
import FamilyControls

struct OBOption: Equatable, Hashable {    
    let emoji: String
    let label: String
    let value: CGFloat
}

enum SetupPhase: Int, CaseIterable {
    case one = 0, two, three
}

enum ReportPhase: Int, CaseIterable {
    case one = 0, two, three
}

@MainActor
final class OBUserViewModel: ObservableObject {
    @AppStorage(AppStorageKeys.Onboarding.isNewUser.rawValue) var firstTimeUser: Bool = true
    @AppStorage(AppStorageKeys.Monetization.isSubscribed.rawValue) var paywallReached: Bool = false
//    @AppStorage(AppStorageKeys.discountSeen.rawValue) var discountSeen: Bool = false
    @AppStorage("age_group") var ageGroup: String = ""

    @Published var path: [Int] = []
    @Published var selections: [CGFloat] = []
    @Published var hideTabbar: Bool = false
    @Published var progress: CGFloat = 0.0
    @Published private var lastGoneBack: Date?
    
    @Published var showPaywall: Bool = false
    
    @Published var sumOfUserValues: CGFloat = 0.0 {
        didSet {
            Logger.debug("\(oldValue), \(sumOfUserValues)")
            oldSumOfValues = oldValue
        }
    }
    let sumOfNormalValues: CGFloat = 16.0 // 16 is the least amount of points, 64 is the max.
    
    @Published var oldSumOfValues: CGFloat = 0.0
    
    @Published var showReportProgress: Bool = false
    @Published var showSetupProgress: Bool = false
    @Published var currentReportProgress: ReportPhase = .one
    @Published var currentSetupProgress: SetupPhase = .one
    
    @Published var screenTimeAvg: CGFloat = 0.0
    @Published var estimatedAge: CGFloat = 0.0
    @Published var yearsUsingPhone: CGFloat = 0.0
    @Published var percentOfLife: CGFloat = 0.0
    
    @Published var screenTimeGoal: TimeInterval = 0.0

    @Published var isAdvancing: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var showChevronHint: Bool = false
    @Published var error: Bool = false

    @Published var username: String = ""
    
    var firstName: String {
        username.components(separatedBy: " ").first ?? username
    }
    
    let actionDelay: TimeInterval = 0.25
    
    let progressSteps: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0] // 10 screens
    private let delay: TimeInterval = 0.5
    
    func goToNextStep(step: Int) {
        path.append(step) // Add the next step to the path
        updateProgress()
    }
    
    func nextStep(step: Int? = nil) {
        
        if let step {
            // For testing purposes
            let last = path.last ?? 0
            if step > last {
                path.append(contentsOf: (last + 1)...step)
            } else {
                path.append(step)
            }
            // End test
        } else {
            path.append(path.count + 1)
        }

        updateProgress()
        
        SleepTask.sleep(seconds: 0.15) { // added a little delay to prevent double taps
            self.isAdvancing = false
        }
    }
    
    func goToPreviousStep() {
        // Ensure at least 0.5 second has passed since the last back navigation
        if let lastGoneBack, Date().timeIntervalSince(lastGoneBack) < delay {
            return
        }

        if !path.isEmpty {
            lastGoneBack = Date() // Update the last back navigation timestamp
            path.removeLast() // Remove the last step to go back
            updateProgress()
        }
        
        sumOfUserValues = oldSumOfValues
    }
    
    private func updateProgress() {
        guard let currentStep = path.last else {
            progress = 0.0 // Reset progress if no steps are left
            return
        }
        
        if progressSteps.indices.contains(currentStep - 1) {
            progress = progressSteps[currentStep - 1] // Map step to progressSteps (1-based index to 0-based)
        } else {
            progress = 0.0 // Default to 0 if out of bounds
        }
    }
    
    private func setLoading(_ value: Bool) {
        withAnimation(.smooth(duration: 0.25)) {
            isLoading = value
        }
    }
    
    private func setChevronVisibility(_ value: Bool) {
        withAnimation(.smooth(duration: 0.25)) {
            showChevronHint = value
        }
    }
    
    func requestAuthorization(completion: @escaping () -> Void, errorCompletion: @escaping (Error) -> Void) {
        setLoading(true)
        
        SleepTask.sleep(seconds: 1.55) {
            self.setChevronVisibility(true)
        }

        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                self.setLoading(false)
                self.setChevronVisibility(false)
                completion()
            } catch {
                Logger.error(error.localizedDescription)
                self.error = true
                self.setLoading(false)
                self.setChevronVisibility(false)
                errorCompletion(error)
            }
        }
    }
    
    func calculate() {
        let averageWakingHours: CGFloat = 16.0
        let averageLifeExpectancy: CGFloat = 80.0
        
        // Assuming Z (user age)
        let userAge: CGFloat = estimatedAge
        
        // Remaining life in years
        let remainingLifeYears = averageLifeExpectancy - userAge
        
        // Convert remaining life years into days
        let remainingLifeDays = remainingLifeYears * 365.25 // .25 accounts for leap years
        
        // Assuming X (hours spent on phone per day)
        let hoursSpentPerDay: CGFloat = screenTimeAvg
        
        
        // Total hours spent on the phone in remaining life
        let remTotalPhoneTimeInHours = hoursSpentPerDay * remainingLifeDays
        
        // Convert total phone time to years, using 16 waking hours per day
        let remTotalPhoneTimeInYears = remTotalPhoneTimeInHours / averageWakingHours / 365.0

        
        // Total hours spent on the phone in life
        let totalPhoneTimeInHours = hoursSpentPerDay * (averageLifeExpectancy * 365.25)
        
        // Convert total phone time to years, using 16 waking hours per day
        let totalPhoneTimeInYears = totalPhoneTimeInHours / averageWakingHours / 365.0
        
        
        // Calculate the percentage of remaining life spent on the phone
        let percentageOfRemainingLifeSpentOnPhone = (remTotalPhoneTimeInYears / remainingLifeYears) * 100
        
        yearsUsingPhone = totalPhoneTimeInYears
        percentOfLife = percentageOfRemainingLifeSpentOnPhone
        
        // Output the result
        Logger.debug("Total years spent on the phone in remaining life: \(totalPhoneTimeInYears) years")
        Logger.debug("Percentage of remaining life spent on the phone: \(percentageOfRemainingLifeSpentOnPhone)%")
    }
    
    func createUser() throws {
        let users = CoreDataStack.shared.fetchEntities(for: UserEntity.self)
        if let user = users.first {
            // do nothing
            Logger.debug("User found: \(String(describing: user.name))")
        } else {
            try CoreDataStack.shared.createUser(name: username, screenTimeGoal: screenTimeGoal)
            Logger.debug("Creating user...\nName: \(username)\nScreen time goal:\(screenTimeGoal)")
        }
    }
    
    func mixPanelTrack(name: String, properties: [String: String]? = nil) {
        Mixpanel.mainInstance().track(event: name, properties: properties)
    }

}

