//
//  Translate.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//

import Foundation

class Translate{
    //translation from text to braille
   static func translateToBraille(text: String) -> String { //static used as a "recall" to the view
        guard !text.isEmpty else {return " "}
        var translatedText = ""
        for char in text.lowercased() {
            if let brailleChar = brailleDictionary[char] {
                translatedText += brailleChar
            } else {
                translatedText += " "
            }
        }
        return translatedText
    }
    
    //translation from braille to text
    static func translateToText(braille: String) -> String {
        guard !braille.isEmpty else {return " "}
        _ = " "
        let reverseDictionary = brailleDictionary.reduce(into: [String: Character]()) { result, pair in
            let (key, value) = pair
            if result[value] == nil {
                result[value] = key
            }
        }
        let brailleUnits = braille.split(separator: " ")
        var reversedText = ""
        for unit in brailleUnits {
            if let textChar = reverseDictionary[String(unit)] {
                reversedText += String(textChar)
            } else {
                reversedText += "?"
            }
        }
        
        return reversedText
    }
}
