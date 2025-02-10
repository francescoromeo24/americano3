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
            saveFlashcards()
        }
    }
    @Published var selectedFlashcard: Flashcard?

    private let fileName = "flashcards.json"

    init() {
        loadFlashcards()
    }

    func addFlashcard(textInput: String, brailleOutput: String) {
        guard !textInput.isEmpty else { return }
        
        let newFlashcard = Flashcard(word: textInput, translation: brailleOutput)
        
        if !flashcards.contains(where: { $0.word == newFlashcard.word }) {
            flashcards.append(newFlashcard)
            selectedFlashcard = newFlashcard
        }
    }
    
    func removeFlashcard(_ flashcard: Flashcard) {
        flashcards.removeAll { $0.id == flashcard.id }
    }


    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle()
        }
    }

    var starredFlashcards: [Flashcard] {
        flashcards.filter { $0.isStarred }
    }

    // MARK: - Persistenza Dati

    private func saveFlashcards() {
        let fileURL = getFileURL()
        do {
            let data = try JSONEncoder().encode(flashcards)
            try data.write(to: fileURL)
        } catch {
            print("Errore durante il salvataggio delle flashcard: \(error)")
        }
    }

    private func loadFlashcards() {
        let fileURL = getFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            flashcards = try JSONDecoder().decode([Flashcard].self, from: data)
        } catch {
            print("Nessun dato trovato o errore durante il caricamento delle flashcard: \(error)")
        }
    }

    private func getFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
}
