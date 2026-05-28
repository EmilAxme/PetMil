//
//  CoreDataStack.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "PetMil")
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("CoreData load error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext { container.viewContext }
}
