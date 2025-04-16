//
//  FlashcardDetailView.swift
//  americano3
//
//  Created by Francesco Romeo on 02/01/25.
//
import SwiftUI

struct FlashcardDetailView: View {
    let flashcard: Flashcard

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Testo originale
                Text(flashcard.word)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .accessibilityLabel(flashcard.word) 
                    .padding(.horizontal)

                // Braille translation
                let brailleWords = flashcard.translation.split(separator: " ").map(String.init)
                let originalWords = flashcard.word.split(separator: " ").map(String.init)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(brailleWords.indices, id: \.self) { index in
                        let brailleWord = brailleWords[index]
                        let originalWord = index < originalWords.count ? originalWords[index] : "?"

                        Text(brailleWord)
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                            .accessibilityLabel(originalWord) // VoiceOver reads original world
                            .accessibilityHint("Double tap to hear the word")
                            .onTapGesture {
                                print("Tapped word: \(originalWord)")
                                giveHapticFeedback()
                            }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.vertical)
        }
        .navigationTitle("Details")
        .accessibilityHint("Flashcard details")
        .background(Color("Background"))
    }

    // Haptic feedback
    func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// Preview
struct FlashcardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardDetailView(flashcard: Flashcard(word: "Hello world", translation: "⠓⠑⠇⠇⠕ ⠺⠕⠗⠇⠙", dateAdded: Date()))
    }
}
