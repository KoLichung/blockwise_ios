//
//  OBVM_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

@MainActor
final class OBVM_V2: ObservableObject {
    @AppStorage(AppStorageKeys.Onboarding.hasFinishedOnboarding.key) var hasFinishedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.User.name.key) var storedName: String = ""

    @Published var path = [Int]()
    
    /// Property to avoid multiple taps on *nextStep*
    @Published private var isNavigating: Bool = false
    
    @Published var hasTriedBefore: Bool = false
    
    @Published var showProgressBar: Bool = false
    @Published var progressBarValue: CGFloat = 0.0
    
    @Published var showProgressBarTwo: Bool = false
    @Published var progressBarValueTwo: CGFloat = 0.0
    
    @Published var estimatedScreenTime: CGFloat = 0.0
    
    @Published var ageForSuperwall: String = ""
    
    @Published var name: String = "" {
        didSet {
            // Each time 'name' is updated, is automatically saved to 'storedName'
            storedName = name
        }
    }
    
    @Published var estimatedAge: CGFloat = 0.0
    
    @Published var yearsSpent: Int = 0
    @Published var yearsSaved: Int = 0
    @Published var monthsNextYear: Int = 0
    
    @Published var screenTimeGoal: TimeInterval = 0.0
    
    // Track progress for each page
    private var progressHistory: [CGFloat] = [0.0]
    
    // Track progress for each page
    private var progressHistoryTwo: [CGFloat] = [0.0]

    let nextPageDelay: TimeInterval = 0.25
    let selectAnswerAnimation: Animation = .snappy(duration: 0.15)
    
    var views: [AnyView] = [
        AnyView(OBWelcome_V2()),
        AnyView(OB1_V2()),
        AnyView(OB2_V2()),
        AnyView(OB3_V2()),
        AnyView(OB4_V2()),
        AnyView(OB5_V2()),
        AnyView(OB6_V2()),
        AnyView(OB15_V2()),
        AnyView(OB13_V2()),
        AnyView(OB14_V2()),
        AnyView(OB18_V2()),
//        AnyView(OB19_V2()),
//        AnyView(OB20_V2()),
        AnyView(OB7_V2()),
        AnyView(OBLoading_V2()),
        AnyView(OB1Report_V2()),
        AnyView(OB2Report_V2()),
        AnyView(OB3Report_V2()),
        AnyView(OB17_V2()),
        AnyView(OB8_V2()),
        AnyView(OB16_V2()),
        AnyView(OBReview_V2()),
        AnyView(OB9_V2()),
//        AnyView(OB11_V2()),
        AnyView(OBPermission_V2()),
        AnyView(OBCongrats_V2()),
        AnyView(OB10_V2()),
    ]
}

extension OBVM_V2 {
    func nextPage(progress value: CGFloat = 0.0, progressTwo valueTwo: CGFloat = 0.0) {
        let nextPageDelay: TimeInterval = 0.35
        
        guard !isNavigating else { return }
        isNavigating = true
        
        path.append(path.count + 1)
        
        if value > 0.0 {
            progressBarValue = value
            progressHistory.append(value)
        }
        
        if valueTwo > 0.0 {
            progressBarValueTwo = valueTwo
            progressHistoryTwo.append(valueTwo)
        }
        
        SleepTask.sleep(seconds: nextPageDelay) {
            self.isNavigating = false
        }
    }
    
    func previousPage() {
        guard !path.isEmpty else { return }
        path.removeLast()
        
        // Remove current progress and revert to previous
        if progressHistory.count > 1 {
            progressHistory.removeLast()
            progressBarValue = progressHistory.last ?? 0.0
        }
        
        // Remove current progress and revert to previous
        if progressHistoryTwo.count > 1 {
            progressHistoryTwo.removeLast()
            progressBarValueTwo = progressHistoryTwo.last ?? 0.0
        }
        
        if progressBarValue < 0.2 {
            showProgressBar = false
        }
        
        if progressBarValueTwo < 0.4 {
            showProgressBarTwo = false
        }
    }
    
    func superwall(_ completion: @escaping () -> Void) {
        Logger.debug("[SUBSCRIPTION] Showing placement: \(placementFromAge)")
        PurchaseManager.shared.superwall(placement: placementFromAge) {
            completion()
        }
    }
    
    private var placementFromAge: String {
        switch ageForSuperwall {
        case "Under 18": return "trial_under_18"
        case "18-24": return "trial_18_to_24"
        case "25-34": return "trial_25_to_34"
        case "35-44": return "trial_35_to_44"
        case "45-54": return "trial_45_to_54"
        case "55+": return "trial_over_55"
        default: return "trial_under_18"
        }
    }
    
    func calculateGoodBadNews() {
        let avgWakingHours: Int = 16
        let avgLifeExpectancy: Int = 80
        
//        let currentAge: CGFloat = estimatedAge
        let currentScreenTime: CGFloat = estimatedScreenTime // assuming this is in hours per day
        
        let percentOfScreenTimeReducedWithApp: CGFloat = 0.5 // -> With our app they can reduce their screen time by up to 50%
        
        // Calculate total screen time hours across entire life (from 14* to 80)
        // *14 is the estimated age someone started using a phone
        let totalLifetimeDays = CGFloat(avgLifeExpectancy - 14) * 365
        
        // Calculate total screen time hours across remaining life
//        let totalLifetimeDays = CGFloat(CGFloat(avgLifeExpectancy) - currentAge) * 365
        
        let totalScreenTimeHoursWithCurrent = totalLifetimeDays * currentScreenTime
        
        // Calculate total screen time hours with reduced usage
        let reducedScreenTime = currentScreenTime * (1 - percentOfScreenTimeReducedWithApp)
        let totalScreenTimeHoursWithReduced = totalLifetimeDays * reducedScreenTime
        
        // Convert to years (divide by hours in a waking year)
        let hoursInWakingYear = 365 * avgWakingHours
        
        let totalScreenTimeInYearsInLifetimeWithCurrentScreenTime: Int = Int(totalScreenTimeHoursWithCurrent / CGFloat(hoursInWakingYear))
        let totalScreenTimeInYearsInLifetimeWithReducedScreenTime: Int = Int(totalScreenTimeHoursWithReduced / CGFloat(hoursInWakingYear))
        
        // Calculate years saved
        let totYearsSaved = totalScreenTimeInYearsInLifetimeWithCurrentScreenTime - totalScreenTimeInYearsInLifetimeWithReducedScreenTime
        
        // NEW: Calculate months in the next year
        let hoursInNextYear = currentScreenTime * 365
        let monthsInNextYear = hoursInNextYear / 730 // 730 hours = average month (365 days / 12 months * 24 hours)
        
        yearsSpent = totalScreenTimeInYearsInLifetimeWithCurrentScreenTime
        yearsSaved = totYearsSaved
        monthsNextYear = Int(monthsInNextYear.rounded()) // Store this as a property
        
        print("You're on track to spend: \(totalScreenTimeInYearsInLifetimeWithCurrentScreenTime) years of your life on screens")
        print("That's almost \(monthsNextYear) months in 2026 alone")
        print("With reduced screen time: \(totalScreenTimeInYearsInLifetimeWithReducedScreenTime) years")
        print("You could save: \(yearsSaved) years of your life!")
    }
}
