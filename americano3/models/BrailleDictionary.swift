//
//  BrailleDictionary.swift
//  americano3
//
//  Created by Francesco Romeo on 11/12/24.
//

import Foundation

// More comprehensive Braille dictionary
let brailleDictionary: [Character: String] = [
    // Lowercase letters
    "a": "⠁", "b": "⠃", "c": "⠉", "d": "⠙", "e": "⠑", "f": "⠋", "g": "⠛", "h": "⠓", "i": "⠊", "j": "⠚",
    "k": "⠅", "l": "⠇", "m": "⠍", "n": "⠝", "o": "⠕", "p": "⠏", "q": "⠟", "r": "⠗", "s": "⠎", "t": "⠞",
    "u": "⠥", "v": "⠧", "w": "⠺", "x": "⠭", "y": "⠽", "z": "⠵",

    // Uppercase letters (prefix ⠠ + letter)
    "A": "⠠⠁", "B": "⠠⠃", "C": "⠠⠉", "D": "⠠⠙", "E": "⠠⠑", "F": "⠠⠋", "G": "⠠⠛", "H": "⠠⠓", "I": "⠠⠊", "J": "⠠⠚",
    "K": "⠠⠅", "L": "⠠⠇", "M": "⠠⠍", "N": "⠠⠝", "O": "⠠⠕", "P": "⠠⠏", "Q": "⠠⠟", "R": "⠠⠗", "S": "⠠⠎", "T": "⠠⠞",
    "U": "⠠⠥", "V": "⠠⠧", "W": "⠠⠺", "X": "⠠⠭", "Y": "⠠⠽", "Z": "⠠⠵",

    // Numbers (preceded by numeric prefix ⠼)
    "1": "⠼⠁", "2": "⠼⠃", "3": "⠼⠉", "4": "⠼⠙", "5": "⠼⠑",
    "6": "⠼⠋", "7": "⠼⠛", "8": "⠼⠓", "9": "⠼⠊", "0": "⠼⠚",

    // Punctuation
    ".": "⠲",  // Period
    ",": "⠂",  // Comma
    ";": "⠆",  // Semicolon
    ":": "⠒",  // Colon
    "?": "⠦",  // Question mark
    "!": "⠖",  // Exclamation mark
    "(": "⠦",  // Open parenthesis
    ")": "⠴",  // Close parenthesis
    "\"": "⠶", // Quotation marks
    "'": "⠄",  // Apostrophe

    // Special symbols
    "+": "⠖",  // Addition
    "-": "⠤",  // Subtraction
    "*": "⠦",  // Multiplication
    "/": "⠌",  // Division
    "=": "⠶",  // Equals
    "@": "⠈⠁", // At symbol
    "#": "⠼",  // Number sign
    "&": "⠯",  // Ampersand
    "%": "⠨⠴", // Percent
    "$": "⠈⠎", // Dollar
    "€": "⠈⠑", // Euro

]
