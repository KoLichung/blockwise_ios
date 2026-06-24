//
//  UserViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/05/25.
//

import SwiftUI

final class UserViewModel: ObservableObject {
    
    @Published var user: UserEntity?
    
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    
    @Published var usage: TimeInterval = 0
            
    init() {
        refresh()
    }
    
    func refresh() {
        getUser()
        getCurrentStreak()
    }
    
    // MARK: - User
    
    func getUser() {
        let users = CoreDataStack.shared.fetchEntities(for: UserEntity.self)
        user = users.first
        
        // Load best streak from persistence
        bestStreak = Int(user?.bestStreak ?? 0)
    }
    
    // MARK: - Streak Logic
    
    func getCurrentStreak() {
        guard let user else {
            Logger.debug("User object missing — cannot update streak.")
            return
        }
        
        let calendar = Calendar.current
        
        let referenceDate: Date
        var countFirstDayImmediately = false
        
        if let lastReset = user.lastStreakReset {
            referenceDate = calendar.startOfDay(for: lastReset)
        } else if let dateCreated = user.dateCreated {
            referenceDate = calendar.startOfDay(for: dateCreated)
            countFirstDayImmediately = true // only count immediate first day if from creation
        } else {
            Logger.debug("No reference date available for streak calculation.")
            return
        }
        
        let daysBetween = calendar.dateComponents([.day], from: referenceDate, to: .yesterday).day ?? 0
        
        let newStreak: Int
        if countFirstDayImmediately {
            // If this is from creation, count today immediately
            newStreak = max(1, daysBetween + 1)
        } else {
            // If from reset, count only fully completed days (no partial)
            newStreak = max(0, daysBetween)
        }
        
        self.currentStreak = newStreak
        
        if newStreak > bestStreak {
            bestStreak = newStreak
            user.bestStreak = Int64(newStreak)
        }
        
        Logger.debug("Streak updated: \(newStreak) days since \(referenceDate)")
        
        saveContext()
    }

    // MARK: - Reset / Break Streak
    
    func breakStreak() {
        guard let user else {
            Logger.debug("User object missing — cannot reset streak.")
            return
        }
        
        let today = Calendar.current.startOfDay(for: .now)
        
        // Reset current streak only
        currentStreak = 0
        user.lastStreakReset = today
        
        Logger.debug("Streak reset to 0. Reset date: \(today)")
        
        saveContext()
    }
        
    // MARK: - Persistence
    
    private func saveContext() {
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            Logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
}
