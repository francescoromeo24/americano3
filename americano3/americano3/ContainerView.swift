//
//  ContainerView.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//

import SwiftUI

struct ContainerView: View {
    init() {
            // Customize the Tab Bar appearance
            UITabBar.appearance().backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 80)
        }
    
    @StateObject private var flashcardManager = FlashcardManager()
    
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house") {
                ContentView()
                    .accessibilityHint("This is the home view")
            }
            Tab("Favorites", systemImage: "star.fill"){
                FavouritesView(flashcards: .constant([
                    Flashcard(word: "", translation: "", isStarred: true),
                    ]))
                .accessibilityHint("This is the favourites view")
            }
        }
    }
}

#Preview {
    ContainerView()
}
