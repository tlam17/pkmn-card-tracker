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
                AuthenticationView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
    }
}

#Preview {
    AppView()
}
