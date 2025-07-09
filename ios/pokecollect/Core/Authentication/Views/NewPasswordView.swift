//
//  NewPasswordView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/9/25.
//

import SwiftUI

struct NewPasswordView: View {
    
    // MARK: - Navigation Callbacks
    let email: String
    let code: String
    let onBackToCodeVerification: () -> Void
    let onPasswordResetSuccess: () -> Void
    
    // MARK: - State Properties
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var showingSuccessAlert = false
    
    // MARK: - Computed Properties
    private var isPasswordValid: Bool {
        PasswordRequirementsGenerator.isPasswordStrong(newPassword)
    }
    
    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && newPassword == confirmPassword
    }
    
    private var isFormValid: Bool {
        isPasswordValid && passwordsMatch && !newPassword.isEmpty
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
                
                VStack(spacing: 0) {
                    // Header with back button - separate from scroll content
                    headerSection
                    
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 20)
                            
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
                            
                            // Password Form Section
                            passwordForm
                            
                            // Reset Password Button
                            resetPasswordButton
                            
                            Spacer(minLength: 32)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: errorMessage)
        .animation(.easeInOut(duration: 0.3), value: successMessage)
        .alert("Password Reset Successfully", isPresented: $showingSuccessAlert) {
            Button("Continue to Login") {
                onPasswordResetSuccess()
            }
        } message: {
            Text("Your password has been reset successfully. You can now log in with your new password.")
        }
    }
}

// MARK: - View Components
private extension NewPasswordView {
    
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
                onBackToCodeVerification()
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
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
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
                
                Image(systemName: "key.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("Create New Password")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Enter a strong password for your account")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 32)
    }
    
    var passwordForm: some View {
        VStack(spacing: 24) {
            // New Password Field with Validation
            VStack(spacing: 12) {
                AuthTextFieldView(
                    title: "New Password",
                    placeholder: "Enter your new password",
                    iconName: "lock",
                    text: $newPassword,
                    isPasswordVisible: $isNewPasswordVisible,
                    textContentType: .newPassword,
                    isDisabled: isLoading,
                    onPasswordVisibilityToggle: {
                        isNewPasswordVisible.toggle()
                    }
                )
                
                // Password validation display - appears right after password field
                PasswordValidationView.passwordStrength(password: newPassword)
            }
            
            // Confirm Password Field with Match Validation
            VStack(spacing: 8) {
                AuthTextFieldView(
                    title: "Confirm New Password",
                    placeholder: "Confirm your new password",
                    iconName: "lock",
                    text: $confirmPassword,
                    isPasswordVisible: $isConfirmPasswordVisible,
                    textContentType: .newPassword,
                    isDisabled: isLoading,
                    onPasswordVisibilityToggle: {
                        isConfirmPasswordVisible.toggle()
                    }
                )
                
                // Password match indicator - appears right after confirm password field
                PasswordMatchIndicatorView(
                    password: newPassword,
                    confirmPassword: confirmPassword
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    var resetPasswordButton: some View {
        VStack(spacing: 16) {
            AuthButtonView(
                title: "Reset Password",
                loadingTitle: "Resetting Password...",
                isLoading: isLoading,
                isEnabled: isFormValid
            ) {
                handleResetPassword()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
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
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Private Methods
private extension NewPasswordView {
    
    func handleResetPassword() {
        // Clear any previous messages
        errorMessage = nil
        successMessage = nil
        
        // Validate form
        guard isFormValid else {
            errorMessage = "Please ensure your password meets all requirements and both passwords match"
            return
        }
        
        // Start loading
        isLoading = true
        
        // Make API call to reset password
        Task {
            do {
                // Create reset password request
                let resetRequest = ResetPasswordRequest(
                    email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                    code: code,
                    newPassword: newPassword
                )
                
                // Call the backend API
                let response: SuccessResponse = try await NetworkService.shared.post(
                    endpoint: Config.API.Endpoints.resetPassword,
                    body: resetRequest,
                    responseType: SuccessResponse.self
                )
                
                // Handle successful response
                await MainActor.run {
                    isLoading = false
                    successMessage = response.message
                    showingSuccessAlert = true
                    
                    // Clear sensitive data
                    clearPasswords()
                    
                    print("Password reset successful: \(response.message)")
                }
                
            } catch {
                // Handle API errors
                await MainActor.run {
                    isLoading = false
                    handleResetPasswordError(error)
                    print("Password reset failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleResetPasswordError(_ error: Error) {
        switch error {
        case APIError.serverError(let code, let message):
            switch code {
            case 400:
                errorMessage = "Invalid reset code or password format. Please try again."
            case 404:
                errorMessage = "Account not found. Please start the password reset process again."
            default:
                errorMessage = message ?? "Server error occurred. Please try again."
            }
        case APIError.networkError:
            errorMessage = "Network connection failed. Please check your internet connection."
        case APIError.timeout:
            errorMessage = "Request timed out. Please try again."
        case APIError.unauthorized:
            errorMessage = "Reset code has expired. Please request a new code."
        default:
            errorMessage = "Failed to reset password. Please try again."
        }
    }
    
    func clearPasswords() {
        newPassword = ""
        confirmPassword = ""
        isNewPasswordVisible = false
        isConfirmPasswordVisible = false
    }
}

// MARK: - Convenience Initializer for Previews
extension NewPasswordView {
    init() {
        self.email = "user@example.com"
        self.code = "123456"
        self.onBackToCodeVerification = {}
        self.onPasswordResetSuccess = {}
    }
}

struct NewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NewPasswordView()
    }
}
