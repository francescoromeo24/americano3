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
    
    // Define a two-column grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Filter and sort starred flashcards based on the date added (newest first)
    var starredFlashcards: [Flashcard] {
        flashcards.filter { $0.isStarred }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Loop through starred flashcards and create navigation links for each
                    ForEach(starredFlashcards, id: \.id) { flashcard in
                        NavigationLink(destination: FlashcardDetailView(flashcard: flashcard)) {
                            VStack {
                                VStack(alignment: .leading) {
                                    // Display word with accessibility support
                                    Text(flashcard.word.isEmpty ? "Word" : flashcard.word)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .accessibilityLabel(flashcard.word.isEmpty ? "Word" : flashcard.word)
                                        .accessibilityHint("This is the word in the flashcard.")
                                    
                                    // Display translation with accessibility support
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
                                    // Star button to toggle favorite status
                                    Button(action: {
                                        toggleFlashcardStar(for: flashcard)
                                        triggerHapticFeedback() // Trigger haptic feedback on action
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
                            .frame(
                                width: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 146,
                                height: UIDevice.current.userInterfaceIdiom == .pad ? 220 : 164
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .stroke(Color.blue, lineWidth: 1)
                                    .shadow(radius: 2)
                            )
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Flashcard")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Favorites") // Set navigation title
            .background(Color("Background")) // Use app-defined background color
        }
    }
    
    // Function to toggle the "starred" status of a flashcard
    func toggleFlashcardStar(for flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index].isStarred.toggle()
        }
    }
    
    // Function to trigger haptic feedback when an action is performed
    func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}

// Preview provider to display sample flashcards
#Preview {
    FavoritesView(flashcards: .constant([
        Flashcard(word: "", translation: "", isStarred: true, dateAdded: Date()),
        Flashcard(word: "", translation: "", isStarred: true, dateAdded: Date())
    ]))
}
