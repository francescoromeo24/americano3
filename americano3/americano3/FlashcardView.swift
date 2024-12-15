//
//  FlashcardView.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//

import SwiftUI

struct FlashcardView: View {
    var flashcard: Flashcard
    var onToggleStar: (Flashcard) -> Void

    var body: some View {
        VStack {
            // Flashcard content
            VStack(alignment: .leading) {
                Text(flashcard.word.isEmpty ? "Word" : flashcard.word)  // Show "Word" if empty
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(flashcard.translation.isEmpty ? "Translation" : flashcard.translation)  // Show "Translation" if empty
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding()

            // Star button to mark as favorite
            HStack {
                Spacer()
                Button(action: {
                    onToggleStar(flashcard)

                }) {
                    Image(systemName: flashcard.isStarred ? "star.fill" : "star")
                        .foregroundColor(flashcard.isStarred ? .blue : .blue)
                        .font(.title)
                }
                .padding()
            }
        }
        .frame(width: 146, height: 164)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white).shadow(radius: 2))
        .padding(.horizontal)
    }
}

#Preview {
    FlashcardView(flashcard: Flashcard(word: "", translation: "", isStarred: false)) { updatedFlashcard in
        // The action to handle the star toggle
        print("Toggled star for flashcard with word: \(updatedFlashcard.word)")
    }
}



