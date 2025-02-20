//
//  BrailleAlphabetView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//
import SwiftUI

struct BrailleAlphabetView: View {
    
    enum AlphabetType: String, CaseIterable {
        case lowercase = "Lowercase"
        case uppercase = "Uppercase"
        case numbers = "Numbers"
        case specialChars = "Special Characters"
    }
    
    @State private var selectedType: AlphabetType = .lowercase

    // Braille dictionary
    let brailleDictionary: [Character: [Bool]] = [
        // Lowercase letters
        "a": [true, false, false, false, false, false],
        "b": [true, true, false, false, false, false],
        "c": [true, false, true, false, false, false],
        "d": [true, false, true, true, false, false],
        "e": [true, false, false, true, false, false],
        "f": [true, true, true, false, false, false],
        "g": [true, true, true, true, false, false],
        "h": [true, true, false, true, false, false],
        "i": [false, true, true, false, false, false],
        "j": [false, true, true, true, false, false],
        "k": [true, false, false, false, true, false],
        "l": [true, true, false, false, true, false],
        "m": [true, false, true, false, true, false],
        "n": [true, false, true, true, true, false],
        "o": [true, false, false, true, true, false],
        "p": [true, true, true, false, true, false],
        "q": [true, true, true, true, true, false],
        "r": [true, true, false, true, true, false],
        "s": [false, true, true, false, true, false],
        "t": [false, true, true, true, true, false],
        "u": [true, false, false, false, true, true],
        "v": [true, true, false, false, true, true],
        "w": [false, true, true, true, false, true],
        "x": [true, false, true, false, true, true],
        "y": [true, false, true, true, true, true],
        "z": [true, false, false, true, true, true],
        
        // Uppercase letters (prefix ⠠)
        "A": [true, false, false, false, false, true],
        "B": [true, true, false, false, false, true],
        "C": [true, false, true, false, false, true],
        "D": [true, false, true, true, false, true],
        "E": [true, false, false, true, false, true],
        "F": [true, true, true, false, false, true],
        "G": [true, true, true, true, false, true],
        "H": [true, true, false, true, false, true],
        "I": [false, true, true, false, false, true],
        "J": [false, true, true, true, false, true],
        "K": [true, false, false, false, true, true],
        "L": [true, true, false, false, true, true],
        "M": [true, false, true, false, true, true],
        "N": [true, false, true, true, true, true],
        "O": [true, false, false, true, true, true],
        "P": [true, true, true, false, true, true],
        "Q": [true, true, true, true, true, true],
        "R": [true, true, false, true, true, true],
        "S": [false, true, true, false, true, true],
        "T": [false, true, true, true, true, true],
        "U": [true, false, false, false, true, true],
        "V": [true, true, false, false, true, true],
        "W": [false, true, true, true, false, true],
        "X": [true, false, true, false, true, true],
        "Y": [true, false, true, true, true, true],
        "Z": [true, false, false, true, true, true],
        
        // Numbers (preceded by numeric prefix ⠼)
        "1": [true, false, false, false, false, false],
        "2": [true, true, false, false, false, false],
        "3": [true, false, true, false, false, false],
        "4": [true, false, true, true, false, false],
        "5": [true, false, false, true, false, false],
        "6": [true, true, true, false, false, false],
        "7": [true, true, true, true, false, false],
        "8": [true, true, false, true, false, false],
        "9": [false, true, true, false, false, false],
        "0": [false, true, true, true, false, false],

        // Punctuation
        ".": [true, false, false, true, true, false], // Period
        ",": [true, false, false, false, false, false], // Comma
        ";": [true, true, true, false, true, true], // Semicolon
        ":": [true, false, false, false, true, true], // Colon
        "?": [false, true, true, true, true, true], // Question mark
        "!": [true, true, true, true, false, true], // Exclamation mark
        
        // Special symbols
        "+": [true, true, true, true, false, false], // Addition
        "-": [true, true, false, false, true, true], // Subtraction
        "*": [true, false, false, false, true, true], // Multiplication
        "/": [false, true, true, false, true, false], // Division
        "=": [false, false, true, true, true, false], // Equals
        "@": [false, true, false, false, true, false], // At symbol
        "#": [false, false, false, true, true, true], // Number sign
        "&": [true, false, true, true, false, false], // Ampersand
        "%": [false, true, false, true, true, true], // Percent
        "$": [false, false, true, false, true, true], // Dollar
        "€": [false, true, true, false, false, true]  // Euro
    ]

    //Filtering and ordering alphabet in order to selection
    func filteredAlphabet() -> [(label: String, pattern: [Bool])] {
        switch selectedType {
        case .lowercase:
            return brailleDictionary.keys
                .filter { $0.isLowercase }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .uppercase:
            return brailleDictionary.keys
                .filter { $0.isUppercase }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .numbers:
            return brailleDictionary.keys
                .filter { $0.isNumber }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .specialChars:
            //separating punctuation from special signs (except for numbers and letters)
            let punctuation: [(String, [Bool])] = brailleDictionary.keys
                .filter { ",.?!;:()\"'".contains($0) }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
            
            let specialSymbols: [(String, [Bool])] = brailleDictionary.keys
                .filter { !",.?!;:()\"'".contains($0) && !$0.isLetter && !$0.isNumber }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }

            return punctuation + specialSymbols
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Segmented control per selezionare il tipo di caratteri
                    Picker("Select Alphabet Type", selection: $selectedType) {
                        ForEach(AlphabetType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    // Mostra l'alfabeto filtrato e ordinato
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 30) {
                        ForEach(filteredAlphabet(), id: \.label) { item in
                            VStack(spacing: 10) {
                                Text(item.label)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.gray)
                                    .accessibilityLabel(item.label)
                                
                                BraillePatternView(pattern: item.pattern, label: item.label)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color("Background"))
            .navigationTitle("Braille Alphabet")
            .foregroundColor(.blue)
        }
    }
}

struct BraillePatternView: View {
    let pattern: [Bool]
    let label: String

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(15)), count: 2), spacing: 5) {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(pattern[index] ? .black : .gray)
            }
        }
        .frame(width: 50, height: 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}

struct BrailleAlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        BrailleAlphabetView()
    }
}
