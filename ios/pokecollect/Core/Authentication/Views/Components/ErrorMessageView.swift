//
//  ErrorMessageView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//

import SwiftUI

// MARK: - Error Message Component
struct ErrorMessageView: View {
    
    // MARK: - Properties
    let message: String
    let onDismiss: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red.opacity(0.7))
                    }
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

// MARK: - Convenience Initializers
extension ErrorMessageView {
    
    // Error message without dismiss button
    init(message: String) {
        self.message = message
        self.onDismiss = nil
    }
    
    // Error message with dismiss button
    init(message: String, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }
}

// MARK: - Preview
struct ErrorMessageView_Previews: PreviewProvider {
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
                // Error message without dismiss
                ErrorMessageView(message: "Invalid email or password. Please try again.")
                
                // Error message with dismiss
                ErrorMessageView(
                    message: "Network connection failed. Please check your internet connection.",
                    onDismiss: {}
                )
            }
        }
    }
}
