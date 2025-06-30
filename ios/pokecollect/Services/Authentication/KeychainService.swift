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
    
    // MARK: - JWT Token Methods
    
    // Saves JWT token to keychain securely
    func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Try to update existing token first
        let updateQuery = buildQuery()
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        
        // If token doesn't exist, create it
        if updateStatus == errSecItemNotFound {
            var addQuery = buildQuery()
            addQuery[kSecValueData as String] = data
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            
            if addStatus != errSecSuccess {
                throw KeychainError.saveError(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.saveError(updateStatus)
        }
    }
    
    // Retrieves JWT token from keychain
    func getToken() throws -> String? {
        var query = buildQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                throw KeychainError.invalidData
            }
            
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.retrieveError(status)
        }
    }
    
    // Delete JWT token from keychain (used for logout)
    func deleteToken() throws {
        let query = buildQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteError(status)
        }
    }
    
    // Checks if JWT token exists in keychain
    func hasToken() -> Bool {
        do {
            return try getToken() != nil
        } catch {
            return false
        }
    }
}

// MARK: - Private Helper Methods
private extension KeychainService {
    
    // Build the query dictionary for JWT token keychain operations
    func buildQuery() -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Config.Auth.tokenKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
    }
}

// MARK: - Keychain Error Types
enum KeychainError: Error, LocalizedError {
    case invalidData
    case saveError(OSStatus)
    case retrieveError(OSStatus)
    case deleteError(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid token data"
        case .saveError(let status):
            return "Failed to save token: \(status)"
        case .retrieveError(let status):
            return "Failed to retrieve token: \(status)"
        case .deleteError(let status):
            return "Failed to delete token: \(status)"
        }
    }
}
