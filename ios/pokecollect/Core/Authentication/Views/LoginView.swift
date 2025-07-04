//
//  LoginView.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/27/25.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - Navigation Callback
    let onSignUpTapped: () -> Void
    
    // MARK: - State Properties
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showingSuccessAlert = false
    
    // MARK: - Authentication Manager
    @StateObject private var authManager = AuthenticationManager.shared
    
    // MARK: - Computed Properties
    private var isLoginFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= Config.Validation.Auth.passwordMinLength
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient - Emerald & Forest Theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.9),
                        Color.teal.opacity(0.7),
                        Color.mint.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating orbs for visual appeal
                backgroundOrbs
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 60)
                        
                        // Logo and Title Section
                        logoSection
                        
                        // Error Message Display
                        if let errorMessage = authManager.errorMessage {
                            ErrorMessageView(
                                message: errorMessage,
                                onDismiss: {
                                    authManager.errorMessage = nil
                                }
                            )
                        }
                        
                        // Login Form
                        loginForm
                        
                        // Login Button
                        loginButton
                        
                        // Divider and Sign Up Link
                        bottomSection
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.errorMessage)
        .alert("Login Successful", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("You have been logged in successfully!")
        }
    }
}

// MARK: - View Components
private extension LoginView {
    
    var backgroundOrbs: some View {
        Group {
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.yellow.opacity(0.15))
                .frame(width: 150, height: 150)
                .offset(x: 120, y: -300)
            
            Circle()
                .fill(Color.orange.opacity(0.12))
                .frame(width: 100, height: 100)
                .offset(x: 150, y: 200)
        }
    }
    
    var logoSection: some View {
        VStack(spacing: 20) {
            // App Logo/Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("PokéCollect")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Track your card collection")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.bottom, 50)
    }
    
    var loginForm: some View {
        VStack(spacing: 24) {
            // Email Field
            AuthTextFieldView(
                title: "Email",
                placeholder: "Enter your email",
                iconName: "envelope",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                isDisabled: authManager.isLoading
            )
            
            // Password Field
            AuthTextFieldView(
                title: "Password",
                placeholder: "Enter your password",
                iconName: "lock",
                text: $password,
                isPasswordVisible: $isPasswordVisible,
                textContentType: .password,
                isDisabled: authManager.isLoading,
                onPasswordVisibilityToggle: {
                    isPasswordVisible.toggle()
                }
            )
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // Handle forgot password
                    print("Forgot password tapped")
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .disabled(authManager.isLoading)
            }
            .padding(.top, -8)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    var loginButton: some View {
        VStack(spacing: 16) {
            AuthButtonView(
                title: "Sign In",
                loadingTitle: "Signing In...",
                isLoading: authManager.isLoading,
                isEnabled: isLoginFormValid
            ) {
                handleLogin()
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 40)
    }
    
    var bottomSection: some View {
        VStack(spacing: 16) {
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                Text("or")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            
            // Sign Up Link
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white.opacity(0.7))
                
                Button("Sign Up") {
                    onSignUpTapped()
                }
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .disabled(authManager.isLoading)
            }
            .font(.footnote)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Private Methods
private extension LoginView {
    func handleLogin() {
        // Clear any previous error messages
        authManager.errorMessage = nil
        
        // Validate form before attempting login
        guard isLoginFormValid else {
            print("Login form validation failed")
            return
        }
        
        // Perform login
        Task {
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
    }
    
    func clearLoginForm() {
        email = ""
        password = ""
        isPasswordVisible = false
    }
}

// MARK: - Convenience Initializer for Previews
extension LoginView {
    init() {
        self.onSignUpTapped = {}
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
