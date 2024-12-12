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
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house") {
                ContentView()
            }
            Tab("Favourites", systemImage: "star.fill"){
                FavouritesView()
            }
        }
    }
}

#Preview {
    ContainerView()
}
