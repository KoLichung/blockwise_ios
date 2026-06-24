//
//  FetchEntities.swift
//  Blockwise
//
//  Created by Ivan Sanna on 27/10/24.
//

import CoreData

extension CoreDataStack {
    /**
     Fetches the specified entities from Core Data with an optional predicate and fetch limit.
     
     - Parameters:
     - entityType: The type of entity to fetch.
     - predicate: An optional `NSPredicate` to filter the fetch request.
     - fetchLimit: An optional limit for the number of results to fetch. Default is no limit.
     - Returns: An array of entities of type `T` if the fetch succeeds, otherwise `nil`.
     
     - Note: Ensure the entity type `T` is specified correctly.
     */
    func fetchEntities<T: NSManagedObject>(
        for entityType: T.Type,
        predicate: NSPredicate? = nil,
        fetchLimit: Int? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [T] {
        let viewContext = persistentContainer.viewContext
        guard let entityName = T.entity().name else { return [] }

        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.fetchLimit = fetchLimit ?? 0
        request.sortDescriptors = sortDescriptors

        do {
            return try viewContext.fetch(request)
        } catch {
            Logger.error("Failed to fetch \(entityName): \(error.localizedDescription)")
            return []
        }
    }
}
