//
//  FavouritesView.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//

import SwiftUI

struct FavoritesView: View {
    @Binding var flashcards: [Flashcard]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var starredFlashcards: [Flashcard] {
        flashcards.filter { $0.isStarred }
    }
    
    var body: some View {
        NavigationStack{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(starredFlashcards, id: \.id) { flashcard in
                        NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                            VStack{
                                VStack(alignment: .leading) {
                                    Text(flashcard.word.isEmpty ? "Word" : flashcard.word)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text(flashcard.translation.isEmpty ? "Translation" : flashcard.translation)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .padding(.top, 2)
                                }
                                .padding()
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        toggleFlashcardStar(for: flashcard)
                                    }) {
                                        Image(systemName:  "star.fill")
                                            .foregroundColor(.blue)
                                            .font(.title)
                                    }
                                    .padding()
                                }
                                
                            }
                            .frame(width: 146, height: 164)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(radius: 2))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Favorites")
        }
    }
    
    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle()
        }
    }
}


#Preview {
    FavoritesView(flashcards: .constant([
        Flashcard(word: "", translation: "", isStarred: true),
        Flashcard(word: "", translation: "", isStarred: true)
    ]))
}

