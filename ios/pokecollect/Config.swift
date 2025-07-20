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
        
        struct Endpoints {
            // Authentication Endpoints
            static let auth = "/api/auth"
            static let login = "\(auth)/login"
            static let register = "\(auth)/register"
            static let forgotPassword = "\(auth)/forgot-password"
            static let verifyResetCode = "\(auth)/verify-reset-code"
            static let resetPassword = "\(auth)/reset-password"
            static let test = "/api/test"
            
            // CardSets Endpoints
            static let sets = "/api/sets"
            static func setsBySeries(_ series: String) -> String {
                return "\(sets)/series/\(series)"
            }
            
            // Cards Endpoints
            static let cards = "/api/cards"
            static func cardsBySetId(_ setId: String) -> String {
                return "\(cards)/set/\(setId)"
            }
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
    
    /// Get full URL for forgot password endpoint
    static var forgotPasswordURL: String {
        return Config.API.baseURL + forgotPassword
    }
    
    /// Get full URL for verify reset code endpoint
    static var verifyResetCodeURL: String {
        return Config.API.baseURL + verifyResetCode
    }
    
    /// Get full URL for reset password endpoint
    static var resetPasswordURL: String {
        return Config.API.baseURL + resetPassword
    }
    
    /// Get full URL for test endpoint
    static var testURL: String {
        return Config.API.baseURL + test
    }
    
    /// Get full URL for sets by series endpoint
    static func setsBySeriesURL(_ series: String) -> String {
        return Config.API.baseURL + setsBySeries(series)
    }
    
    /// Get full URL for cards by set ID endpoint
    static func cardsBySetIdURL(_ setId: String) -> String {
        return Config.API.baseURL + cardsBySetId(setId)
    }
}
