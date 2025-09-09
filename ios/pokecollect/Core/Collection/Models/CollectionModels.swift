//
//  CollectionModels.swift
//  pokecollect
//
//  Created by Tyler Lam on 9/9/25.
//

import Foundation

// MARK: - Add Entry Request
struct AddEntryRequest: Codable {
    let cardId: String
    let userId: Int
    let quantity: Int
}

// MARK: - Collection Entry Response
struct CollectionEntry: Codable {
    let id: Int
    let userId: Int
    let quantity: Int
    let acquiredDate: String
    let card: CardDTO?
}

// MARK: - Card DTO (for collection responses)
struct CardDTO: Codable {
    let id: String
    let name: String
    let number: String
    let rarity: String?
    let imageUrl: String?
    let smallImageUrl: String?
    let largeImageUrl: String?
}

// MARK: - Collection Entry DTO
struct CollectionEntryDTO: Codable {
    let id: Int
    let userId: Int
    let quantity: Int
    let acquiredDate: String
    let card: CardDTO
}
