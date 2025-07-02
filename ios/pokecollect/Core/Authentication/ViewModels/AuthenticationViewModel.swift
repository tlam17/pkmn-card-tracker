//
//  AuthenticationViewModel.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//

import Foundation

// MARK: - Authentication ViewModel
@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var isPasswordVisible = false
    @Published var showingSuccessAlert = false
    
    // MARK: - Dependencies
    private let authManager: AuthenticationManager
    
    // MARK: - Computed Properties
    var isLoginFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= Config.Validation.Auth.passwordMinLength
    }
    
    var isSignupFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        name.count >= Config.Validation.Auth.nameMinLength &&
        name.count <= Config.Validation.Auth.nameMaxLength &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        email.count <= Config.Validation.Auth.emailMaxLength &&
        !password.isEmpty &&
        password.count >= Config.Validation.Auth.passwordMinLength &&
        password.count <= Config.Validation.Auth.passwordMaxLength &&
        isPasswordStrong
    }
    
    private var isPasswordStrong: Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // Pass through properties from AuthenticationManager
    var isLoading: Bool {
        authManager.isLoading
    }
    
    var errorMessage: String? {
        authManager.errorMessage
    }
    
    var isLoggedIn: Bool {
        authManager.isLoggedIn
    }
    
    // MARK: - Initialization
    init(authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func handleLogin() async {
        // Clear any previous error messages
        authManager.errorMessage = nil
        
        // Validate form before attempting login
        guard isLoginFormValid else {
            print("Login form validation failed")
            return
        }
        
        // Perform login
        do {
            try await authManager.login(email: email, password: password)
            showingSuccessAlert = true
            clearLoginForm()
            print("Login completed successfully")
        } catch {
            print("Login failed: \(error.localizedDescription)")
            // Error message is already handled by AuthenticationManager
        }
    }
    
    func handleSignup() async {
        // Clear any previous error messages
        authManager.errorMessage = nil
        
        // Validate form before attempting signup
        guard isSignupFormValid else {
            print("Signup form validation failed")
            return
        }
        
        // Perform signup
        do {
            try await authManager.register(name: name, email: email, password: password)
            showingSuccessAlert = true
            clearSignupForm()
            print("Signup completed successfully")
        } catch {
            print("Signup failed: \(error.localizedDescription)")
            // Error message is already handled by AuthenticationManager
        }
    }
    
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
    
    func clearError() {
        authManager.errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func clearLoginForm() {
        email = ""
        password = ""
        isPasswordVisible = false
    }
    
    private func clearSignupForm() {
        name = ""
        email = ""
        password = ""
        isPasswordVisible = false
    }
}
