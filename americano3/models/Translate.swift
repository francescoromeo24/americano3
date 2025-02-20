//
//  Translate.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//
import Foundation

class Translate {
    static func translateToBraille(text: String) -> String {
        guard !text.isEmpty else { return " " }

        var translatedText = ""
        var previousCharWasNumber = false

        for char in text {
            if char == " " {
                translatedText += " "  // Preserve spaces
                previousCharWasNumber = false
            } else if let brailleChar = brailleDictionary[char] {
                translatedText += brailleChar
                previousCharWasNumber = false
            } else if char.isUppercase, let lowerBraille = brailleDictionary[char.lowercased().first!] {
                translatedText += "⠠" + lowerBraille  // Adds uppercase prefix
                previousCharWasNumber = false
            } else if char.isNumber, let brailleNumber = brailleDictionary[char] {
                if !previousCharWasNumber {
                    translatedText += "⠼" // Adds numeric prefix only at the start of a number sequence
                }
                translatedText += brailleNumber
                previousCharWasNumber = true
            } else {
                translatedText += "?"  // Unrecognized character
                previousCharWasNumber = false
            }
        }
        return translatedText
    }

    static func translateToText(braille: String) -> String {
        guard !braille.isEmpty else { return " " }

        // Create a reverse dictionary for Braille-to-text translation
        let reverseDictionary = brailleDictionary.reduce(into: [String: Character]()) { result, pair in
            result[pair.value] = pair.key
        }

        var textOutput = ""
        var isCapital = false
        var isNumeric = false

        var i = 0
        let brailleCharacters = Array(braille)

        while i < brailleCharacters.count {
            let char = brailleCharacters[i]

            if char == " " {
                textOutput.append(" ")  // Preserve spaces
            } else if char == "⠠" {  // Uppercase prefix
                isCapital = true
            } else if char == "⠼" {  // Numeric prefix
                isNumeric = true
            } else if let textChar = reverseDictionary[String(char)] {
                if isCapital {
                    textOutput.append(textChar.uppercased()) // Converts to uppercase
                    isCapital = false
                } else if isNumeric {
                    textOutput.append(textChar) // Assumes it's a number
                    isNumeric = false
                } else {
                    textOutput.append(textChar)
                }
            } else {
                textOutput.append("?")  // Unrecognized character
            }
            i += 1
        }
        return textOutput
    }
}
