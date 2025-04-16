//
//  Translate.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//
import Foundation

class Translate {
    
    // This function translates a regular text (String) to Braille
    static func translateToBraille(text: String) -> String {
        // Return a space if the input text is empty
        guard !text.isEmpty else { return " " }

        var translatedText = ""
        var previousCharWasNumber = false

        // Iterate over each character in the text
        for char in text {
            // Handle spaces separately
            if char == " " {
                translatedText += " "  // Preserve spaces
                previousCharWasNumber = false
            // If the character is recognized in the Braille dictionary
            } else if let brailleChar = brailleDictionary[char] {
                translatedText += brailleChar
                previousCharWasNumber = false
            // Handle uppercase letters
            } else if char.isUppercase, let lowerBraille = brailleDictionary[char.lowercased().first!] {
                translatedText += "⠠" + lowerBraille  // Adds uppercase prefix
                previousCharWasNumber = false
            // Handle numbers
            } else if char.isNumber, let brailleNumber = brailleDictionary[char] {
                // Add numeric prefix "⠼" only if it's the first number in a sequence
                if !previousCharWasNumber {
                    translatedText += "⠼"
                }
                translatedText += brailleNumber
                previousCharWasNumber = true
            } else {
                translatedText += "?"  // If the character is not recognized, use "?" as a placeholder
                previousCharWasNumber = false
            }
        }
        return translatedText
    }

    // This function translates Braille back to regular text
    static func translateToText(braille: String) -> String {
        // Return a space if the Braille input is empty
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

        // Iterate through the Braille string character by character
        while i < brailleCharacters.count {
            let char = brailleCharacters[i]

            // Handle spaces
            if char == " " {
                textOutput.append(" ")  // Preserve spaces
            // Handle uppercase prefix "⠠"
            } else if char == "⠠" {
                isCapital = true
            // Handle numeric prefix "⠼"
            } else if char == "⠼" {
                isNumeric = true
            // If the Braille character is found in the reverse dictionary
            } else if let textChar = reverseDictionary[String(char)] {
                // If the character should be uppercase, apply uppercase transformation
                if isCapital {
                    textOutput.append(textChar.uppercased()) // Converts to uppercase
                    isCapital = false
                // If the character is a number, simply append it as is
                } else if isNumeric {
                    textOutput.append(textChar) // Assumes it's a number
                    isNumeric = false
                } else {
                    textOutput.append(textChar)
                }
            } else {
                textOutput.append("?")  // If the character is not recognized, use "?" as a placeholder
            }
            i += 1
        }
        return textOutput
    }
}
