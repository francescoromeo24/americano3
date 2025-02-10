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
    @State private var navigateToFavourites = false
    @State private var navigateToDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                // Navigazione alla FlashcardDetailView
                NavigationLink(destination: FlashcardDetailView(flashcard: flashcard), isActive: $navigateToDetail) {
                    EmptyView()
                }

                // Flashcard content (cliccabile per aprire il dettaglio)
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
                        .accessibilityLabel(flashcard.word.isEmpty ? "Empty translation field" : flashcard.word)
                }
                .padding()
                .onTapGesture {
                    navigateToDetail = true
                    provideHapticFeedback()
                    UIAccessibility.post(notification: .announcement, argument: "Opening details for \(flashcard.word)")
                }
                .accessibilityHint("Double tap to view details")

                // Star button to mark as favorite and navigate to favorites
                HStack {
                    Spacer()
                    Button(action: {
                        flashcard.isStarred.toggle()
                        onToggleStar(flashcard)
                        provideHapticFeedback()
                        announceStarStatus()

                        // Se la stella viene premuta, naviga ai preferiti
                        if flashcard.isStarred {
                            navigateToFavourites = true
                        }
                    }) {
                        Image(systemName: flashcard.isStarred ? "star.fill" : "star")
                            .foregroundColor(.blue)
                            .font(.title)
                            .accessibilityLabel(flashcard.isStarred ? "Remove from favorites" : "Add to favorites")
                            .accessibilityHint("Double tap to toggle favorite status and go to favorites if added")
                    }
                    .padding()
                   /* .background(
                        NavigationLink(destination: FavoritesView(), isActive: $navigateToFavourites) {
                            EmptyView()
                        }
                        .hidden()
                    )*/
                }
            }
            .frame(width: 146, height: 164)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .stroke(Color.blue, lineWidth:1)
                    .shadow(radius: 2)
            )
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
        }
    }

    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func announceStarStatus() {
        let status = flashcard.isStarred ? "Added to favorites" : "Removed from favorites"
        UIAccessibility.post(notification: .announcement, argument: status)
    }
}
struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardView(
            flashcard: .constant(Flashcard(word: "Hello", translation: "Ciao", isStarred: false)),
            onToggleStar: { flashcard in
                print("Toggled star for flashcard with word: \(flashcard.word)")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
