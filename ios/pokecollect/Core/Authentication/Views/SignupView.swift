//
//  SignupView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//

import SwiftUI

struct SignupView: View {
    // MARK: - State Properties
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptTerms = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showingAlert = false
    
    // MARK: - Authentication Manager
    @StateObject private var authManager = AuthenticationManager.shared
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        // Name validation
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let isNameValid = trimmedName.count >= Config.Validation.Auth.nameMinLength &&
                         trimmedName.count <= Config.Validation.Auth.nameMaxLength &&
                         !trimmedName.isEmpty
        
        // Email validation
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmailValid = !trimmedEmail.isEmpty &&
                          trimmedEmail.contains("@") &&
                          trimmedEmail.contains(".") &&
                          trimmedEmail.count <= Config.Validation.Auth.emailMaxLength
        
        // Password validation
        let isPasswordValid = password.count >= Config.Validation.Auth.passwordMinLength &&
                             password.count <= Config.Validation.Auth.passwordMaxLength &&
                             !password.isEmpty
        
        // Confirm password validation
        let isConfirmPasswordValid = !confirmPassword.isEmpty &&
                                    password == confirmPassword
        
        // Terms acceptance validation
        let isTermsAccepted = acceptTerms
        
        // All conditions must be true
        return isNameValid &&
               isEmailValid &&
               isPasswordValid &&
               isConfirmPasswordValid &&
               isTermsAccepted
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
                        
                        // Title Section
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("Create Account")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 40)
                        
                        // Signup Form
                        VStack(spacing: 24) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    TextField("Enter your name", text: $name)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .autocapitalization(.words)
                                        .textContentType(.name)
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
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    if isConfirmPasswordVisible {
                                        TextField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    } else {
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: {
                                        isConfirmPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
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
                            
                            // Terms of Service Acceptance
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {
                                        acceptTerms.toggle()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(acceptTerms ? Color.yellow : Color.white.opacity(0.15))
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                            
                                            if acceptTerms {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                    .disabled(authManager.isLoading)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 0) {
                                            Text("I agree to the ")
                                                .font(.footnote)
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Button("Terms of Service") {
                                                // Handle terms of service link
                                                print("Show Terms of Service")
                                            }
                                            .font(.footnote)
                                            .foregroundColor(.yellow)
                                            .underline()
                                            .disabled(authManager.isLoading)
                                            
                                            Text(" and ")
                                                .font(.footnote)
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Button("Privacy Policy") {
                                                // Handle privacy policy link
                                                print("Show Privacy Policy")
                                            }
                                            .font(.footnote)
                                            .foregroundColor(.yellow)
                                            .underline()
                                            .disabled(authManager.isLoading)
                                        }
                                        
                                        Text("By creating an account, you confirm that you are at least 13 years old.")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                        
                        // Signup Button
                        VStack(spacing: 16) {
                            Button(action: {
                                handleSignup()
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("Creating account...")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Create Account")
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
                        .padding(.bottom, 24)
                        
                        // Login
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button("Login") {
                                // Navigate to sign up
                                print("Navigate to login")
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
    }
}

// MARK: - Private Methods
private extension SignupView {
    func handleSignup() {
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
                try await authManager.register(name: name, email: email, password: password)
                print("Signup completed successfully")
            } catch {
                print("Signup failed: \(error.localizedDescription)")
                // Error message is already handled by AuthenticationManager
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
