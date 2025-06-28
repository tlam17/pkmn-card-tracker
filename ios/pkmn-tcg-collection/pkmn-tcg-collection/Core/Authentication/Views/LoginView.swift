//
//  LoginView.swift
//  pkmn-tcg-collection
//
//  Created by Tyler Lam on 6/27/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient - Emerald & Forest Theme
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
                
                // Floating orbs for visual appeal
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 200, height: 200)
                    .offset(x: -100, y: -200)
                
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 150, height: 150)
                    .offset(x: 120, y: -300)
                
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .offset(x: 150, y: 200)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 60)
                        
                        // Logo and Title Section
                        VStack(spacing: 20) {
                            // App Logo/Icon
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 8) {
                                Text("PokéCollect")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Track your card collection")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.bottom, 50)
                        
                        // Login Form
                        VStack(spacing: 24) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
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
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(.white.opacity(0.7))
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
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    // Handle forgot password
                                }
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, -8)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                        
                        // Login Button
                        VStack(spacing: 16) {
                            Button(action: {
                                // Handle login
                                isLoading = true
                                // Simulate loading
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isLoading)
                            .scaleEffect(isLoading ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isLoading)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("or")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 16)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button("Sign Up") {
                                // Navigate to sign up
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        }
                        .font(.footnote)
                        .padding(.bottom, 32)
                        
                        Spacer(minLength: 32)
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
