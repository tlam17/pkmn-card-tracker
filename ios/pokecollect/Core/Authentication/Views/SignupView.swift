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
    @State private var showingSuccessAlert = false
    
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
                             !password.isEmpty &&
                             isPasswordStrong
        
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
    
    private var isPasswordStrong: Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]+$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
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
                        
                        // Title Section
                        titleSection
                        
                        // Error Message Display
                        if let errorMessage = authManager.errorMessage {
                            ErrorMessageView(
                                message: errorMessage,
                                onDismiss: {
                                    authManager.errorMessage = nil
                                }
                            )
                        }
                        
                        // Signup Form
                        signupForm
                        
                        // Signup Button
                        signupButton
                        
                        // Divider and Login Link
                        bottomSection
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.errorMessage)
        .alert("Registration Successful", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your account has been created successfully!")
        }
    }
}

// MARK: - View Components
private extension SignupView {
    
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
    
    var titleSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 40)
    }
    
    var signupForm: some View {
        VStack(spacing: 24) {
            // Name Field
            AuthTextFieldView(
                title: "Name",
                placeholder: "Enter your name",
                iconName: "person",
                text: $name,
                textContentType: .name,
                autocapitalization: .words,
                isDisabled: authManager.isLoading
            )
            
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
                textContentType: .newPassword,
                isDisabled: authManager.isLoading,
                onPasswordVisibilityToggle: {
                    isPasswordVisible.toggle()
                }
            )
            
            // Confirm Password
            AuthTextFieldView(
                title: "Confirm Password",
                placeholder: "Confirm your password",
                iconName: "lock",
                text: $confirmPassword,
                isPasswordVisible: $isConfirmPasswordVisible,
                textContentType: .newPassword,
                isDisabled: authManager.isLoading,
                onPasswordVisibilityToggle: {
                    isConfirmPasswordVisible.toggle()
                }
            )
            
            // Terms of Service Acceptance
            termsOfServiceSection
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    var termsOfServiceSection: some View {
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
    
    var signupButton: some View {
        VStack(spacing: 16) {
            AuthButtonView(
                title: "Create Account",
                loadingTitle: "Creating account...",
                isLoading: authManager.isLoading,
                isEnabled: isFormValid
            ) {
                handleSignup()
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 32)
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
            
            // Login Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white.opacity(0.7))
                
                Button("Login") {
                    // Navigate to login
                    print("Navigate to login")
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
private extension SignupView {
    func handleSignup() {
        // Clear any previous error messages
        authManager.errorMessage = nil
        
        // Validate form before attempting signup
        guard isFormValid else {
            print("Form validation failed")
            return
        }
        
        // Perform signup
        Task {
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
    }
    
    func clearSignupForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        acceptTerms = false
        isPasswordVisible = false
        isConfirmPasswordVisible = false
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
