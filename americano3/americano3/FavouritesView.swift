//
//  FavouritesView.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//
import SwiftUI
import UIKit

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
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(starredFlashcards, id: \.id) { flashcard in
                        NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                            VStack {
                                VStack(alignment: .leading) {
                                    Text(flashcard.word.isEmpty ? "Word" : flashcard.word)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .accessibilityLabel(flashcard.word.isEmpty ? "Word" : flashcard.word)
                                        .accessibilityHint("This is the word in the flashcard.")
                                    
                                    Text(flashcard.translation.isEmpty ? "Translation" : flashcard.translation)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .padding(.top, 2)
                                        .accessibilityLabel(flashcard.word.isEmpty ? "Translation" : flashcard.word)
                                        .accessibilityHint("This is the translation of the word.")
                                }
                                .padding()
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        toggleFlashcardStar(for: flashcard)
                                        triggerHapticFeedback() // Trigger haptic feedback
                                    }) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.blue)
                                            .font(.title)
                                    }
                                    .padding()
                                    .accessibilityLabel("Toggle star")
                                    .accessibilityHint("Tap to mark this flashcard as starred or unstarred.")
                                    .accessibilityAction(.escape) { toggleFlashcardStar(for: flashcard) }
                                }
                                
                            }
                            .frame(width: 146, height: 164)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .stroke(Color.blue, lineWidth:1)
                                    .shadow(radius: 2)
                            )
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Flashcard")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Favorites")
            .background(Color("Background"))
        }
    }
    
    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle()
        }
    }
    
    func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}

#Preview {
    FavoritesView(flashcards: .constant([
        Flashcard( word: "", translation: "", isStarred: true),
        Flashcard(word: "", translation: "", isStarred: true)
    ]))
}

