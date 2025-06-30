//
//  NetworkService.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/28/25.
//

import Foundation

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    // Shared singleton instance for app-wide use
    static let shared = NetworkService()
    // URL session for network requests with custom configuration
    private let session: URLSession
    // JSON encoder for request bodies
    private let encoder = JSONEncoder()
    // JSON decoder for response parsing
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    private init() {
        // Configure URL session with custom settings
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Config.API.timeout
        configuration.timeoutIntervalForResource = Config.API.timeout
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        self.session = URLSession(configuration: configuration)
        
        // Configure JSON decoder for consistent date parsing
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    // MARK: - Public API Methods
    // Generic method for making API requests with response parsing
    func request<T: Codable>(endpoint: String, method: HTTPMethod = .GET, body: Data? = nil, responseType: T.Type) async throws -> T {
        
        // Build the URL and configure the request
        guard let url = buildURL(for: endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add authentication if available
        addAuthenticationIfAvailable(to: &request)
        
        // Log request for debugging
        logRequest(request, body: body)
        
        do {
            // Perform the network request
            let (data, response) = try await session.data(for: request)
            
            // Validate and log the response
            try validateResponse(response, data: data)
            logResponse(response, data: data)
            
            // Decode and return the response
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch {
            throw mapSystemError(error)
        }
    }
    
    // Generic method for making API requests that don't expect a response body
    func requestWithoutResponse(endpoint: String, method: HTTPMethod = .POST, body: Data? = nil) async throws {
        
        // Use main request method but ignore the response
        let _: EmptyResponse = try await request(
            endpoint: endpoint,
            method: method,
            body: body,
            responseType: EmptyResponse.self
        )
        
    }
}

// MARK: - Helper Methods
private extension NetworkService {
    
    // Builds complete URL from endpoint
    func buildURL(for endpoint: String) -> URL? {
        let baseURL = Config.API.baseURL
        let fullURLString = baseURL + endpoint
        return URL(string: fullURLString)
    }
    
    // Adds JWT to request if available
    func addAuthenticationIfAvailable(to request: inout URLRequest) {
        // TODO: This will be implemented when we create AuthenticationManager
        // For now, we'll add a placeholder that checks for stored token
        if let token = getStoredToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // Placeholder for token retrieval
    func getStoredToken() -> String? {
        // TODO: Implement proper token retrieval from Keychain
        return UserDefaults.standard.string(forKey: Config.Auth.tokenKey)
    }
    
    // Validates HTTP response and throws appropriate errors
    func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 400...499:
            // Client error - try to extract error message
            let errorMessage = extractErrorMessage(from: data)
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        case 500...599:
            // Server error
            let errorMessage = extractErrorMessage(from: data)
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        default:
            throw APIError.unknown
        }
    }
    
    // Extract error message from response data
    func extractErrorMessage(from data: Data) -> String? {
        do {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            return errorResponse.message
        } catch {
            // If we can't decode the error message, try to get the raw string
            return String(data: data, encoding: .utf8)
        }
    }
    
    // Map system errors to custom error types
    func mapSystemError(_ error: Error) -> APIError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError(urlError)
            default:
                return .networkError(urlError)
            }
        } else if error is DecodingError {
            return .decodingError(error)
        } else {
            return .networkError(error)
        }
    }
    
    // MARK: - Logging Methods
    // Log outgoing requests
    func logRequest(_ request: URLRequest, body: Data?) {
        #if DEBUG
        print("[NetworkService] Request:")
        print("URL: \(request.url?.absoluteString ?? "Unknown")")
        print("Method: \(request.httpMethod ?? "Unknown")")
        
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        
        if let body = body,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        #endif
    }
    
    // Log incoming responses
    func logResponse(_ response: URLResponse, data: Data) {
        #if DEBUG
        print("[NetworkService] Response:")
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Body: \(responseString)")
        }
        #endif
    }
}

// MARK: - Convenience Methods
extension NetworkService {
    
    // Convenience method for encoding request bodies
    func encode<T: Codable>(_ object: T) throws -> Data {
        return try encoder.encode(object)
    }
    
    // Convenience method for GET requests
    func get<T: Codable>(endpoint: String, responseType: T.Type) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .GET,
            body: nil,
            responseType: responseType
        )
    }
    
    // Convenience method for POST requests with body
    func post<T: Codable, U:Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U {
        let bodyData = try encode(body)
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // Convenience method for PUT requests with body
    func put<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U {
        let bodyData = try encode(body)
        return try await request(
            endpoint: endpoint,
            method: .PUT,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // Convenience method for PATCH requests with body
    func patch<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U {
        let bodyData = try encode(body)
        return try await request(
            endpoint: endpoint,
            method: .PATCH,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // Convenience method for DELETE requests
    func delete(endpoint: String) async throws {
        try await requestWithoutResponse(
            endpoint: endpoint,
            method: .DELETE,
            body: nil
        )
    }
}

// MARK: - Helper Types

// Empty response type for requests that don't return data
struct EmptyResponse: Codable {}

struct ErrorResponse: Codable {
    let status: Int
    let error: String
    let message: String
    let details: [String: String]?
    let timestamp: Int64
}

