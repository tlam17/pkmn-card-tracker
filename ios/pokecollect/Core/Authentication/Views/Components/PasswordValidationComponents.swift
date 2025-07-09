//
//  PasswordValidationComponents.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/9/25.
//

import SwiftUI

// MARK: - Password Requirement Model
struct PasswordRequirement {
    let text: String
    let isMet: Bool
}

// MARK: - Password Requirements Generator
struct PasswordRequirementsGenerator {
    static func getRequirements(for password: String) -> [PasswordRequirement] {
        return [
            PasswordRequirement(
                text: "At least 8 characters",
                isMet: password.count >= Config.Validation.Auth.passwordMinLength
            ),
            PasswordRequirement(
                text: "One uppercase letter (A-Z)",
                isMet: password.range(of: "[A-Z]", options: .regularExpression) != nil
            ),
            PasswordRequirement(
                text: "One lowercase letter (a-z)",
                isMet: password.range(of: "[a-z]", options: .regularExpression) != nil
            ),
            PasswordRequirement(
                text: "One number (0-9)",
                isMet: password.range(of: "[0-9]", options: .regularExpression) != nil
            ),
            PasswordRequirement(
                text: "One special character (@$!%*?&)",
                isMet: password.range(of: "[@$!%*?&]", options: .regularExpression) != nil
            )
        ]
    }
    
    static func isPasswordStrong(_ password: String) -> Bool {
        return getRequirements(for: password).allSatisfy { $0.isMet }
    }
}

// MARK: - Valid Password Indicator Component
struct ValidPasswordIndicatorView: View {
    let isPasswordStrong: Bool
    
    var body: some View {
        Group {
            if isPasswordStrong {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text("Valid password")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green.opacity(0.4), lineWidth: 1)
                        )
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale),
                    removal: .opacity.combined(with: .scale)
                ))
                .animation(.easeInOut(duration: 0.3), value: isPasswordStrong)
            }
        }
    }
}

// MARK: - Password Requirements View Component
struct PasswordRequirementsView: View {
    let passwordRequirements: [PasswordRequirement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Password Requirements")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .leading)
            ], spacing: 6) {
                ForEach(passwordRequirements, id: \.text) { requirement in
                    HStack(spacing: 8) {
                        Image(systemName: requirement.isMet ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 12))
                            .foregroundColor(requirement.isMet ? .green : .white.opacity(0.5))
                        
                        Text(requirement.text)
                            .font(.caption2)
                            .foregroundColor(requirement.isMet ? .white : .white.opacity(0.7))
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale),
            removal: .opacity.combined(with: .scale)
        ))
        .animation(.easeInOut(duration: 0.3), value: passwordRequirements.map { $0.isMet })
    }
}

// MARK: - Password Match Indicator Component
struct PasswordMatchIndicatorView: View {
    let password: String
    let confirmPassword: String
    
    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    var body: some View {
        Group {
            if !confirmPassword.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(passwordsMatch ? .green : .red)
                    
                    Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                        .font(.caption2)
                        .foregroundColor(passwordsMatch ? .white : .red.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(passwordsMatch ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(passwordsMatch ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.2), value: passwordsMatch)
            }
        }
    }
}

// MARK: - Combined Password Validation View
struct PasswordValidationView: View {
    let password: String
    let confirmPassword: String?
    let showRequirements: Bool
    
    private let passwordRequirements: [PasswordRequirement]
    private let isPasswordStrong: Bool
    
    init(password: String, confirmPassword: String? = nil, showRequirements: Bool = true) {
        self.password = password
        self.confirmPassword = confirmPassword
        self.showRequirements = showRequirements
        self.passwordRequirements = PasswordRequirementsGenerator.getRequirements(for: password)
        self.isPasswordStrong = PasswordRequirementsGenerator.isPasswordStrong(password)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Password strength indicator
            if !password.isEmpty && showRequirements {
                if isPasswordStrong {
                    ValidPasswordIndicatorView(isPasswordStrong: isPasswordStrong)
                } else {
                    PasswordRequirementsView(passwordRequirements: passwordRequirements)
                }
            }
            
            // Password match indicator (only if confirmPassword is provided)
            if let confirmPassword = confirmPassword {
                PasswordMatchIndicatorView(
                    password: password,
                    confirmPassword: confirmPassword
                )
            }
        }
    }
}

// MARK: - Convenience Extensions
extension PasswordValidationView {
    /// For use cases where only password strength validation is needed (no confirm password)
    static func passwordStrength(password: String) -> PasswordValidationView {
        return PasswordValidationView(
            password: password,
            confirmPassword: nil,
            showRequirements: true
        )
    }
    
    /// For use cases where both password strength and match validation are needed
    static func passwordWithConfirmation(password: String, confirmPassword: String) -> PasswordValidationView {
        return PasswordValidationView(
            password: password,
            confirmPassword: confirmPassword,
            showRequirements: true
        )
    }
    
    /// For use cases where you want to hide requirements but still validate
    static func minimal(password: String, confirmPassword: String? = nil) -> PasswordValidationView {
        return PasswordValidationView(
            password: password,
            confirmPassword: confirmPassword,
            showRequirements: false
        )
    }
}

// MARK: - Validation Helper Functions
extension PasswordValidationView {
    /// Check if password meets strength requirements
    var isPasswordValid: Bool {
        return PasswordRequirementsGenerator.isPasswordStrong(password)
    }
    
    /// Check if passwords match (returns true if no confirmPassword provided)
    var passwordsMatch: Bool {
        guard let confirmPassword = confirmPassword else { return true }
        return !confirmPassword.isEmpty && password == confirmPassword
    }
    
    /// Check if both password is valid AND passwords match
    var isFormValid: Bool {
        return isPasswordValid && passwordsMatch
    }
}

// MARK: - Preview
struct PasswordValidationComponents_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.9),
                    Color.teal.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Weak password example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weak Password Example:")
                            .foregroundColor(.white)
                            .font(.headline)
                        PasswordValidationView.passwordWithConfirmation(
                            password: "weak",
                            confirmPassword: "weak"
                        )
                    }
                    
                    // Strong password example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Strong Password Example:")
                            .foregroundColor(.white)
                            .font(.headline)
                        PasswordValidationView.passwordWithConfirmation(
                            password: "StrongPass123!",
                            confirmPassword: "StrongPass123!"
                        )
                    }
                    
                    // Password mismatch example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password Mismatch Example:")
                            .foregroundColor(.white)
                            .font(.headline)
                        PasswordValidationView.passwordWithConfirmation(
                            password: "StrongPass123!",
                            confirmPassword: "DifferentPass456@"
                        )
                    }
                    
                    // Password strength only
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password Strength Only:")
                            .foregroundColor(.white)
                            .font(.headline)
                        PasswordValidationView.passwordStrength(password: "Progress123!")
                    }
                }
                .padding()
            }
        }
    }
}
