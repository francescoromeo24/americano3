//
//  DataManager.swift
//  americano3
//
//  Created by Francesco Romeo on 20/02/25.
//

import CoreData
import UIKit

class DataManager {
    static let shared = DataManager()

    // Ottieni il contesto Core Data
    private var context: NSManagedObjectContext {
        return PersistenceController.shared.context
    }

    // Funzione per salvare un BrailleEntry
    func saveBrailleEntry(text: String) {
        let newBrailleEntry = BrailleEntry(context: context)
        newBrailleEntry.text = text
        newBrailleEntry.dateCreated = formatDate(Date()) // Converte la data in stringa

        do {
            try context.save()
        } catch {
            print("Failed to save Braille entry: \(error.localizedDescription)")
        }
    }

    // Funzione per salvare uno ScanEntity
    func saveScanEntity(image: UIImage, recognizedText: String) {
        let newScanEntity = ScanEntity(context: context)
        newScanEntity.imageData = image.pngData()  // Converte l'immagine in dati binari
        newScanEntity.recognizedText = recognizedText
        newScanEntity.timestamp = Date()

        do {
            try context.save()
        } catch {
            print("Failed to save scan entity: \(error.localizedDescription)")
        }
    }

    // Funzione per recuperare tutte le BrailleEntry
    func fetchBrailleEntries() -> [BrailleEntry] {
        let fetchRequest: NSFetchRequest<BrailleEntry> = BrailleEntry.fetchRequest()

        do {
            let brailleEntries = try context.fetch(fetchRequest)
            return brailleEntries
        } catch {
            print("Failed to fetch Braille entries: \(error.localizedDescription)")
            return []
        }
    }

    // Funzione per recuperare tutte le ScanEntity
    func fetchScanEntities() -> [ScanEntity] {
        let fetchRequest: NSFetchRequest<ScanEntity> = ScanEntity.fetchRequest()

        do {
            let scanEntities = try context.fetch(fetchRequest)
            return scanEntities
        } catch {
            print("Failed to fetch scan entities: \(error.localizedDescription)")
            return []
        }
    }

    // Funzione per formattare la data in una stringa
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Formato della data
        return dateFormatter.string(from: date)
    }
}
