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
}

struct AuthenticationView: View {
    @State private var currentFlow: AuthenticationFlow = .login
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentFlow {
                case .login:
                    LoginView(onSignUpTapped: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentFlow = .signup
                        }
                    })
                case .signup:
                    SignupView(onLoginTapped: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentFlow = .login
                        }
                    })
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
