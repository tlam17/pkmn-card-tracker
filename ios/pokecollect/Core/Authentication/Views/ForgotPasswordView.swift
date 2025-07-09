//
//  ForgotPasswordView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/7/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    // MARK: - Navigation Callback
    let onBackToLogin: () -> Void
    
    // MARK: - State Properties
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var showingSuccessAlert = false
    
    // MARK: - Computed Properties
    private var isEmailValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedEmail.isEmpty &&
               trimmedEmail.contains("@") &&
               trimmedEmail.contains(".") &&
               trimmedEmail.count <= Config.Validation.Auth.emailMaxLength
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
                        
                        // Header with back button
                        headerSection
                        
                        // Title Section
                        titleSection
                        
                        // Error Message Display
                        if let errorMessage = errorMessage {
                            ErrorMessageView(
                                message: errorMessage,
                                onDismiss: {
                                    self.errorMessage = nil
                                }
                            )
                        }
                        
                        // Success Message Display
                        if let successMessage = successMessage {
                            successMessageView(message: successMessage)
                        }
                        
                        // Email Form
                        emailForm
                        
                        // Send Code Button
                        sendCodeButton
                        
                        // Instructions
                        instructionsSection
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: errorMessage)
        .animation(.easeInOut(duration: 0.3), value: successMessage)
        .alert("Code Sent Successfully", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("A 6-digit reset code has been sent to your email address. Please check your inbox and spam folder.")
        }
    }
}

// MARK: - View Components
private extension ForgotPasswordView {
    
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
    
    var headerSection: some View {
        HStack {
            Button(action: {
                onBackToLogin()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
    
    var titleSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: "lock.rotation")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("Forgot Password?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Enter your email address and we'll send you a code to reset your password")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    var emailForm: some View {
        VStack(spacing: 24) {
            // Email Field
            AuthTextFieldView(
                title: "Email Address",
                placeholder: "Enter your email",
                iconName: "envelope",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                isDisabled: isLoading
            )
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    var sendCodeButton: some View {
        VStack(spacing: 16) {
            AuthButtonView(
                title: "Send Reset Code",
                loadingTitle: "Sending Code...",
                isLoading: isLoading,
                isEnabled: isEmailValid
            ) {
                handleSendCode()
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 32)
    }
    
    var instructionsSection: some View {
        VStack(spacing: 16) {
            Text("What happens next?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                instructionRow(
                    icon: "1.circle.fill",
                    text: "We'll send a 6-digit code to your email"
                )
                
                instructionRow(
                    icon: "2.circle.fill",
                    text: "Enter the code on the next screen"
                )
                
                instructionRow(
                    icon: "3.circle.fill",
                    text: "Create your new password"
                )
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .frame(width: 24)
            
            Text(text)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
    
    func successMessageView(message: String) -> some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text(message)
                    .foregroundColor(.green)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    successMessage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.green.opacity(0.7))
                }
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
}

// MARK: - Private Methods
private extension ForgotPasswordView {
    func handleSendCode() {
        // Clear any previous messages
        errorMessage = nil
        successMessage = nil
        
        // Validate email before proceeding
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Start loading
        isLoading = true
        
        // Simulate API call delay (replace with actual API call later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            
            // Simulate success response
            successMessage = "If an account with that email exists, we've sent you a reset code."
            showingSuccessAlert = true
            
            // Clear email for security
            email = ""
            
            print("Password reset code sent to: \(email)")
            
            // TODO: Navigate to code verification screen
            // For now, just show success message
        }
    }
}

// MARK: - Convenience Initializer for Previews
extension ForgotPasswordView {
    init() {
        self.onBackToLogin = {}
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
