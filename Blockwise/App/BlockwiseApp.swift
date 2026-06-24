//
//  BlockwiseApp.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

@main
struct BlockwiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var swDelegate: SWDelegate = .init()
    
    init() {
        AppServices.configure(swDelegate: swDelegate)
        
        // MARK: ✅ Back up data on every launch (no-op if already done)
        TransferMigrationManager.shared.backupIfNeeded()
        
        // MARK: ✅ Restore data from backup into the NEW App Group container
        TransferMigrationManager.shared.restoreIfNeeded(
            newAppGroupID: AppConfiguration.appGroupID
        )
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchRouter()
                .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
                .sensoryFeedback(.selection, trigger: swDelegate.playHaptic)
        }
    }
}
