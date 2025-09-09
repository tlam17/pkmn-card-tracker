//
//  CollectionServiceProtocol.swift
//  pokecollect
//
//  Created by Tyler Lam on 9/1/25.
//

import Foundation

// MARK: - Collection Service Protocol
protocol CollectionServiceProtocol {
    func addToCollection(cardId: String, userId: Int, quantity: Int) async throws -> CollectionEntry
    func removeFromCollection(entryId: Int) async throws
    func getUserCollection(userId: Int) async throws -> [CollectionEntryDTO]
}

// MARK: - Collection Service Implementation
final class CollectionService: CollectionServiceProtocol {
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Add a card to the user's collection or update quantity if it exists
    /// - Parameters:
    ///   - cardId: The ID of the card to add
    ///   - userId: The ID of the user
    ///   - quantity: The quantity to set for this card
    /// - Returns: CollectionEntry object
    func addToCollection(cardId: String, userId: Int, quantity: Int) async throws -> CollectionEntry {
        let request = AddEntryRequest(cardId: cardId, userId: userId, quantity: quantity)
        let endpoint = "/api/collection/add"
        
        do {
            let response: CollectionEntry = try await networkService.post(
                endpoint: endpoint,
                body: request,
                responseType: CollectionEntry.self
            )
            
            print("Successfully added/updated card \(cardId) in collection with quantity \(quantity)")
            return response
        } catch {
            print("Failed to add card \(cardId) to collection: \(error)")
            throw CollectionError.addFailed(cardId: cardId, error: error)
        }
    }
    
    /// Remove a collection entry
    /// - Parameter entryId: The ID of the collection entry to remove
    func removeFromCollection(entryId: Int) async throws {
        let endpoint = "/api/collection/delete/\(entryId)"
        
        do {
            try await networkService.delete(endpoint: endpoint)
            print("Successfully removed collection entry \(entryId)")
        } catch {
            print("Failed to remove collection entry \(entryId): \(error)")
            throw CollectionError.deleteFailed(entryId: entryId, error: error)
        }
    }
    
    /// Get all collection entries for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: Array of CollectionEntryDTO objects
    func getUserCollection(userId: Int) async throws -> [CollectionEntryDTO] {
        let endpoint = "/api/collection/user/\(userId)"
        
        do {
            let collection: [CollectionEntryDTO] = try await networkService.get(
                endpoint: endpoint,
                responseType: [CollectionEntryDTO].self
            )
            
            print("Successfully fetched \(collection.count) collection entries for user \(userId)")
            return collection
        } catch {
            print("Failed to fetch collection for user \(userId): \(error)")
            throw CollectionError.fetchFailed(userId: userId, error: error)
        }
    }
}

// MARK: - Collection Service Errors
enum CollectionError: Error, LocalizedError {
    case addFailed(cardId: String, error: Error)
    case deleteFailed(entryId: Int, error: Error)
    case fetchFailed(userId: Int, error: Error)
    case invalidUserId
    case invalidCardId
    case invalidQuantity
    
    var errorDescription: String? {
        switch self {
        case .addFailed(let cardId, let error):
            return "Failed to add card \(cardId) to collection: \(error.localizedDescription)"
        case .deleteFailed(let entryId, let error):
            return "Failed to remove entry \(entryId) from collection: \(error.localizedDescription)"
        case .fetchFailed(let userId, let error):
            return "Failed to fetch collection for user \(userId): \(error.localizedDescription)"
        case .invalidUserId:
            return "Invalid user ID provided"
        case .invalidCardId:
            return "Invalid card ID provided"
        case .invalidQuantity:
            return "Invalid quantity provided"
        }
    }
}
