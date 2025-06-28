//
//  Config.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/28/25.
//

// MARK: - App Configuration
import Foundation

struct Config {
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "http://localhost:8080"
        static let timeout: TimeInterval = 30.0
        
        // Authentication Endpoints
        struct Endpoints {
            static let auth = "/api/auth"
            static let login = "\(auth)/login"
            static let register = "\(auth)/register"
            static let test = "/api/test"
        }
    }
    
    // MARK: - Authentication
    struct Auth {
        static let tokenKey = "jwt_token"
        static let userEmailKey = "user_email"
    }
    
    // MARK: - Validation Rules
    struct Validation {
        struct Auth {
            static let emailMaxLength = 100
            static let passwordMinLength = 8
            static let passwordMaxLength = 128
            static let nameMinLength = 2
            static let nameMaxLength = 100
        }
    }
}

// MARK: - URL Helpers
extension Config.API.Endpoints {
    /// Get full URL for login endpoint
    static var loginURL: String {
        return Config.API.baseURL + login
    }
    
    /// Get full URL for register endpoint
    static var registerURL: String {
        return Config.API.baseURL + register
    }
    
    /// Get full URL for test endpoint
    static var testURL: String {
        return Config.API.baseURL + test
    }
}
