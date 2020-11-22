//
//  Character.swift
//  Character Grid
//
//  Created by Christopher J. Roura on 11/5/20.
//

import Foundation

struct Character: Codable, Hashable, Identifiable {
    var id: String { name }
    
    let name: String
    let imageName: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name, imageName, category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
    }    
}
