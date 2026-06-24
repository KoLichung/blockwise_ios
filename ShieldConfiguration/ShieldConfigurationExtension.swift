//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Ivan Sanna on 26/10/24.
//

import ManagedSettingsUI
import ManagedSettings
import SwiftUI
import UIKit
import CoreData

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let scheduleStore = ManagedSettingsStore(named: .init("schedule_store"))
    private let focusStore = ManagedSettingsStore(named: .init("focus_store"))

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        
        if let token = application.token, focusStore.shield.applications?.contains(token) == true {
            return FocusShield(application: application)
        }
        
        if let token = application.token, scheduleStore.shield.applications?.contains(token) == true {
            return ScheduleShield(application: application)
        }
        
        if UserDefaultsManager.shared.isLimitReached() {
            return LimitShield(application: application)
        }
        
        let nextAvailableDate: Date = UserDefaultsManager.shared.getNextAvailability(for: application.token)
        
        if Date.now < nextAvailableDate {
            return CooldownShield(application: application, date: nextAvailableDate)
        }
        
        return DefaultShield(application: application)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
    
}

// MARK: - Configs

extension ShieldConfigurationExtension {
    // Default shield
    private func DefaultShield(application: Application) -> ShieldConfiguration {
        let appName: String = application.localizedDisplayName ?? ""
        let opens: Int = UserDefaultsManager.shared.getOpenCount(for: application.token)
        let usage: TimeInterval = UserDefaultsManager.shared.getTimeUsed(for: application.token)
        
        let subtitleText: String = opens > 0 ? "\(TimeFormatter.display(usage, style: .spaced)) • \(opens) opens today" : "Never used today"
        
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemUltraThinMaterialDark,
            backgroundColor: UIColor.init(Color.black),
            icon: UIImage(resource: .logoForShield),
            title: .init(text: "\(appName) is blocked", color: .white),
            subtitle: .init(text: subtitleText, color: UIColor(white: 1.0, alpha: 0.5)),
            primaryButtonLabel: .init(text: "Not now", color: UIColor(Color(hex: 0x333333))),
            primaryButtonBackgroundColor: UIColor(Color(hex: 0xFFFFFF)),
            secondaryButtonLabel: .init(text: "Open \(appName)", color: .white)
        )
    }
    
    private func CooldownShield(application: Application, date: Date) -> ShieldConfiguration {
        let appName: String = application.localizedDisplayName ?? ""
        
        let subtitleText = "Available again at \(date.formatted(date: .omitted, time: .shortened))"

        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemThickMaterialDark,
            backgroundColor: UIColor.init(Color.indigo),
            icon: UIImage(resource: .logoForCooldown),
            title: .init(text: "\(appName) is recharging", color: .white),
            subtitle: .init(text: subtitleText, color: UIColor(white: 1.0, alpha: 0.5)),
            primaryButtonLabel: .init(text: "Back", color: UIColor(Color(hex: 0x333333))),
            primaryButtonBackgroundColor: UIColor(Color(hex: 0xFFFFFF)),
//            secondaryButtonLabel: .init(text: "Breathing exercise", color: .white)
        )
    }
    
    private func LimitShield(application: Application) -> ShieldConfiguration {
        let appName: String = application.localizedDisplayName ?? ""
        let goal: TimeInterval = UserDefaultsManager.shared.get(forKey: "screenTimeGoal", as: TimeInterval.self) ?? 0
        
        var subtitle: String {
            "Enjoy the rest of your day\n\n\(TimeFormatter.display(goal, style: .short)) / \(TimeFormatter.display(goal, style: .short))"
        }
        
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemThickMaterialDark,
            backgroundColor: UIColor.init(Color.skyBlue),
            icon: UIImage(resource: .logoForLimit),
            title: .init(text: "Today’s limit reached", color: .white),
            subtitle: .init(text: subtitle, color: UIColor(white: 1.0, alpha: 0.5)),
            primaryButtonLabel: .init(text: "Okay", color: UIColor(Color(hex: 0x333333))),
            primaryButtonBackgroundColor: UIColor(Color(hex: 0xFFFFFF)),
            secondaryButtonLabel: .init(text: "Use \(appName) anyway", color: .white)
        )
    }
    
    private func ScheduleShield(application: Application) -> ShieldConfiguration {
        let appName: String = application.localizedDisplayName ?? ""
        let schedule: ScheduleMirror? = UserDefaultsManager.shared.get(forKey: "schedule_mirror_shield", as: ScheduleMirror.self)
        
        let title: String = "\(appName) is blocked by\n\(schedule?.emoji ?? "☘️") \(schedule?.name ?? "unknown")"
        let subtitle: String = "Active until \((schedule?.endTime ?? .now).formatted(date: .omitted, time: .shortened))"
        
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemThickMaterialDark,
            backgroundColor: UIColor.init(Color.orange),
            icon: UIImage(resource: .logoForShield),
            title: .init(text: title, color: .white),
            subtitle: .init(text: subtitle, color: UIColor(white: 1.0, alpha: 0.5)),
            primaryButtonLabel: .init(text: "Okay", color: UIColor(Color(hex: 0x333333))),
            primaryButtonBackgroundColor: UIColor(Color(hex: 0xFFFFFF)),
        )
    }

    private func FocusShield(application: Application) -> ShieldConfiguration {
        let appName: String = application.localizedDisplayName ?? ""
        
        let title: String = "\(appName) is blocked by\nFocus Session"
        let subtitle: String = ""
        
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.systemThickMaterialDark,
            backgroundColor: UIColor.init(Color.orange),
            icon: UIImage(resource: .logoForShield),
            title: .init(text: title, color: .white),
            subtitle: .init(text: subtitle, color: UIColor(white: 1.0, alpha: 0.5)),
            primaryButtonLabel: .init(text: "Okay", color: UIColor(Color(hex: 0x333333))),
            primaryButtonBackgroundColor: UIColor(Color(hex: 0xFFFFFF)),
        )
    }

}
