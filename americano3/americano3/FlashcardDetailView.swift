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
        VStack {
            Text(flashcard.word)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text(flashcard.translation)
                .font(.title2)
                .foregroundColor(.gray)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Flashcard Details")
    }
}
