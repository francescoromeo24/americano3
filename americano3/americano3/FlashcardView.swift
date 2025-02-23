//
//  FlashcardView.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//
import SwiftUI
import UIKit

struct FlashcardView: View {
    @Binding var flashcard: Flashcard
    var onToggleStar: (Flashcard) -> Void
    @State private var navigateToDetail = false

    var body: some View {
        VStack {
            // Flashcard content (click to see details)
            VStack(alignment: .leading) {
                Text(flashcard.word.isEmpty ? "Word" : flashcard.word)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .accessibilityLabel(flashcard.word.isEmpty ? "Empty word field" : flashcard.word)

                Text(flashcard.translation.isEmpty ? "Translation" : flashcard.translation)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 2)
                    .accessibilityLabel(flashcard.translation.isEmpty ? "Empty translation field" : flashcard.translation)
            }
            .padding()
            .onTapGesture {
                navigateToDetail = true
                provideHapticFeedback()
                UIAccessibility.post(notification: .announcement, argument: "Opening details for \(flashcard.word)")
            }
            .accessibilityHint("Double tap to view details")

            // Star button to mark as favorite
            HStack {
                Spacer()
                Button(action: {
                    flashcard.isStarred.toggle()
                    onToggleStar(flashcard)
                    provideHapticFeedback()
                    announceStarStatus()
                }) {
                    Image(systemName: flashcard.isStarred ? "star.fill" : "star")
                        .foregroundColor(.blue)
                        .font(.title)
                        .accessibilityLabel(flashcard.isStarred ? "Remove from favorites" : "Add to favorites")
                        .accessibilityHint("Double tap to toggle favorite status")
                }
                .padding()
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
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .navigationDestination(isPresented: $navigateToDetail) {
            FlashcardDetailView(flashcard: flashcard)
        }
    }
// haptic feedback
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
//send to favorites
    private func announceStarStatus() {
        let status = flashcard.isStarred ? "Added to favorites" : "Removed from favorites"
        UIAccessibility.post(notification: .announcement, argument: status)
    }
}

struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardView(
            flashcard: .constant(Flashcard(word: "Hello", translation: "⠉ ⠊ ⠁ ⠕", isStarred: false, dateAdded: Date())),
            onToggleStar: { flashcard in
                print("Toggled star for flashcard with word: \(flashcard.word)")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
