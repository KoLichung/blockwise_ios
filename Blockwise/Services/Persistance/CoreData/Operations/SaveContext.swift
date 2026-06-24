//
//  SaveContext.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import Foundation

extension CoreDataStack {
    /**
     Saves any uncommitted changes in the Core Data context.
     
     - Note: This method first checks if there are any uncommitted changes in the context. If changes are present, it attempts to save them. In case of an error, it logs the error message to the console.
     */
    func saveContext() throws {
        //  Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
            Logger.success("Saved to Core Data")
        } catch {
            Logger.error(error.localizedDescription)
            throw URLError(.badURL)
        }
    }
}
