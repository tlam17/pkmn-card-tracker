//
//  AuthTextFieldView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//


//
//  AuthTextFieldView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/1/25.
//

import SwiftUI

// MARK: - Authentication Text Field Component
struct AuthTextFieldView: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    let iconName: String
    @Binding var text: String
    var isSecure: Bool = false
    var isPasswordField: Bool = false
    @Binding var isPasswordVisible: Bool
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var isDisabled: Bool = false
    var onPasswordVisibilityToggle: (() -> Void)? = nil
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
                
                if isPasswordField {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .textContentType(textContentType)
                            .disabled(isDisabled)
                    } else {
                        SecureField(placeholder, text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .textContentType(textContentType)
                            .disabled(isDisabled)
                    }
                    
                    Button(action: {
                        onPasswordVisibilityToggle?()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .disabled(isDisabled)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .disabled(isDisabled)
                }
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
    }
}

// MARK: - Convenience Initializers
extension AuthTextFieldView {
    
    // Standard text field
    init(
        title: String,
        placeholder: String,
        iconName: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: UITextAutocapitalizationType = .sentences,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.iconName = iconName
        self._text = text
        self.isSecure = false
        self.isPasswordField = false
        self._isPasswordVisible = .constant(false)
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.isDisabled = isDisabled
        self.onPasswordVisibilityToggle = nil
    }
    
    // Password field
    init(
        title: String,
        placeholder: String,
        iconName: String,
        text: Binding<String>,
        isPasswordVisible: Binding<Bool>,
        textContentType: UITextContentType? = nil,
        isDisabled: Bool = false,
        onPasswordVisibilityToggle: @escaping () -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.iconName = iconName
        self._text = text
        self.isSecure = true
        self.isPasswordField = true
        self._isPasswordVisible = isPasswordVisible
        self.keyboardType = .default
        self.textContentType = textContentType
        self.autocapitalization = .none
        self.isDisabled = isDisabled
        self.onPasswordVisibilityToggle = onPasswordVisibilityToggle
    }
}

// MARK: - Preview
struct AuthTextFieldView_Previews: PreviewProvider {
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
                // Regular text field
                AuthTextFieldView(
                    title: "Email",
                    placeholder: "Enter your email",
                    iconName: "envelope",
                    text: .constant(""),
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .none
                )
                
                // Password field
                AuthTextFieldView(
                    title: "Password",
                    placeholder: "Enter your password",
                    iconName: "lock",
                    text: .constant(""),
                    isPasswordVisible: .constant(false),
                    textContentType: .password,
                    onPasswordVisibilityToggle: {}
                )
            }
            .padding()
        }
    }
}
