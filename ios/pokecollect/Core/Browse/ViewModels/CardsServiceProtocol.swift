//
//  CardsServiceProtocol.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/20/25.
//

import Foundation

// MARK: - Cards Service Protocol
protocol CardsServiceProtocol {
    func getCardsBySetId(_ setId: String) async throws -> [Card]
}

// MARK: - Cards Service Implementation
final class CardsService: CardsServiceProtocol {
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetch cards for a specific set
    /// - Parameter setId: The set ID (e.g., "sv6")
    /// - Returns: Array of Card objects
    func getCardsBySetId(_ setId: String) async throws -> [Card] {
        let endpoint = "/api/cards/set/\(setId)"
        
        do {
            let cards: [Card] = try await networkService.get(
                endpoint: endpoint,
                responseType: [Card].self
            )
            
            print("Successfully fetched \(cards.count) cards for set: \(setId)")
            return cards
        } catch {
            print("Failed to fetch cards for set \(setId): \(error)")
            throw CardsError.fetchFailed(setId: setId, error: error)
        }
    }
}

// MARK: - Cards Service Errors
enum CardsError: Error, LocalizedError {
    case fetchFailed(setId: String, error: Error)
    case invalidSetId(String)
    case noCardsFound(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let setId, let error):
            return "Failed to fetch cards for set \(setId): \(error.localizedDescription)"
        case .invalidSetId(let setId):
            return "Invalid set ID: \(setId)"
        case .noCardsFound(let setId):
            return "No cards found for set: \(setId)"
        }
    }
}

// MARK: - Mock Service for Development/Testing
final class MockCardsService: CardsServiceProtocol {
    
    func getCardsBySetId(_ setId: String) async throws -> [Card] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return mock data based on set ID
        switch setId {
        case "sv6":
            return Card.examples
        case "sv5":
            return [
                Card(
                    id: "sv5-1",
                    name: "Charmander",
                    number: "001",
                    smallImageUrl: "https://images.pokemontcg.io/sv5/1.png",
                    largeImageUrl: "https://images.pokemontcg.io/sv5/1_hires.png"
                ),
                Card(
                    id: "sv5-2",
                    name: "Charmeleon",
                    number: "002",
                    smallImageUrl: "https://images.pokemontcg.io/sv5/2.png",
                    largeImageUrl: "https://images.pokemontcg.io/sv5/2_hires.png"
                )
            ]
        default:
            throw CardsError.noCardsFound(setId)
        }
    }
}
