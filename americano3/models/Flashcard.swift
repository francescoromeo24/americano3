//
//  Flashcard.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//

import Foundation
//characteristics flashcard

struct Flashcard: Identifiable, Codable {
    var id = UUID()
    let word: String
    let translation: String
    var isStarred: Bool = false
    let dateAdded: Date 
}

