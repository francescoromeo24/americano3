//
//  BrailleAlphabetView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//
import SwiftUI

struct BrailleAlphabetView: View {
    
    // Enum to define the different types of alphabets
    enum AlphabetType: String, CaseIterable {
        case lowercase = "Lowercase"
        case uppercase = "Uppercase"
        case numbers = "Numbers"
        case specialChars = "Special Characters"
    }
    
    @State private var selectedType: AlphabetType = .lowercase

    // Braille dictionary mapping characters to their respective Braille patterns
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
        
        // Uppercase letters (prefixed with ⠠)
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
            ";": [true, false, false, false, true, false], // Semicolon
            ":": [true, false, true, false, true, false], // Colon
            "?": [false, true, false, true, false, false], // Question mark
            "!": [false, true, true, false, false, false], // Exclamation mark
            "(": [false, false, true, true, false, false], // Open parenthesis
            ")": [false, false, false, true, false, true], // Close parenthesis
            "\"": [true, false, false, true, false, true], // Quotation marks
            "'": [true, true, false, false, true, false], // Apostrophe

        // Special symbols
            "+": [true, true, true, true, false, false], // Addition
            "-": [true, true, false, false, true, true], // Subtraction
            "*": [true, false, false, false, true, true], // Multiplication
            "/": [false, true, true, false, true, false], // Division
            "=": [true, false, false, false, true, true], // Equals
            "@": [false, true, false, true, false, true], // At symbol
            "#": [true, false, true, false, true, true], // Number sign
            "&": [false, true, true, false, true, false], // Ampersand
            "%": [false, true, false, true, true, false], // Percent
            "$": [true, true, false, true, false, true], // Dollar
            "€": [false, false, true, false, true, true], // Euro

    ]

    // Function to filter and sort the alphabet based on the selected type
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
            // Separating punctuation from other special symbols
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
                    // Picker to select the alphabet type
                    Picker("Select Alphabet Type", selection: $selectedType) {
                        ForEach(AlphabetType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    // Displaying the filtered and sorted Braille alphabet
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

// View to display the Braille pattern for each character
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

// Preview for SwiftUI live rendering
struct BrailleAlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        BrailleAlphabetView()
    }
}
