//
//  ContainerView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//

import SwiftUI

struct ContainerView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label(LocalizedStringKey("translate"), systemImage: "translate")
                }
            
            BrailleAlphabetView()
                .tabItem {
                    Label(LocalizedStringKey("braille_alphabet"), systemImage: "textformat.characters.dottedunderline")
                }
        }
        .accentColor(.blue)
        .background(Color("Background"))
    }
}

#Preview {
    Group {
        ContainerView()
            .preferredColorScheme(.light)
        
        ContainerView()
            .preferredColorScheme(.dark)
        
        ContainerView()
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
    }
}
