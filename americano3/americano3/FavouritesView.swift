//
//  FavouritesView.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//

import SwiftUI

struct FavouritesView: View {
    @Binding var flashcards: [Flashcard] // Collegamento alla lista di flashcard
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Filtra le flashcard per mostrare solo quelle favorite
                    ForEach(flashcards.filter { $0.isStarred }) { flashcard in
                        FlashcardView(flashcard: flashcard) { updatedFlashcard in
                            // Aggiorna lo stato della stella
                            if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
                                flashcards[index] = updatedFlashcard
                            }
                        }
                        .frame(width: 146, height: 164) // Dimensione delle flashcard
                    }
                }
                .padding()
            }
            .navigationTitle("Favorites")
            .foregroundColor(.blue)
            .background(Color("Background"))
        }
    }
}

#Preview {
    FavouritesView(flashcards: .constant([
            Flashcard(word: "", translation: "", isStarred: true),
        ]))
}

