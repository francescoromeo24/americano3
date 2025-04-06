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

    // Additional accented letters
    "â": "⠢",  // a with circumflex
    "ê": "⠣",  // e with circumflex
    "î": "⠩",  // i with circumflex
    "ô": "⠹",  // o with circumflex
    "û": "⠱",  // u with circumflex
    "ë": "⠫",  // e with umlaut
    "ï": "⠻",  // i with umlaut
    "ü": "⠳",  // u with umlaut
    "ñ": "⠻",  // n with tilde
    "ç": "⠯",  // c with cedilla
    
    // Additional uppercase accented letters
    "Â": "⠠⠢", // A with circumflex
    "Ê": "⠠⠣", // E with circumflex
    "Î": "⠠⠩", // I with circumflex
    "Ô": "⠠⠹", // O with circumflex
    "Û": "⠠⠱", // U with circumflex
    "Ë": "⠠⠫", // E with umlaut
    "Ï": "⠠⠻", // I with umlaut
    "Ü": "⠠⠳", // U with umlaut
    "Ñ": "⠠⠻", // N with tilde
    "Ç": "⠠⠯", // C with cedilla

    // Additional punctuation
    "…": "⠲⠲⠲", // Ellipsis
    "–": "⠤⠤",  // En dash
    "—": "⠤⠤⠤", // Em dash
    "«": "⠦",    // Left guillemet
    "»": "⠴",    // Right guillemet
    "¿": "⠦",    // Inverted question mark
    "¡": "⠖",    // Inverted exclamation mark
    
    // Additional symbols
    "°": "⠐⠂",  // Degree
    "±": "⠖⠤",  // Plus-minus
    "×": "⠦",    // Multiplication
    "÷": "⠌",    // Division
    "≠": "⠶⠱",  // Not equal
    "≤": "⠶⠣",  // Less than or equal
    "≥": "⠶⠜",  // Greater than or equal
    "™": "⠞⠍",  // Trademark
    "©": "⠉⠗",  // Copyright
    "®": "⠗",    // Registered trademark
    
]
