//
//  FlashcardManager.swift
//  americano3
//
//  Created by Francesco Romeo on 16/12/24.
//

import Foundation

class FlashcardManager: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    
    func addFlashcard(textInput: String, brailleOutput: String) {
        // Avoid adding a flashcard if no translation exists
        guard !textInput.isEmpty else { return }
        
        // Create a new flashcard
        let newFlashcard = Flashcard(word: textInput, translation: brailleOutput)
        
        if !flashcards.contains(where: { $0.word == newFlashcard.word }) {
            flashcards.append(newFlashcard) // Add flashcard
        }
    }
    
    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle() // Toggle starred state
        }
    }
}

