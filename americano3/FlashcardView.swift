//
//  FlashcardView.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//
import SwiftUI

struct FlashcardView: View {
    @Binding var flashcard: Flashcard
    var onToggleStar: (Flashcard) -> Void
    @State private var navigateToFavourites = false // State for navigation
    
    
    var body: some View {
        NavigationStack{
            VStack {
                // Flashcard content
                VStack(alignment: .leading) {
                    Text(flashcard.word.isEmpty ? "Word" : flashcard.word) // Show "Word" if empty
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(flashcard.translation.isEmpty ? "Translation" : flashcard.translation) // Show "Translation" if empty
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
                .padding()
                
                // Star button to mark as favorite
                HStack {
                    Spacer()
                    Button(action: {
                        flashcard.isStarred.toggle() // Toggle the star
                        onToggleStar(flashcard) // Pass updated flashcard
                        
                    }) {
                        Image(systemName: flashcard.isStarred ? "star.fill" : "star")
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
                    .shadow(radius: 2)
            )
            .padding(.horizontal)
        
            
        }
    }
}

struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardView(
            flashcard: .constant(Flashcard(word: "", translation: "", isStarred: false)),
            onToggleStar: { flashcard in
                print("Toggled star for flashcard with word: \(flashcard.word)")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
  }
}
