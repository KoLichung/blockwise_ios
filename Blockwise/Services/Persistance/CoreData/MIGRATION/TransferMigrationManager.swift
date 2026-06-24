//
//  TransferMigrationManager.swift
//  Blockwise
//
//  Handles data migration when transferring the app via App Store Connect.
//  App Group containers don't survive transfers, so we backup data to the
//  app's own sandbox (Application Support) before the transfer, then restore
//  it into the new App Group container after.
//
//  TIMELINE:
//  1. Ship a pre-transfer update that calls `backupIfNeeded()` on every launch.
//     Wait for most active users to get the backup.
//  2. Transfer the app in App Store Connect.
//  3. Ship a post-transfer update with the new App Group ID that calls
//     `restoreIfNeeded(newAppGroupID:)` before initializing CoreDataStack.
//

import Foundation

final class TransferMigrationManager {
    
    static let shared = TransferMigrationManager()
    private init() {}
    
    // MARK: - Constants
    
    private let dataModelName = "CoreDataModel"
    
    /// Bump this if you ever need to re-run the backup (e.g. schema change before transfer)
    private let backupVersion = 1
    
    // UserDefaults keys (stored in standard UserDefaults, which survives the transfer)
    private enum Keys {
        static let didBackup = "TransferMigration_didBackup"
        static let backupVersion = "TransferMigration_backupVersion"
        static let didRestore = "TransferMigration_didRestore"
    }
    
    // MARK: - Paths
    
    private var backupBaseURL: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TransferMigrationBackup")
    }
    
    private var coreDataBackupURL: URL {
        backupBaseURL.appendingPathComponent("CoreData")
    }
    
    private var userDefaultsBackupURL: URL {
        backupBaseURL.appendingPathComponent("UserDefaults.plist")
    }
    
    // MARK: - SQLite file extensions
    
    /// Core Data / SQLite uses these three files together
    private let sqliteExtensions = ["sqlite", "sqlite-wal", "sqlite-shm"]
    
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - STEP 1: PRE-TRANSFER BACKUP
    // Call this on every app launch BEFORE the transfer.
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Backs up Core Data SQLite files + App Group UserDefaults to Application Support.
    /// Safe to call on every launch — skips if already backed up at current version.
    func backupIfNeeded() {
        let defaults = UserDefaults.standard
        
        // Skip if already backed up at current version
        if defaults.bool(forKey: Keys.didBackup),
           defaults.integer(forKey: Keys.backupVersion) >= backupVersion {
            Logger.debug("[TransferMigration] Backup already complete (v\(backupVersion)), skipping.")
            return
        }
        
        do {
            try backupCoreData()
            try backupUserDefaults()
            
            defaults.set(true, forKey: Keys.didBackup)
            defaults.set(backupVersion, forKey: Keys.backupVersion)
            
            Logger.success("[TransferMigration] Backup complete.")
        } catch {
            Logger.debug("[TransferMigration] Backup failed: \(error.localizedDescription)")
        }
    }
    
    /// Force a fresh backup (e.g. for testing or if you bumped backupVersion)
    func forceBackup() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.didBackup)
        defaults.removeObject(forKey: Keys.backupVersion)
        backupIfNeeded()
    }
    
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - STEP 2: POST-TRANSFER RESTORE
    // Call this on first launch AFTER the transfer,
    // BEFORE initializing CoreDataStack.
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Restores Core Data + UserDefaults from backup into the new App Group container.
    /// Returns `true` if restoration was performed.
    @discardableResult
    func restoreIfNeeded(newAppGroupID: String) -> Bool {
        let defaults = UserDefaults.standard
        
        // Skip if already restored
        guard !defaults.bool(forKey: Keys.didRestore) else {
            Logger.debug("[TransferMigration] Already restored, skipping.")
            return false
        }
        
        // Skip if no backup exists
        guard FileManager.default.fileExists(atPath: coreDataBackupURL.path) else {
            Logger.debug("[TransferMigration] No backup found, skipping.")
            return false
        }
        
        // Check if the new App Group store already has data
        // (if it does, we don't want to overwrite it)
        let newStoreURL = URL.storeURL(for: newAppGroupID, dataModel: dataModelName)
        if FileManager.default.fileExists(atPath: newStoreURL.path) {
            Logger.debug("[TransferMigration] New App Group store already exists, skipping restore.")
            defaults.set(true, forKey: Keys.didRestore)
            return false
        }
        
        do {
            try restoreCoreData(newAppGroupID: newAppGroupID)
            try restoreUserDefaults(newAppGroupID: newAppGroupID)
            
            defaults.set(true, forKey: Keys.didRestore)
            
            Logger.success("[TransferMigration] Restore complete.")
            return true
        } catch {
            Logger.debug("[TransferMigration] Restore failed: \(error.localizedDescription)")
            return false
        }
    }
    
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - CLEANUP
    // Call after you're confident all users have migrated (e.g. a few months post-transfer)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    func cleanupBackup() {
        try? FileManager.default.removeItem(at: backupBaseURL)
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.didBackup)
        defaults.removeObject(forKey: Keys.backupVersion)
        defaults.removeObject(forKey: Keys.didRestore)
        
        Logger.debug("[TransferMigration] Backup cleaned up.")
    }
    
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Core Data Backup / Restore
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func backupCoreData() throws {
        let fm = FileManager.default
        
        // Source: current App Group container
        let sourceBase = URL.storeURL(for: AppConfiguration.appGroupID, dataModel: dataModelName)
        
        // Destination: Application Support / TransferMigrationBackup / CoreData /
        try fm.createDirectory(at: coreDataBackupURL, withIntermediateDirectories: true)
        
        for ext in sqliteExtensions {
            let srcFile = sqliteFileURL(base: sourceBase, extension: ext)
            let dstFile = coreDataBackupURL.appendingPathComponent("\(dataModelName).\(ext)")
            
            guard fm.fileExists(atPath: srcFile.path) else { continue }
            
            // Remove old backup if present, then copy
            try? fm.removeItem(at: dstFile)
            try fm.copyItem(at: srcFile, to: dstFile)
        }
    }
    
    private func restoreCoreData(newAppGroupID: String) throws {
        let fm = FileManager.default
        
        // Destination: new App Group container
        let destBase = URL.storeURL(for: newAppGroupID, dataModel: dataModelName)
        let destDir = destBase.deletingLastPathComponent()
        try fm.createDirectory(at: destDir, withIntermediateDirectories: true)
        
        for ext in sqliteExtensions {
            let srcFile = coreDataBackupURL.appendingPathComponent("\(dataModelName).\(ext)")
            let dstFile = sqliteFileURL(base: destBase, extension: ext)
            
            guard fm.fileExists(atPath: srcFile.path) else { continue }
            
            try? fm.removeItem(at: dstFile)
            try fm.copyItem(at: srcFile, to: dstFile)
        }
    }
    
    /// Builds the correct file URL for each SQLite companion file.
    /// e.g. base = .../CoreDataModel.sqlite
    ///   ext = "sqlite"     → .../CoreDataModel.sqlite
    ///   ext = "sqlite-wal" → .../CoreDataModel.sqlite-wal
    private func sqliteFileURL(base: URL, extension ext: String) -> URL {
        if ext == "sqlite" {
            return base
        } else {
            // base is already ".../CoreDataModel.sqlite"
            // we need ".../CoreDataModel.sqlite-wal" etc.
            return URL(fileURLWithPath: base.path + "-" + ext.replacingOccurrences(of: "sqlite-", with: ""))
        }
    }
    
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - UserDefaults Backup / Restore
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private func backupUserDefaults() throws {
        // Read all values from the App Group suite
        guard let suiteDefaults = UserDefaults(suiteName: AppConfiguration.appGroupID) else {
            Logger.debug("[TransferMigration] Could not open App Group UserDefaults suite.")
            return
        }
        
        let allValues = suiteDefaults.dictionaryRepresentation()
        
        // Filter out Apple's internal keys (they start with a prefix we don't need)
        let filtered = allValues.filter { key, _ in
            !key.hasPrefix("com.apple.")
            && !key.hasPrefix("NS")
            && !key.hasPrefix("Apple")
        }
        
        guard !filtered.isEmpty else {
            Logger.debug("[TransferMigration] No App Group UserDefaults to backup.")
            return
        }
        
        // Serialize to plist
        let data = try PropertyListSerialization.data(
            fromPropertyList: filtered,
            format: .binary,
            options: 0
        )
        
        try FileManager.default.createDirectory(
            at: backupBaseURL,
            withIntermediateDirectories: true
        )
        
        try data.write(to: userDefaultsBackupURL, options: .atomic)
        
        Logger.debug("[TransferMigration] Backed up \(filtered.count) UserDefaults keys.")
    }
    
    private func restoreUserDefaults(newAppGroupID: String) throws {
        guard FileManager.default.fileExists(atPath: userDefaultsBackupURL.path) else {
            Logger.debug("[TransferMigration] No UserDefaults backup found.")
            return
        }
        
        guard let suiteDefaults = UserDefaults(suiteName: newAppGroupID) else {
            Logger.debug("[TransferMigration] Could not open new App Group UserDefaults suite.")
            return
        }
        
        let data = try Data(contentsOf: userDefaultsBackupURL)
        
        guard let dict = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any] else {
            Logger.debug("[TransferMigration] Could not deserialize UserDefaults backup.")
            return
        }
        
        // Write each key-value pair into the new suite
        for (key, value) in dict {
            suiteDefaults.set(value, forKey: key)
        }
        
        Logger.debug("[TransferMigration] Restored \(dict.count) UserDefaults keys.")
    }
}
