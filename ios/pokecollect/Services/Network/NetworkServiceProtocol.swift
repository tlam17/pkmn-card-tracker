//
//  NetworkServiceProtocol.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/28/25.
//

import Foundation

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    /// Generic method for making API requests with response parsing
    /// - Parameters:
    ///   - endpoint: API endpoint path (e.g., "/api/auth/login")
    ///   - method: HTTP method to use
    ///   - body: Optional request body data
    ///   - responseType: Expected response type conforming to Codable
    /// - Returns: Decoded response object
    /// - Throws: APIError for various failure scenarios
    func request<T: Codable>(endpoint: String, method: HTTPMethod, body: Data?, responseType: T.Type) async throws -> T
    
    /// Method for requests that don't expect a response body
    /// - Parameters:
    ///   - endpoint: API endpoint path
    ///   - method: HTTP method to use
    ///   - body: Optional request body data
    /// - Throws: APIError for various failure scenarios
    func requestWithoutResponse(endpoint: String, method: HTTPMethod, body: Data?) async throws
    
    // MARK: - Convenience Methods
        
    /// Convenience method for GET requests
    func get<T: Codable>(endpoint: String, responseType: T.Type) async throws -> T
    
    /// Convenience method for POST requests with body
    func post<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U
    
    /// Convenience method for PUT requests with body
    func put<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U
    
    /// Convenience method for PATCH requests with body
    func patch<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U
    
    /// Convenience method for DELETE requests
    func delete(endpoint: String) async throws
}
