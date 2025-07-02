//
//  AuthButtonView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//

import SwiftUI

// MARK: - Authentication Button Component
struct AuthButtonView: View {
    
    // MARK: - Properties
    let title: String
    let loadingTitle: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text(loadingTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Text(title)
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
                        isEnabled ? Color.yellow : Color.gray.opacity(0.6),
                        isEnabled ? Color.orange : Color.gray.opacity(0.4)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isLoading ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isLoading)
    }
}

// MARK: - Convenience Initializers
extension AuthButtonView {
    
    // Standard auth button with default loading title
    init(
        title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.loadingTitle = "Loading..."
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
}

// MARK: - Preview
struct AuthButtonView_Previews: PreviewProvider {
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
            
            VStack(spacing: 20) {
                // Normal state
                AuthButtonView(
                    title: "Sign In",
                    isLoading: false,
                    isEnabled: true,
                    action: {}
                )
                
                // Loading state
                AuthButtonView(
                    title: "Sign In",
                    loadingTitle: "Signing In...",
                    isLoading: true,
                    isEnabled: true,
                    action: {}
                )
                
                // Disabled state
                AuthButtonView(
                    title: "Sign In",
                    isLoading: false,
                    isEnabled: false,
                    action: {}
                )
            }
            .padding()
        }
    }
}
