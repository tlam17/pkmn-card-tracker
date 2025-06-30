//
//  LoginView.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/27/25.
//

import SwiftUI

struct LoginView: View {
    // MARK: - State Properties
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showingAlert = false
    
    // MARK: - Authentication Manager
    @StateObject private var authManager = AuthenticationManager.shared
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 60)
                        
                        // Logo and Title Section
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
                        
                        // Error Message Display
                        if let errorMessage = authManager.errorMessage {
                            VStack {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.9))
                                )
                                .padding(.horizontal, 32)
                                .padding(.bottom, 16)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Login Form
                        VStack(spacing: 24) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .disabled(authManager.isLoading)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .disabled(authManager.isLoading)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
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
                        
                        // Login Button
                        VStack(spacing: 16) {
                            Button(action: {
                                handleLogin()
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("Signing In...")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            isFormValid ? Color.yellow : Color.gray.opacity(0.6),
                                            isFormValid ? Color.orange : Color.gray.opacity(0.4)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(!isFormValid || authManager.isLoading)
                            .scaleEffect(authManager.isLoading ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: authManager.isLoading)
                            
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
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button("Sign Up") {
                                // Navigate to sign up
                                print("Navigate to sign up")
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .disabled(authManager.isLoading)
                        }
                        .font(.footnote)
                        .padding(.bottom, 32)
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.errorMessage)
        .alert("Login Successful", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("You have been logged in successfully!")
        }
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                showingAlert = true
                // Clear form after successful login
                email = ""
                password = ""
            }
        }
    }
}

// MARK: - Private Methods
private extension LoginView {
    func handleLogin() {
        // Clear any previous error messages
        authManager.errorMessage = nil
        
        // Validate form before attempting login
        guard isFormValid else {
            print("Form validation failed")
            return
        }
        
        // Perform login
        Task {
            do {
                try await authManager.login(email: email, password: password)
                print("Login completed successfully")
            } catch {
                print("Login failed: \(error.localizedDescription)")
                // Error message is already handled by AuthenticationManager
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
