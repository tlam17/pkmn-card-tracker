//
//  AuthenticationManager.swift
//  pokecollect
//
//  Created by Tyler Lam on 6/30/25.
//

import Foundation

// MARK: - Authentication Manager
// Manages the overall authentication state of the app
@MainActor
final class AuthenticationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private let keychainService: KeychainService
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Shared Instance
    static let shared = AuthenticationManager()
    
    // MARK: - Initialization
    private init(
        keychainService: KeychainService = KeychainService.shared,
        networkService: NetworkServiceProtocol = NetworkService.shared
    ) {
        self.keychainService = keychainService
        self.networkService = networkService
        
        // Check if user is already logged in on launch
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Authentication Methods
    
    // Login
    func login(email: String, password: String) async throws {
        // Clear any previous errors
        errorMessage = nil
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            // Create login request
            let loginRequest = LoginRequest(
                email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            
            // Make API call to backend
            let authResponse = try await networkService.post(
                endpoint: Config.API.Endpoints.login,
                body: loginRequest,
                responseType: AuthResponse.self)
            
            // Save JWT token
            try keychainService.saveToken(authResponse.token)
            
            // Update authentication state
            isLoggedIn = true
            
            print("Login successful for: \(loginRequest.email)")
        } catch {
            handleAuthenticationError(error)
            throw error
        }
    }
    
    // Register
    func register(name: String, email: String, password: String) async throws {
        // Clear any previous errors
        errorMessage = nil
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            // Create signup request
            let signupRequest = SignupRequest(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            
            // Make API call to backend
            let authResponse = try await networkService.post(
                endpoint: Config.API.Endpoints.register,
                body: signupRequest,
                responseType: AuthResponse.self)
            
            // Save JWT token
            try keychainService.saveToken(authResponse.token)
            
            // Update authentication state
            isLoggedIn = true
            
            print("Login successful for: \(signupRequest.email)")
        } catch {
            handleAuthenticationError(error)
            throw error
        }
    }
    
    // Logout
    func logout() {
        do {
            // Remove JWT token from keychain
            try keychainService.deleteToken()
            
            // Reset authentication state
            isLoggedIn = false
            currentUser = nil
            errorMessage = nil
            
            print("Logout successful")
        } catch {
            print("Error during logout: \(error.localizedDescription)")
            isLoggedIn = false
            currentUser = nil
        }
    }
    
    // Validate current authentication state
    func validateAutnethication() async {
        guard isLoggedIn, getCurrentToken() != nil else {
            logout()
            return
        }
        
        do {
            // Test the token
            let _ = try await networkService.get(
                endpoint: Config.API.Endpoints.test,
                responseType: String.self
            )
            
            print("Token validation successful")
        } catch APIError.unauthorized {
            print("Token expired, logging out")
            logout()
        } catch {
            print("Token validation failed: \(error.localizedDescription)")
        }
    }
    
    // Get the current JWT token if available
    func getCurrentToken() -> String? {
        do {
            return try keychainService.getToken()
        } catch {
            print("Error retrieving token: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Private Helper Methods
private extension AuthenticationManager {
    
    // Check authentication status when app starts
    func checkAuthenticationStatus() {
        // Check if we have a stored token
        if keychainService.hasToken() {
            isLoggedIn = true
            print("Found stored token - user appears to be logged in")
            
            // Validate token in the background
            Task {
                await validateAutnethication()
            }

        } else {
            isLoggedIn = false
            currentUser = nil
            print("No stored token found - user needs to log in")
        }
    }
    
    // Handle authentication errors
    func handleAuthenticationError(_ error: Error) {
        switch error {
        case APIError.unauthorized:
            errorMessage = "Invalid email of password."
        case APIError.serverError(let code, let message):
            if code == 409 {
                errorMessage = "An account with this email already exists."
            } else {
                errorMessage = message ?? "Server error occurred."
            }
        case APIError.networkError:
            errorMessage = "Network connection failed. Please check your internet connection."
        case APIError.timeout:
            errorMessage = "Request timed out. Please try again."
        case KeychainError.saveError:
            errorMessage = "Failed to save login information securely."
        default:
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        print("Authentication error: \(error.localizedDescription)")
    }
    
}
