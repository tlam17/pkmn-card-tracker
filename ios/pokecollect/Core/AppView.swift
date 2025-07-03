//
//  AppView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/3/25.
//

import SwiftUI

struct AppView: View {
    // MARK: - Authentication Manager
        @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                ContentView()
            } else {
                AuthenticationFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
    }
}

// MARK: - Authentication Flow View
struct AuthenticationFlowView: View {
    @State private var selectedTab: AuthTab = .login
    
    enum AuthTab: CaseIterable {
        case login, signup
        
        var title: String {
            switch self {
            case .login: return "Login"
            case .signup: return "Sign Up"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LoginView()
                .tag(AuthTab.login)
            
            SignupView()
                .tag(AuthTab.signup)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            // Custom tab selector at the top
            VStack {
                authTabSelector
                Spacer()
            }
        )
        .ignoresSafeArea()
    }
    
    private var authTabSelector: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(AuthTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(tab.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                            
                            Rectangle()
                                .fill(selectedTab == tab ? Color.white : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
            .background(Color.clear)
        }
    }
}

#Preview {
    AppView()
}
