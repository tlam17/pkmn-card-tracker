//
//  Card.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/20/25.
//

import Foundation

// MARK: - Card Model
struct Card: Codable, Identifiable {
    let id: String
    let name: String
    let number: String
    let rarity: String
    let smallImageUrl: String?
    let largeImageUrl: String?
    
    // Computed property for display number (handles special formatting)
    var displayNumber: String {
        // Some cards have numbers like "001/264" - we want to show just "001"
        if number.contains("/") {
            return String(number.split(separator: "/").first ?? "")
        }
        return number
    }
    
    // Computed property for best available image URL
    var bestImageUrl: String? {
        return largeImageUrl ?? smallImageUrl
    }
    
    // For preview and testing
    static let example = Card(
        id: "sv6-1",
        name: "Bulbasaur",
        number: "001",
        rarity: "Common",
        smallImageUrl: "https://images.pokemontcg.io/sv6/1.png",
        largeImageUrl: "https://images.pokemontcg.io/sv6/1_hires.png"
    )
    
    static let examples: [Card] = [
        Card(
            id: "sv6-1",
            name: "Bulbasaur",
            number: "001",
            rarity: "Common",
            smallImageUrl: "https://images.pokemontcg.io/sv6/1.png",
            largeImageUrl: "https://images.pokemontcg.io/sv6/1_hires.png"
        ),
        Card(
            id: "sv6-2",
            name: "Ivysaur",
            number: "002",
            rarity: "Common",
            smallImageUrl: "https://images.pokemontcg.io/sv6/2.png",
            largeImageUrl: "https://images.pokemontcg.io/sv6/2_hires.png"
        ),
        Card(
            id: "sv6-3",
            name: "Venusaur",
            number: "003",
            rarity: "Common",
            smallImageUrl: "https://images.pokemontcg.io/sv6/3.png",
            largeImageUrl: "https://images.pokemontcg.io/sv6/3_hires.png"
        )
    ]
}
