//
//  DeleteObject.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import CoreData

extension CoreDataStack {
    /**
     Deletes a specified `NSManagedObject` from the Core Data context and saves the context.
     
     - Parameter object: The `NSManagedObject` to delete.
     
     - Note: This method automatically saves the context after deletion. If the save fails, this method should handle the error appropriately.
     */
    func delete(_ object: NSManagedObject) throws {
        persistentContainer.viewContext.delete(object)
        try saveContext()
        Logger.success("Entity Deleted")
    }
}
