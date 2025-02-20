//
//  FlashcardManager.swift
//  americano3
//
//  Created by Francesco Romeo on 16/12/24.
//

import Foundation
import Combine

class FlashcardManager: ObservableObject {
    @Published var flashcards: [Flashcard] = [] {
        didSet {
            sortedFlashcards = flashcards.sorted { $0.dateAdded > $1.dateAdded }
            saveFlashcards() // Automatically save whenever flashcards are updated
        }
    }
    
    @Published var selectedFlashcard: Flashcard?
    @Published var sortedFlashcards: [Flashcard] = []

    private let fileName = "flashcards.json"

    init() {
        loadFlashcards() // Load flashcards from storage when the manager is initialized
    }
    
    /// Adds a new flashcard to the list if it doesn't already exist.
    func addFlashcard(textInput: String, brailleOutput: String) {
        guard !textInput.isEmpty else { return }
        
        let newFlashcard = Flashcard(word: textInput, translation: brailleOutput, dateAdded: Date())
        
        // Prevent duplicate entries based on the word
        if !flashcards.contains(where: { $0.word == newFlashcard.word }) {
            flashcards.append(newFlashcard)
            selectedFlashcard = newFlashcard
        }
    }
    
    /// Removes a specified flashcard from the list.
    func removeFlashcard(_ flashcard: Flashcard) {
        flashcards.removeAll { $0.id == flashcard.id }
    }

    /// Toggles the favorite (starred) status of a flashcard.

    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle()
        }
    }

    /// Retrieves a list of all flashcards that are marked as favorite (starred).
    var starredFlashcards: [Flashcard] {
        flashcards.filter { $0.isStarred }
    }

    /// Saves the flashcards to a local JSON file.
    private func saveFlashcards() {
        let fileURL = getFileURL()
        do {
            let data = try JSONEncoder().encode(flashcards)
            try data.write(to: fileURL)
        } catch {
            print("Error while saving flashcards: \(error)")
        }
    }

    /// Loads flashcards from the local JSON file.
    private func loadFlashcards() {
        let fileURL = getFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            flashcards = try JSONDecoder().decode([Flashcard].self, from: data)
        } catch {
            print("No data found while loading flashcards: \(error)")
        }
    }

    /// Returns the file path where flashcards are stored.
    private func getFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
}
