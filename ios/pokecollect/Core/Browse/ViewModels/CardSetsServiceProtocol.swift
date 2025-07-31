//
//  CardSetsServiceProtocol.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/15/25.
//

import Foundation

// MARK: - CardSets Service Protocol
protocol CardSetsServiceProtocol {
    func getSetsBySeries(_ series: String) async throws -> [CardSet]
}

// MARK: - CardSets Service Implementation
final class CardSetsService: CardSetsServiceProtocol {
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetch card sets for a specific series
    /// - Parameter series: The series name (e.g., "Scarlet & Violet")
    /// - Returns: Array of CardSet objects
    func getSetsBySeries(_ series: String) async throws -> [CardSet] {
        let endpoint = "/api/sets/series/\(series.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? series)"
        
        do {
            let cardSets: [CardSet] = try await networkService.get(
                endpoint: endpoint,
                responseType: [CardSet].self
            )
            
            print("Successfully fetched \(cardSets.count) sets for series: \(series)")
            return cardSets
        } catch {
            print("Failed to fetch sets for series \(series): \(error)")
            throw CardSetsError.fetchFailed(series: series, error: error)
        }
    }
}

// MARK: - CardSets Service Errors
enum CardSetsError: Error, LocalizedError {
    case fetchFailed(series: String, error: Error)
    case invalidSeriesName(String)
    case noSetsFound(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let series, let error):
            return "Failed to fetch sets for \(series): \(error.localizedDescription)"
        case .invalidSeriesName(let series):
            return "Invalid series name: \(series)"
        case .noSetsFound(let series):
            return "No sets found for series: \(series)"
        }
    }
}

// MARK: - Mock Service for Development/Testing
final class MockCardSetsService: CardSetsServiceProtocol {
    
    func getSetsBySeries(_ series: String) async throws -> [CardSet] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return mock data based on series
        switch series {
        case "Scarlet & Violet":
            return [
                CardSet(
                    id: "sv6",
                    name: "Twilight Masquerade",
                    series: "Scarlet & Violet",
                    language: "ENGLISH",
                    symbolUrl: nil,
                    logoUrl: nil,
                    printedTotal: 162,
                    totalCards: 226,
                    releaseDate: "2024-05-24"
                ),
                CardSet(
                    id: "sv5",
                    name: "Temporal Forces",
                    series: "Scarlet & Violet",
                    language: "ENGLISH",
                    symbolUrl: nil,
                    logoUrl: nil,
                    printedTotal: 157,
                    totalCards: 218,
                    releaseDate: "2024-03-22"
                )
            ]
        default:
            throw CardSetsError.noSetsFound(series)
        }
    }
}
