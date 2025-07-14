//
//  BrowseView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/13/25.
//

import SwiftUI

struct BrowseView: View {
    var body: some View {
        ZStack {
            // Same background gradient as auth views
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
            
            VStack(spacing: 20) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Browse Sets & Cards")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Coming soon...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    BrowseView()
}
