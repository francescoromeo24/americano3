//
//  Flashcard.swift
//  americano3
//
//  Created by Francesco Romeo on 15/12/24.
//

import Foundation
import SwiftUI
//characteristics flashcard

struct Flashcard: Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    var isStarred: Bool = false
}

