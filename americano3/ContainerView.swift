//
//  ContainerView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//

import SwiftUI

struct ContainerView: View {
    init() {
          // Color icons and text
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemBlue
        UITabBar.appearance().tintColor = UIColor.blue
      }
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Translate", systemImage: "translate")
                }
            
            BrailleAlphabetView()
                .tabItem {
                    Label("Braille Alphabet", systemImage: "textformat.characters.dottedunderline")
                }
        }
    }
    
}

#Preview {
    ContainerView()
}
