//
//  SectionCharacters.swift
//  Character Grid
//
//  Created by Christopher J. Roura on 11/5/20.
//

import Foundation

struct SectionCharacters: Hashable, Equatable {
    let category: String
    let characters: [Character]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
    
    static func ==(lhs: SectionCharacters, rhs: SectionCharacters) -> Bool {
        lhs.category == rhs.category
    }
}
