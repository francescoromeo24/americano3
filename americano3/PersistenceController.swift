//
//  PersistenceController.swift
//  americano3
//
//  Created by Francesco Romeo on 14/02/25.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NomeDelTuoDataModel") // Usa il nome esatto del tuo .xcdatamodeld
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Errore nel caricamento del Core Data: \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }
}

