//
//  CodeVerificationView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/8/25.
//

import SwiftUI

struct CodeVerificationView: View {
    
    // MARK: - Navigation Callbacks
    let email: String
    let onBackToForgotPassword: () -> Void
    let onCodeVerified: (String, String) -> Void // email, code
    
    // MARK: - State Properties
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var resendCooldown = 0
    @State private var timer: Timer?
    @State private var showingSuccessAlert = false
    @State private var isResendingCode = false
    
    // MARK: - Code Input State
    @State private var verificationCodeInput = ""
    
    // MARK: - Computed Properties
    private var currentCode: String {
        verificationCodeInput
    }
    
    private var isCodeComplete: Bool {
        currentCode.count == 6 && currentCode.allSatisfy { $0.isNumber }
    }
    
    private var canResendCode: Bool {
        resendCooldown == 0 && !isLoading && !isResendingCode
    }
    
    private var timeRemaining: String {
        let minutes = resendCooldown / 60
        let seconds = resendCooldown % 60
        return String(format: "%d:%02d", minutes, seconds)
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
                    
                    // Scrollable content - properly centered
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
                            
                            // Code Input Section
                            codeInputSection
                            
                            // Verify Button
                            verifyButton
                            
                            // Resend Code Section
                            resendCodeSection
                            
                            // Instructions
                            instructionsSection
                            
                            Spacer(minLength: 32)
                        }
                        .frame(maxWidth: .infinity) // Ensure full width usage
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: errorMessage)
        .animation(.easeInOut(duration: 0.3), value: successMessage)
        .onAppear {
            startResendCooldown()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Code Verified Successfully", isPresented: $showingSuccessAlert) {
            Button("Continue") {
                onCodeVerified(email, currentCode)
            }
        } message: {
            Text("Your verification code has been confirmed. You can now reset your password.")
        }
    }
}

// MARK: - View Components
private extension CodeVerificationView {
    
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
                onBackToForgotPassword()
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
            .disabled(isLoading || isResendingCode)
            
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
                
                Image(systemName: "envelope.badge")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text("Check Your Email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("We've sent a 6-digit verification code to")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity) // Ensure proper centering
        .padding(.bottom, 32)
    }
    
    var codeInputSection: some View {
        VStack(spacing: 16) {
            // Single input field for the 6-digit code
            AuthTextFieldView(
                title: "",
                placeholder: "Enter 6-digit code",
                iconName: "key",
                text: $verificationCodeInput,
                keyboardType: .numberPad,
                autocapitalization: .none,
                isDisabled: isLoading || isResendingCode
            )
            
            // Code expiration timer
            if resendCooldown > 0 {
                Text("Code expires in \(timeRemaining)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity) // Ensure proper centering
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .onChange(of: verificationCodeInput) { oldValue, newValue in
            // Limit to 6 digits only
            let filtered = newValue.filter { $0.isNumber }
            if filtered.count <= 6 {
                verificationCodeInput = filtered
            } else {
                verificationCodeInput = String(filtered.prefix(6))
            }
            
            // Auto-submit when code is complete
            if verificationCodeInput.count == 6 && !isLoading {
                handleVerifyCode()
            }
        }
    }

    
    var verifyButton: some View {
        VStack(spacing: 16) {
            AuthButtonView(
                title: "Verify Code",
                loadingTitle: "Verifying...",
                isLoading: isLoading,
                isEnabled: isCodeComplete && !isResendingCode
            ) {
                handleVerifyCode()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    var resendCodeSection: some View {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            // Resend Code Button
            if canResendCode {
                Button(action: {
                    handleResendCode()
                }) {
                    HStack {
                        if isResendingCode {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Sending...")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        } else {
                            Text("Resend Code")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(isResendingCode || isLoading)
            } else {
                Text("Resend code in \(timeRemaining)")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity) // Ensure proper centering
        .padding(.bottom, 32)
    }
    
    var instructionsSection: some View {
        VStack(spacing: 12) {
            Text("Didn't receive the code?")
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                instructionRow(
                    icon: "envelope",
                    text: "Check your spam/junk folder"
                )
                
                instructionRow(
                    icon: "clock",
                    text: "Wait a few minutes for delivery"
                )
                
                instructionRow(
                    icon: "arrow.clockwise",
                    text: "Request a new code if needed"
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .frame(width: 20)
            
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
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Private Methods
private extension CodeVerificationView {
    
    func handleVerifyCode() {
        // Clear any previous messages
        errorMessage = nil
        successMessage = nil
        
        // Validate code
        guard isCodeComplete else {
            errorMessage = "Please enter the complete 6-digit verification code"
            return
        }
        
        // Start loading
        isLoading = true
        
        // Make actual API call to backend
        Task {
            do {
                // Create verify code request
                let verifyRequest = VerifyResetCodeRequest(
                    email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                    code: currentCode
                )
                
                // Call the backend API
                let response: SuccessResponse = try await NetworkService.shared.post(
                    endpoint: "/api/auth/verify-reset-code",
                    body: verifyRequest,
                    responseType: SuccessResponse.self
                )
                
                // Handle successful response
                await MainActor.run {
                    isLoading = false
                    successMessage = response.message
                    showingSuccessAlert = true
                    print("Code verification successful: \(response.message)")
                }
                
            } catch {
                // Handle API errors
                await MainActor.run {
                    isLoading = false
                    handleVerificationError(error)
                    clearCode()
                    print("Code verification failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleResendCode() {
        // Clear any previous messages
        errorMessage = nil
        successMessage = nil
        
        // Start resending loading state
        isResendingCode = true
        
        // Make actual API call to resend code
        Task {
            do {
                // Create forgot password request (same as initial request)
                let forgotPasswordRequest = ForgotPasswordRequest(
                    email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                // Call the backend API to resend code
                let response: SuccessResponse = try await NetworkService.shared.post(
                    endpoint: "/api/auth/forgot-password",
                    body: forgotPasswordRequest,
                    responseType: SuccessResponse.self
                )
                
                // Handle successful response
                await MainActor.run {
                    isResendingCode = false
                    successMessage = response.message
                    
                    // Start cooldown timer
                    startResendCooldown()
                    
                    // Clear current code
                    clearCode()
                    
                    print("Code resent successfully: \(response.message)")
                }
                
            } catch {
                // Handle API errors
                await MainActor.run {
                    isResendingCode = false
                    handleResendError(error)
                    print("Code resend failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleVerificationError(_ error: Error) {
        switch error {
        case APIError.serverError(let code, let message):
            if code == 400 {
                errorMessage = "Invalid or expired verification code. Please try again."
            } else {
                errorMessage = message ?? "Server error occurred. Please try again."
            }
        case APIError.networkError:
            errorMessage = "Network connection failed. Please check your internet connection."
        case APIError.timeout:
            errorMessage = "Request timed out. Please try again."
        default:
            errorMessage = "Verification failed. Please check your code and try again."
        }
    }
    
    func handleResendError(_ error: Error) {
        switch error {
        case APIError.serverError(let code, let message):
            if code == 400 {
                errorMessage = "Unable to resend code. Please try again later."
            } else {
                errorMessage = message ?? "Failed to resend code. Please try again."
            }
        case APIError.networkError:
            errorMessage = "Network connection failed. Unable to resend code."
        case APIError.timeout:
            errorMessage = "Request timed out. Please try resending the code again."
        default:
            errorMessage = "Failed to resend code. Please try again."
        }
    }
    
    func clearCode() {
        verificationCodeInput = ""
    }
    
    func startResendCooldown() {
        resendCooldown = 300 // 5 minutes
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if resendCooldown > 0 {
                resendCooldown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

// MARK: - Convenience Initializer for Previews
extension CodeVerificationView {
    init() {
        self.email = "user@example.com"
        self.onBackToForgotPassword = {}
        self.onCodeVerified = { _, _ in }
    }
}

struct CodeVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        CodeVerificationView()
    }
}
