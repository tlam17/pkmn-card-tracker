//
//  KeychainService.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/29/25.
//

import Foundation
import Security

// MARK: - Keychain Service
final class KeychainService {
    
    // Shared singleton instance for app-wide use
    static let shared = KeychainService()
    
    private init() {}
    
    // The service identifier for the app's keychain items
    private let service = Bundle.main.bundleIdentifier ?? "com.tlam.pkmn-tcg-collection"
}
