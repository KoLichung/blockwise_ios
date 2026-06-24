//
//  CoreDataStack.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import SwiftUI
import CoreData
import ManagedSettings
import FamilyControls
import DeviceActivity

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    internal init() {}
    
    /// Initialize the `persistentContainer`
    lazy var persistentContainer: NSPersistentContainer = {
        
        /// Reference the `.xcdatamodel` file
        let dataModelName: String = "CoreDataModel"
        
        let container = NSPersistentContainer(name: dataModelName)
        
        /// Configure AppGroups
        let url = URL.storeURL(for: AppConfiguration.appGroupID, dataModel: dataModelName)
        let persistentHistoryTracker: PersistentHistoryTrackingHelper
        
//        let storeDescription = NSPersistentStoreDescription(url: url)
//        
//        storeDescription.setOption(true as NSNumber,
//                                   forKey: NSPersistentHistoryTrackingKey)
//        storeDescription.setOption(true as NSNumber,
//                                   forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        let storeDescription = NSPersistentStoreDescription(url: url)

        storeDescription.setOption(true as NSNumber,
                                   forKey: NSMigratePersistentStoresAutomaticallyOption)
        storeDescription.setOption(true as NSNumber,
                                   forKey: NSInferMappingModelAutomaticallyOption)

        storeDescription.setOption(true as NSNumber,
                                   forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber,
                                   forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, error in
            if let error {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                // The app can't function without Core Data, therefore, if there is a
                // problem loading the stores, the app will crash.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        /// - Prioritize user's changes on background changes...
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        //        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        /// - After loading the `persistentStores`, set up the `persistentHistoryTracker`
        container.viewContext.transactionAuthor = AppActor.mainApp.rawValue
        persistentHistoryTracker = PersistentHistoryTrackingHelper(
            container: container,
            currentActor: AppActor.monitorExtension
        )
        
        return container
    }()
    
}

/// Extension needed to configure `CoreDataStack` with `AppGroups`
public extension URL {
    static func storeURL(for appGroup: String, dataModel: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            // MARK: Handle error
            fatalError("DEBUG: Something went wrong!")
        }
        
        return fileContainer.appendingPathComponent("\(dataModel).sqlite")
    }
}

extension CoreDataStack {
    // MARK: Create Record
    func createRecord(for block: BlockEntity, duration: TimeInterval) throws {
        let viewContext = persistentContainer.viewContext
        let calendar = Calendar.current
        let now = Date()
        let end = now.addingTimeInterval(duration)
        
        let startDay = calendar.startOfDay(for: now)
        let endDay = calendar.startOfDay(for: end)
        
        if startDay == endDay {
            // 👇 Same day, just save one record
            let record = RecordEntity(context: viewContext)
            record.timestamp = now
            record.duration = duration
            block.addToRecordRelationship(record)
            
            Logger.debug("Record NOT splitted")
            
            updateUserDefaults(block: block, duration: duration)
        } else {
            // 👇 Crosses midnight — split into two
            guard let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDay) else {
                throw NSError(domain: "Invalid date calculation", code: 1)
            }

            let durationUntilMidnight = midnight.timeIntervalSince(now)
            let durationAfterMidnight = duration - durationUntilMidnight

            // Today’s portion
            let todayRecord = RecordEntity(context: viewContext)
            todayRecord.timestamp = now
            todayRecord.duration = durationUntilMidnight
            todayRecord.crossDay = true
            block.addToRecordRelationship(todayRecord)
            updateUserDefaults(block: block, duration: durationUntilMidnight)

            // Tomorrow’s portion
            let tomorrowRecord = RecordEntity(context: viewContext)
            tomorrowRecord.timestamp = midnight
            tomorrowRecord.duration = durationAfterMidnight
            tomorrowRecord.crossDay = true
            block.addToRecordRelationship(tomorrowRecord)
            updateUserDefaults(block: block, duration: durationAfterMidnight, on: .tomorrow)
            
            Logger.debug("Created 2 split records")
        }
        
        try saveContext()
    }
    
    private func updateUserDefaults(block: BlockEntity, duration: TimeInterval, on date: Date = .now) {
        guard let string = block.appTokenString, let token = ApplicationToken.fromRawValue(string) else { return }
        
        UserDefaultsManager.shared.incrementOpenCount(for: token, on: date)
        UserDefaultsManager.shared.addTimeUsed(for: token, duration: duration, on: date)
    }
    
    // MARK: Create/Add Goal
    func setScreenTimeGoal(_ goal: TimeInterval, for user: UserEntity) throws {
        let context = persistentContainer.viewContext
        let newStart = Calendar.current.startOfDay(for: .now)

        // 1. Find an existing active goal (if any)
        if let existingGoals = user.goals as? Set<GoalEntity> {
            if let activeGoal = existingGoals.first(where: { $0.endDate == nil }) {
                activeGoal.endDate = Date.yesterday.setting(hour: 23, minute: 59, second: 59)
            }
        }

        // 2. Create the new goal
        let goalEntity = GoalEntity(context: context)
        goalEntity.goal = goal
        goalEntity.startDate = newStart
        goalEntity.endDate = nil
        goalEntity.user = user

        // 3. Add to relationship
        user.addToGoals(goalEntity)

        try saveContext()
    }
    
    func TOREMOVE(user: UserEntity) throws {
        let context = persistentContainer.viewContext
        let newStart = Calendar.current.startOfDay(for: .now)
        
        let goal: TimeInterval = 2 * 3600

        // 1. Find an existing active goal (if any)
        if let existingGoals = user.goals as? Set<GoalEntity> {
            if let activeGoal = existingGoals.first(where: { $0.endDate == nil }) {
                activeGoal.endDate = Date.now.setting(hour: 23, minute: 59)
            }
        }

        // 2. Create the new goal
        let goalEntity = GoalEntity(context: context)
        goalEntity.goal = goal
        goalEntity.startDate = user.dateCreated ?? Date.now
        goalEntity.endDate = newStart
        goalEntity.user = user

        // 3. Add to relationship
        user.addToGoals(goalEntity)

        try saveContext()
    }
    
    func migrateGoal(user: UserEntity) throws {
        guard user.screenTimeGoal > 0 else { return }
        
        let currentGoal = user.screenTimeGoal
        Logger.debug("Current Goal: \(currentGoal)")
        
        // Create goal entity
        let context = persistentContainer.viewContext
        let goalEntity = GoalEntity(context: context)
        goalEntity.goal = currentGoal
        goalEntity.startDate = user.dateCreated ?? Date.now
        goalEntity.endDate = nil
        goalEntity.user = user
        
        user.addToGoals(goalEntity)
        
        try saveContext()
        
        Logger.success("Goal migrated!")
    }

    
    // MARK: Create User
    func createUser(name: String, screenTimeGoal: TimeInterval) throws {
        Logger.debug("Creating user")
        
        let viewContext = persistentContainer.viewContext
        
        let newUser = UserEntity(context: viewContext)
        newUser.dateCreated = .now
        newUser.name = name
        
        try setScreenTimeGoal(screenTimeGoal, for: newUser)
                
        try saveContext()
    }

    // MARK: Create Block
    func createBlock(appToken: ApplicationToken) throws {
        let viewContext = persistentContainer.viewContext
        
        let newBlock = BlockEntity(context: viewContext)
        newBlock.identifier = UUID().uuidString
        newBlock.dateCreated = .now
        newBlock.appTokenString = appToken.string
        newBlock.cooldown = 5 * 60 // Default 5 minute value
        newBlock.maxDuration = 15 * 60 // Default to 15 minutes
        newBlock.buttonDelay = 10 // Default to 10 seconds
        
        try saveContext()
        
        DeviceActivityManager.shared.addToShield(appToken: appToken)
    }
    
    // MARK: Delete Block
    @MainActor
    func deleteBlock(_ object: BlockEntity) throws {
        
        // Remove pending notification (if any)
        if let warningNotifId = object.warningNotificationId,
           LocalNotificationManager.shared.pendingRequests.contains(where: { $0.identifier == warningNotifId }) {
            Logger.debug("Pending Notification Found")
            LocalNotificationManager.shared.removePendingRequest(withIdentifier: warningNotifId)
        }

        try delete(object)
    }
}

extension CoreDataStack {
    func fetchBlockFromToken(_ token: ApplicationToken?) -> BlockEntity? {
        guard let token else { return nil }
        guard let tokenString = token.string else { return nil }
        
        let allBlocks: [BlockEntity] = fetchEntities(for: BlockEntity.self)
        
        for block in allBlocks {
            if let string = block.appTokenString, string == tokenString {
                return block
            }
        }
        
        return nil
    }
}

// MARK: Find goal for specific date
extension UserEntity {
    func goal(for date: Date) -> TimeInterval? {
        guard let goals = goals as? Set<GoalEntity> else { return nil }
        
        // Find the goal active at the given date:
        // startDate <= date AND (endDate == nil OR endDate > date)
        if let activeGoal = goals.first(where: { goal in
            guard let start = goal.startDate else { return false }
            if let end = goal.endDate {
                return (start <= date) && (date < end)
            } else {
                return start <= date
            }
        }) {
            return activeGoal.goal
        }
        
        return nil
    }
    
    func goalEntity(for date: Date) -> GoalEntity? {
        guard let goals = goals as? Set<GoalEntity> else { return nil }
        
        return goals.first(where: { goal in
            guard let start = goal.startDate else { return false }
            if let end = goal.endDate {
                return (start <= date) && (date < end)
            } else {
                return start <= date
            }
        })
    }
}

extension CoreDataStack {
    func markTodayReviewComplete(for user: UserEntity) throws {
        user.lastReview = .now
        try saveContext()
    }
    
    func isReviewed(from user: UserEntity) -> Bool {
        if let review = user.lastReview {
            let calendar = Calendar.current
            return calendar.isDateInToday(review)
        } else {
            return false
        }
    }
}

extension CoreDataStack {
    func createSchedule(asset: String, name: String, days: [Weekday], startTime: Date, endTime: Date, apps: FamilyActivitySelection) throws {
        
        let viewContext = persistentContainer.viewContext
        let identifier = UUID().uuidString
        let daysString = days.asString
        let selectionKey = UUID().uuidString
        
        let newSchedule = ScheduleEntity(context: viewContext)
        newSchedule.name = name
        newSchedule.dateCreated = .now
        newSchedule.identifier = identifier
        newSchedule.icon = asset // emoji stored as string
        newSchedule.selectionKey = selectionKey
        newSchedule.startTime = startTime
        newSchedule.endTime = endTime
        newSchedule.activeDays = daysString
        
        UserDefaultsManager.shared.set(apps, forKey: selectionKey)
                
        try saveContext()
        try DeviceActivityManager.shared.schedule(days: days, startTime: startTime, endTime: endTime, id: identifier)
        
    }
}
