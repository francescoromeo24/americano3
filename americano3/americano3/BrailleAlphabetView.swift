//
//  BrailleAlphabetView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//
import SwiftUI

struct BrailleAlphabetView: View {
    
    let brailleAlphabet: [(label: String, pattern: [Bool])] = [
        // Alphabet
        ("A", [true, false, false, false, false, false]),
        ("B", [true, true, false, false, false, false]),
        ("C", [true, false, true, false, false, false]),
        ("D", [true, false, true, true, false, false]),
        ("E", [true, false, false, true, false, false]),
        ("F", [true, true, true, false, false, false]),
        ("G", [true, true, true, true, false, false]),
        ("H", [true, true, false, true, false, false]),
        ("I", [false, true, true, false, false, false]),
        ("J", [false, true, true, true, false, false]),
        ("K", [true, false, false, false, true, false]),
        ("L", [true, true, false, false, true, false]),
        ("M", [true, false, true, false, true, false]),
        ("N", [true, false, true, true, true, false]),
        ("O", [true, false, false, true, true, false]),
        ("P", [true, true, true, false, true, false]),
        ("Q", [true, true, true, true, true, false]),
        ("R", [true, true, false, true, true, false]),
        ("S", [false, true, true, false, true, false]),
        ("T", [false, true, true, true, true, false]),
        ("U", [true, false, false, false, true, true]),
        ("V", [true, true, false, false, true, true]),
        ("W", [false, true, true, true, false, true]),
        ("X", [true, false, true, false, true, true]),
        ("Y", [true, false, true, true, true, true]),
        ("Z", [true, false, false, true, true, true]),
        
        // Numbers
        ("1", [true, false, false, false, false, false]),
        ("2", [true, true, false, false, false, false]),
        ("3", [true, false, true, false, false, false]),
        ("4", [true, false, true, true, false, false]),
        ("5", [true, false, false, true, false, false]),
        ("6", [true, true, true, false, false, false]),
        ("7", [true, true, true, true, false, false]),
        ("8", [true, true, false, true, false, false]),
        ("9", [false, true, true, false, false, false]),
        ("0", [false, true, true, true, false, false]),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 30) {
                        ForEach(brailleAlphabet, id: \.label) { item in
                            VStack(spacing: 10) {
                                // Letter or Number
                                Text(item.label)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.gray) // Lettere dell'alfabeto grigie
                                    .accessibilityLabel(item.label) // Accessibilità per la lettera
                                
                                // Braille Pattern
                                BraillePatternView(pattern: item.pattern, label: item.label)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color("Background")) // Imposta il colore di background a tutta la schermata
            .navigationTitle("Braille Alphabet")
            .foregroundColor(.blue)
        }
    }
}

struct BraillePatternView: View {
    let pattern: [Bool]
    let label: String

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(15)), count: 2), spacing: 5) { // Punti più piccoli
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .frame(width: 12, height: 12) // Cerchi più piccoli
                    .foregroundColor(pattern[index] ? .black : .gray) // Punti attivi neri, inattivi grigi
            }
        }
        .frame(width: 50, height: 60) // Assicura una dimensione costante per la griglia Braille
        .accessibilityElement(children: .combine) // Combinare i cerchi in un singolo elemento di accessibilità
        .accessibilityLabel(label) // VoiceOver dirà solo la lettera, senza descrizione dei punti Braille
    }
}

// Anteprima per SwiftUI
struct BrailleAlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrailleAlphabetView()
        }
    }
}
