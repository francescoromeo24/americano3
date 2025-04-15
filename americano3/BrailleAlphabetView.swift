//
//  BrailleAlphabetView.swift
//  americano3
//
//  Created by Francesco Romeo on 28/01/25.
//
import SwiftUI

struct BrailleAlphabetView: View {
    
    enum AlphabetType: String, CaseIterable {
        case lowercase
        case uppercase
        case numbers
        case specialChars
        
        var localized: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.lowercased())
        }
    }
    
    @State private var selectedType: AlphabetType = .lowercase

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
        
        // Uppercase letters
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
        
        // Numbers
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
        ".": [true, false, false, true, true, false],
        ",": [true, false, false, false, false, false],
        ";": [true, false, false, false, true, false],
        ":": [true, false, true, false, true, false],
        "?": [false, true, false, true, false, false],
        "!": [false, true, true, false, false, false],
        "(": [false, false, true, true, false, false],
        ")": [false, false, false, true, false, true],
        "\"": [true, false, false, true, false, true],
        "'": [true, true, false, false, true, false],

        // Special symbols
        "+": [true, true, true, true, false, false],
        "-": [true, true, false, false, true, true],
        "*": [true, false, false, false, true, true],
        "/": [false, true, true, false, true, false],
        "=": [true, false, false, false, true, true],
        "@": [false, true, false, true, false, true],
        "#": [true, false, true, false, true, true],
        "&": [false, true, true, false, true, false],
        "%": [false, true, false, true, true, false],
        "$": [true, true, false, true, false, true],
        "€": [false, false, true, false, true, true],

        // Accented letters
        "à": [true, false, false, false, false, false, true, true],
        "è": [true, false, false, true, false, false, true, true],
        "é": [true, false, false, true, false, false, true, false],
        "ì": [false, true, true, false, false, false, true, true],
        "í": [false, true, true, false, false, false, true, false],
        "ò": [true, false, false, true, true, false, true, true],
        "ó": [true, false, false, true, true, false, true, false],
        "ù": [true, false, false, false, true, true, true, true],
        "ú": [true, false, false, false, true, true, true, false],
        "ä": [true, false, false, false, false, false, false, true],
        "ë": [true, false, false, true, false, false, false, true],
        "ï": [false, true, true, false, false, false, false, true],
        "ö": [true, false, false, true, true, false, false, true],
        "ü": [true, false, false, false, true, true, false, true],
        "ñ": [true, false, true, true, true, false, true, false],
        "ç": [true, false, true, false, false, false, true, false],

        "À": [true, false, false, false, false, false, true, true],
        "È": [true, false, false, true, false, false, true, true],
        "É": [true, false, false, true, false, false, true, false],
        "Ì": [false, true, true, false, false, false, true, true],
        "Í": [false, true, true, false, false, false, true, false],
        "Ò": [true, false, false, true, true, false, true, true],
        "Ó": [true, false, false, true, true, false, true, false],
        "Ù": [true, false, false, false, true, true, true, true],
        "Ú": [true, false, false, false, true, true, true, false],
        "Ä": [true, false, false, false, false, false, false, true],
        "Ë": [true, false, false, true, false, false, false, true],
        "Ï": [false, true, true, false, false, false, false, true],
        "Ö": [true, false, false, true, true, false, false, true],
        "Ü": [true, false, false, false, true, true, false, true],
        "Ñ": [true, false, true, true, true, false, true, false],
        "Ç": [true, false, true, false, false, false, true, false],
    ]
    
    func filteredAlphabet() -> [(label: String, pattern: [Bool])] {
        switch selectedType {
        case .lowercase:
            return brailleDictionary.keys
                .filter { $0.isLowercase && !$0.isNumber && !(",.?!;:()\"'".contains($0)) }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .uppercase:
            return brailleDictionary.keys
                .filter { $0.isUppercase && !$0.isNumber && !(",.?!;:()\"'".contains($0)) }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .numbers:
            return brailleDictionary.keys
                .filter { $0.isNumber }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
        case .specialChars:
            let punctuation = brailleDictionary.keys
                .filter { ",.?!;:()\"'".contains($0) }
                .sorted()
                .map { (String($0), brailleDictionary[$0]!) }
            let specialSymbols = brailleDictionary.keys
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
                    Picker("Select Alphabet Type", selection: $selectedType) {
                        ForEach(AlphabetType.allCases, id: \.self) { type in
                            Text(type.localized)
                                .font(.body)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

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
            .navigationTitle(LocalizedStringKey("braille_alphabet"))
            .dynamicTypeSize(..<DynamicTypeSize.large)
            .foregroundColor(.blue)
        }
    }
}

struct BraillePatternView: View {
    let pattern: [Bool]
    let label: String

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(15)), count: 2), spacing: 5) {
            ForEach(0..<min(6, pattern.count), id: \.self) { index in
                Circle()
                    .frame(width: min(15, UIFontMetrics.default.scaledValue(for: 15)),
                           height: min(15, UIFontMetrics.default.scaledValue(for: 15)))
                    .foregroundColor(pattern.indices.contains(index) ? (pattern[index] ? .primary : Color.secondary.opacity(0.3)) : .clear)
            }
        }
        .frame(width: 50, height: 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}

struct BrailleAlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrailleAlphabetView()
            BrailleAlphabetView()
                .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        }
    }
}
