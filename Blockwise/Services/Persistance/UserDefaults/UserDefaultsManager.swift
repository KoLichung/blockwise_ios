//
//  UserDefaultsManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import Foundation
import ManagedSettings

/// A singleton manager for handling UserDefaults operations.
///
/// This class provides methods to save and load Codable objects to and from UserDefaults,
/// specifically designed to work with a specified app group identifier. It includes
/// methods for managing activity selections, unlock actions, shield statuses, and notification tokens.
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    // UserDefaults instance for the app group
    let userDefault = UserDefaults(suiteName: AppConfiguration.appGroupID)
}

// MARK: Generic Set Function
extension UserDefaultsManager {
    /// Sets a Codable object to UserDefaults for a specified key.
    ///
    /// - Parameters:
    ///   - object: The object to be saved. Must conform to `Codable`.
    ///   - key: The key under which the object will be stored.
    internal func `set`<T: Codable>(_ object: T?, forKey key: String) {
        guard let userDefault else { return }
        
        if let object = object, let encodedData = try? JSONEncoder().encode(object) {
            userDefault.setValue(encodedData, forKey: key)
        } else {
            Logger.error("Failed to encode object")
        }
    }
}

// MARK: Generic Get Function
extension UserDefaultsManager {
    /// Loads a Codable object from UserDefaults for a specified key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the object to load.
    ///   - type: The type of the object to decode.
    /// - Returns: The decoded object if successful; otherwise, `nil`.
    internal func `get`<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let userDefault else { return nil }
        
        guard let data = userDefault.data(forKey: key) else {
            Logger.error("Failed to find data of type: [\(type)], for key: “\(key)“")
            return nil
        }
        
        do {
            let decodedObject = try JSONDecoder().decode(type, from: data)
            return decodedObject
        } catch {
            Logger.error("Failed to decode object of type: [\(type)]: \(error.localizedDescription), for key: “\(key)“")
        }
        
        return nil
    }

}

extension UserDefaultsManager {
    func setNextAvailability(for appToken: ApplicationToken, date: Date) {
        guard let tokenString = appToken.string else { return }
        set(date, forKey: "next_availability_\(tokenString)")
    }
    
    func getNextAvailability(for appToken: ApplicationToken?) -> Date {
        guard let tokenString = appToken?.string else { return .now }
        return get(forKey: "next_availability_\(tokenString)", as: Date.self) ?? .now
    }
}

extension UserDefaultsManager {
    func isLimitReached(on date: Date = .now) -> Bool {
        let prefix = "is_limit_reached_on_date_"
        let key = "\(prefix)\(UserDefaultsManager.dateString(for: date))"
        return get(forKey: key, as: Bool.self) ?? false
    }
    
    func setLimitReached(value: Bool, on date: Date = .now) {
        let prefix = "is_limit_reached_on_date_"
        let key = "\(prefix)\(UserDefaultsManager.dateString(for: date))"
        set(value, forKey: key)
        removeOldKeys(for: prefix)
    }
}

extension UserDefaultsManager {
    
    // MARK: - Minute Pass Management
    
    /// Marks a minute pass as used for the given app token on the current day
    func useMinutePass(for appToken: ApplicationToken) {
        guard let key = makePassKey(for: appToken) else {
            assertionFailure("Invalid app token - cannot mark pass as used")
            return
        }
        set(true, forKey: key)
        cleanupIfNeeded()
    }
    
    /// Checks if a minute pass has been used for the given app token today
    func hasUsedPass(for appToken: ApplicationToken) -> Bool {
        guard let key = makePassKey(for: appToken) else {
            return false
        }
        return get(forKey: key, as: Bool.self) ?? false
    }
    
    // MARK: - Private Implementation
    
    private func makePassKey(for appToken: ApplicationToken) -> String? {
        guard let tokenString = appToken.string else {
            return nil
        }
        
        let dateString = UserDefaultsManager.dateString(for: .now)
        return "pass_used|\(tokenString)|\(dateString)"
    }
    
    private func cleanupIfNeeded() {
        let lastCleanupKey = "pass_cleanup_last_run"
        let now = Date.now
        
        // Only run cleanup once per day
        if let lastCleanup = get(forKey: lastCleanupKey, as: Date.self),
           Calendar.current.isDate(lastCleanup, inSameDayAs: now) {
            return
        }
        
        // Mark cleanup as run
        set(now, forKey: lastCleanupKey)
        
        // Remove records older than 7 days
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let passKeys = allKeys.filter { $0.hasPrefix("pass_used|") }
        
        for key in passKeys {
            let components = key.split(separator: "|")
            guard components.count == 3,
                  let dateString = components.last,
                  let recordDate = dateFromString(String(dateString)) else {
                continue
            }
            
            if recordDate < cutoffDate {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
}

// MARK: - Per-App Daily Stats
extension UserDefaultsManager {
    
    // MARK: Keys
    
    private enum StatType: String {
        case openCount  = "open_count"
        case timeUsed   = "time_used"
        
        func key(for tokenString: String, on date: Date) -> String {
            "\(tokenString)_\(UserDefaultsManager.dateString(for: date))_\(rawValue)"
        }
    }
    
    private static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: Open Count
    
    func getOpenCount(for appToken: ApplicationToken?, on date: Date = .now) -> Int {
        guard let tokenString = appToken?.string else { return 0 }
        return get(forKey: StatType.openCount.key(for: tokenString, on: date), as: Int.self) ?? 0
    }
    
    func incrementOpenCount(for appToken: ApplicationToken, on date: Date = .now) {
        guard let tokenString = appToken.string else { return }
        let key = StatType.openCount.key(for: tokenString, on: date)
        set((get(forKey: key, as: Int.self) ?? 0) + 1, forKey: key)
        removeOldKeys(for: StatType.openCount.rawValue)
    }
    
    func resetOpenCount(for appToken: ApplicationToken, on date: Date = .now) {
        guard let tokenString = appToken.string else { return }
        set(0, forKey: StatType.openCount.key(for: tokenString, on: date))
    }
    
    func decrementOpenCount(for appToken: ApplicationToken, on date: Date = .now) {
        guard let tokenString = appToken.string else { return }
        let key = StatType.openCount.key(for: tokenString, on: date)
        let current = get(forKey: key, as: Int.self) ?? 0
        set(max(0, current - 1), forKey: key)
        removeOldKeys(for: StatType.openCount.rawValue)
    }
    
    // MARK: Time Used
    
    func getTimeUsed(for appToken: ApplicationToken?, on date: Date = .now) -> TimeInterval {
        guard let tokenString = appToken?.string else { return 0 }
        return get(forKey: StatType.timeUsed.key(for: tokenString, on: date), as: TimeInterval.self) ?? 0
    }
    
    func addTimeUsed(for appToken: ApplicationToken, duration: TimeInterval, on date: Date = .now) {
        guard let tokenString = appToken.string else { return }
        let key = StatType.timeUsed.key(for: tokenString, on: date)
        set((get(forKey: key, as: TimeInterval.self) ?? 0) + duration, forKey: key)
        removeOldKeys(for: StatType.timeUsed.rawValue)
    }
    
    // MARK: Cleanup
    
    private func removeOldKeys(for string: String) {
        let today = UserDefaultsManager.dateString(for: .now)
        let tomorrow = UserDefaultsManager.dateString(for: .tomorrow)
        
        UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.contains(string) && !$0.contains(today) && !$0.contains(tomorrow) }
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}

// MARK: Defer Token
extension UserDefaultsManager {
    func setToken(token: ApplicationToken?, value: Bool) {
        set(value, forKey: "defer_value")
        set(token, forKey: "defer_value_app")
    }
    
    func hasToken() -> Bool {
        get(forKey: "defer_value", as: Bool.self) ?? false
    }
    
    func loadAppToken() -> ApplicationToken? {
        get(forKey: "defer_value_app", as: ApplicationToken.self)
    }
}
