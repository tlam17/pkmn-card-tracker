//
//  ContentView.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Browse Tab
            BrowseView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "magnifyingglass" : "magnifyingglass")
                    Text("Browse")
                }
                .tag(0)
            
            // Collection Tab
            CollectionView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "folder.fill" : "folder")
                    Text("Collection")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(.white)
        .background(
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
        )
        .onAppear {
            // Configure tab bar appearance
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.backgroundColor = UIColor(Color.mint.opacity(0.7))
        
        // Normal item appearance
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        // Selected item appearance
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - Placeholder Views

struct CollectionView: View {
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
                Image(systemName: "folder.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("My Collection")
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

struct ProfileView: View {
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
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Profile & Settings")
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
    ContentView()
}
