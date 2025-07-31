//
//  CardSet.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/15/25.
//

import Foundation

// MARK: - CardSet Model
struct CardSet: Codable, Identifiable {
    let id: String
    let name: String
    let series: String
    let language: String
    let symbolUrl: String?
    let logoUrl: String?
    let printedTotal: Int
    let totalCards: Int
    let releaseDate: String // We'll keep as String since the backend sends it as "yyyy-MM-dd"
    
    // Computed property for formatted release date
    var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: releaseDate) {
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        }
        
        return releaseDate
    }
    
    // For preview and testing
    static let example = CardSet(
        id: "sv6",
        name: "Twilight Masquerade",
        series: "Scarlet & Violet",
        language: "ENGLISH",
        symbolUrl: "https://images.pokemontcg.io/sv6/symbol.png",
        logoUrl: "https://images.pokemontcg.io/sv6/logo.png",
        printedTotal: 162,
        totalCards: 226,
        releaseDate: "2024-05-24"
    )
}

// MARK: - Series Model (for organizing sets)
struct Series: Identifiable {
    let id = UUID()
    let name: String
    let sets: [CardSet]
}

// MARK: - API Response wrapper (if needed)
struct CardSetsResponse: Codable {
    let sets: [CardSet]
}
