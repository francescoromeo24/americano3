//
//  FavouritesView.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//

import SwiftUI

struct FavouritesView: View {
    @Binding var flashcards: [Flashcard] // Collegamento alla lista di flashcard
    @StateObject var flashcardManager = FlashcardManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    
                    ForEach(flashcardManager.starredFlashcards)
                    { flashcard in
                        FlashcardView(
                            flashcard: .constant(flashcard),
                            onToggleStar: { updatedFlashcard in
                                if let index = flashcards.firstIndex(where: { $0.id == updatedFlashcard.id }) {
                                    flashcards[index] = updatedFlashcard
                                }
                        }
                        )
                        .frame(width: 146, height: 164) // Dimensione delle flashcard
                    }
                }
                .padding()
            }
            .navigationTitle("Favourites")
            .foregroundColor(.blue)
            .background(Color("Background"))
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView(flashcards: .constant([
            Flashcard(word: "", translation: "", isStarred: true),
            Flashcard(word: "", translation: "", isStarred: false),
        ]))
    }
}
