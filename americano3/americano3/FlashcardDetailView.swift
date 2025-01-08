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
        NavigationStack{
            ScrollView{
                VStack {
                    Text(flashcard.word)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                    Text(flashcard.translation)
                        .font(.title2)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .navigationTitle("Flashcard Details")
            }
        }
    }
}

#Preview {
    FlashcardDetailView(flashcard: Flashcard( word: "", translation: ""))
}

