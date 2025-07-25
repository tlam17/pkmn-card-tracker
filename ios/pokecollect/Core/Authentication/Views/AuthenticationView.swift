//
//  AuthenticationView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/3/25.
//

import SwiftUI

enum AuthenticationFlow {
    case login
    case signup
    case forgotPassword
    case codeVerification(email: String)
    case newPassword(email: String, code: String)
}

struct AuthenticationView: View {
    @State private var currentFlow: AuthenticationFlow = .login
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentFlow {
                case .login:
                    LoginView(
                        onSignUpTapped: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .signup
                            }
                        },
                        onForgotPasswordTapped: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .forgotPassword
                            }
                        }
                    )
                case .signup:
                    SignupView(onLoginTapped: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentFlow = .login
                        }
                    })
                case .forgotPassword:
                    ForgotPasswordView(
                        onBackToLogin: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .login
                            }
                        },
                        onCodeSent: { email in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .codeVerification(email: email)
                            }
                        }
                    )
                case .codeVerification(let email):
                    CodeVerificationView(
                        email: email,
                        onBackToForgotPassword: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .forgotPassword
                            }
                        },
                        onCodeVerified: { email, code in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .newPassword(email: email, code: code)
                            }
                        }
                    )
                case .newPassword(let email, let code):
                    NewPasswordView(
                        email: email,
                        code: code,
                        onBackToCodeVerification: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .codeVerification(email: email)
                            }
                        },
                        onPasswordResetSuccess: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentFlow = .login
                            }
                        }
                    )
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .navigationBarHidden(true)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
