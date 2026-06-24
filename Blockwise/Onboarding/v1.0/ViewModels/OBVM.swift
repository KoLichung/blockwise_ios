//
//  OBVM.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI
import SuperwallKit

final class OBVM: ObservableObject {
    
    @AppStorage(AppStorageKeys.User.name.key) var storedName: String = ""
    @AppStorage(AppStorageKeys.Onboarding.showTutorial.key) var showTutorial: Bool = false
    @AppStorage(AppStorageKeys.Monetization.isSubscribed.key) var isSubscribed: Bool = false

    @Published private var superwall = Superwall.shared
    
    // Welcome screen 3-step progress
    @Published var showWelcomeProgress: Bool = false
    @Published var welcomeProgress: WelcomeProgress = .one
    
    // Progress bar
    @Published var progressBar: CGFloat = 0.0
    @Published var showProgressBar: Bool = false
    
    // Report Progress
    @Published var reportProgress: OBReport = .one
    @Published var showReportBar: Bool = false
    
    // NavigationStack path, to control the page hierarchy
    @Published var path = [Int]()
        
    // Property to avoid multiple taps on nextStep()
    @Published private var isNavigating: Bool = false
    
    // User inputs, used in calculation
    @Published var screenTimeAvg: String = ""
    @Published var age: String = ""
    @Published var estimatedAge: CGFloat = 0.0
    @Published var screenTimePoints: Int = 0
    
    // Report calculation
    @Published var yearsCalc: Int = 0
    @Published var daysCalc: Int = 0
    @Published var yearsBackCalc: Int = 0
    
    // User name
    @Published var username: String = "Steve"
    var firstName: String {
        username
            .split(whereSeparator: { $0.isWhitespace })
            .first
            .map(String.init) ?? username
    }
    
    // Goals
    @Published var screenTimeGoal: TimeInterval = 60 * 60 + 30 * 60 // 1 hour 30 mins by default
    @Published var streakGoal: Int = 0
    
    // Delay between navigation
    let nextPageDelay: TimeInterval = 0.25
    let selectAnswerAnimation: Animation = .snappy(duration: 0.15)
    
    // MARK: - Views (ordered top-first)
    var views: [AnyView] = [
//        AnyView(OBW1()),
//        AnyView(OBW2()),
        AnyView(OB1()),
        AnyView(OB2()),
        AnyView(OB3()),
        AnyView(OB4()),
        AnyView(OB5()),
        AnyView(OB6()),
        AnyView(OBN1()),
        AnyView(OBN3()),
        AnyView(OB7()),
        AnyView(OB8()),
        AnyView(OB9()),
        AnyView(OB10()),
//        AnyView(OB11()),
        AnyView(OB12()),
        AnyView(OB13()),
//        AnyView(OB14()),
        AnyView(OBN4()),
        AnyView(OB15()),
        AnyView(OBN2()),
        AnyView(OB16()),
        AnyView(OBLoading()),
        AnyView(OB17()),
        AnyView(OB18()),
        AnyView(OB19()),
        AnyView(OB20()),
        AnyView(OB21()),
        AnyView(OBReview()),
        AnyView(OB22()),
        AnyView(OBN5()),
//        AnyView(OB23()),
//        AnyView(OBN6()),
//        AnyView(OB23()),
//        AnyView(OBTrialPolicy()),
//        AnyView(OBCommit()),
//        AnyView(OBLetter()),
//        AnyView(OBT1()),
//        AnyView(OBT2()),
//        AnyView(OBT3()),
//        AnyView(OB26()),
//        AnyView(OB27()),
    ]
}

// MARK: - Functions
extension OBVM {
    
    func showPaywall() {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering showPaywall()")
        Logger.debug("")
        
        // Mixpanel
        AnalyticsService.shared.track("Paywall > Seen")
        
        Logger.debug("↓")
        Logger.debug("→ Registering Superwall paywall: 'main_trial_paywall'")
        
        superwall.register(placement: "main_trial_paywall") {
            self.dismissPaywallSuccessfully()
        }
        
        Logger.debug("-----------------------------------------------------------")
    }
    
    func dismissPaywallSuccessfully() {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering dismissPaywallSuccessfully()")
        Logger.debug("")
        Logger.debug("State:")
        Logger.debug("  • Subscription Active: \(superwall.subscriptionStatus.isActive)")
        Logger.debug("")
        
        guard superwall.subscriptionStatus.isActive else {
            Logger.warning("⚠️ Subscription not active - exiting early")
            Logger.debug("-----------------------------------------------------------")
            return
        }

        Logger.success("✅ Paywall dismissed successfully!")
        Logger.debug("")
        
        AnalyticsService.shared.track("Paywall > Converted")
        
        Logger.debug("↓")
        Logger.debug("Updating state:")
        Logger.debug("  • isSubscribed: false → true")
        Logger.debug("  • showTutorial: \(showTutorial) → true")
        
        isSubscribed = true
        showTutorial = true

        Logger.debug("")
        Logger.debug("↓")
        Logger.debug("→ Creating user profile...")
        
        do {
            try createProfile()
            Logger.success("✅ User profile setup completed")
        } catch {
            Logger.error("❌ Failed to create profile: \(error.localizedDescription)")
        }
        
        Logger.debug("-----------------------------------------------------------")
    }

    func createProfile() throws {
        Logger.debug("-----------------------------------------------------------")
        Logger.debug("→ Entering createProfile()")
        Logger.debug("")
        
        let users = CoreDataStack.shared.fetchEntities(for: UserEntity.self)
        
        Logger.debug("State:")
        Logger.debug("  • Existing users count: \(users.count)")
        Logger.debug("")
        
        if users.first != nil {
            Logger.debug("→ User already exists - skipping creation")
            Logger.debug("-----------------------------------------------------------")
        } else {
            Logger.debug("→ Creating new user...")
            Logger.debug("  • Name: \(username)")
            Logger.debug("  • Screen Time Goal: \(screenTimeGoal)")
            Logger.debug("")
            
            try CoreDataStack.shared.createUser(name: username, screenTimeGoal: screenTimeGoal)
            storedName = firstName
            
            Logger.success("✅ User created successfully")
            Logger.debug("-----------------------------------------------------------")
        }
    }

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
    
    func calculateReport() {
        let averageWakingHours: CGFloat = 16.0
        let averageLifeExpectancy: CGFloat = 80.0
        
        // Assuming Z (user age)
        let userAge: CGFloat = estimatedAge
        
        // Remaining life in years
        let remainingLifeYears = averageLifeExpectancy - userAge
        
        // Convert remaining life years into days
        let remainingLifeDays = remainingLifeYears * 365.25 // .25 accounts for leap years
        
        // Assuming X (hours spent on phone per day)
        let hoursSpentPerDay: CGFloat = CGFloat(screenTimePoints)
        
        let hoursSpentPerDayNew: CGFloat = screenTimeGoal / 3600
        let totalPhoneTimeInHoursNew = hoursSpentPerDayNew * (averageLifeExpectancy * 365.25)
        let totalPhoneTimeInYearsNew = totalPhoneTimeInHoursNew / averageWakingHours / 365.0
        
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
        
        let savedYears = Int(totalPhoneTimeInYears - totalPhoneTimeInYearsNew)
        
        yearsCalc = Int(totalPhoneTimeInYears)
        daysCalc = Int(hoursSpentPerDay * 365.25) / 24
        yearsBackCalc = savedYears > 0 ? savedYears : Int(Double(yearsCalc) * 0.6)
        
        // Output the result
        Logger.debug("Total years spent on the phone in remaining life: \(totalPhoneTimeInYears) years")
        Logger.debug("Percentage of remaining life spent on the phone: \(percentageOfRemainingLifeSpentOnPhone)%")
    }
}

// MARK: - OBAnswer
struct OBAnswer: Equatable, Hashable {
    let asset: String
    let title: String
    let points: CGFloat
    
    init(asset: String = "", title: String, points: CGFloat = 0) {
        self.asset = asset
        self.title = title
        self.points = points
    }
}

// MARK: - Welcome progress
enum WelcomeProgress: Int, CaseIterable {
    case one, two, three
}

// MARK: - Report Progress
enum OBReport: Int, CaseIterable {
    case one, two, three
}
