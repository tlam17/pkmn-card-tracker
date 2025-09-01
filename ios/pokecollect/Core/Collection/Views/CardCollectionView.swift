//
//  CardCollectionView.swift
//  pokecollect
//
//  Created by Tyler Lam on 8/29/25.
//

import SwiftUI

struct CardCollectionView: View {
    
    // MARK: - Properties
    let card: Card
    let cardSet: CardSet
    let onBack: () -> Void
    
    // MARK: - State Properties
    @State private var quantity: Int = 0
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            // Background gradient (matching your existing theme)
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Content Section
                    contentSection
                    
                    // Bottom padding
                    Color.clear
                        .frame(height: 100)
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .overlay(
            // Success message overlay
            Group {
                if showSuccessMessage {
                    successMessageOverlay
                }
            }
        )
    }
}

// MARK: - View Components
private extension CardCollectionView {
    
    var headerSection: some View {
        VStack(spacing: 12) {
            // Back button and title
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    var contentSection: some View {
        VStack(spacing: 24) {
            // Card Image and Basic Info
            cardImageSection
            
            // Quantity Management Section
            quantitySection
            
            // Save Button
            saveButtonSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var cardImageSection: some View {
        VStack(spacing: 16) {
            // Card Image
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                if let imageUrl = card.bestImageUrl {
                    CachedAsyncImage(
                        url: imageUrl,
                        placeholderSystemImage: "photo",
                        placeholderColor: .white.opacity(0.6)
                    )
                    .frame(width: 200, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No Image")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // Card Name and Set Info
            VStack(spacing: 8) {
                Text(card.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Text("#\(card.displayNumber)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(cardSet.name)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    var quantitySection: some View {
        VStack(spacing: 20) {
            // Quantity Control
            HStack(spacing: 24) {
                // Minus Button
                Button(action: decrementQuantity) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(quantity > 0 ? 0.2 : 0.1))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(quantity > 0 ? 0.4 : 0.2), lineWidth: 1)
                                )
                        )
                }
                .disabled(quantity <= 0)
                .opacity(quantity > 0 ? 1.0 : 0.5)
                
                // Quantity Display
                Text("\(quantity)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 80)
                
                // Plus Button
                Button(action: incrementQuantity) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 20)
            
            // Quick Quantity Buttons
            HStack(spacing: 12) {
                ForEach([1, 5, 10], id: \.self) { quickValue in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            quantity = quickValue
                        }
                    }) {
                        Text("\(quickValue)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(quantity == quickValue ? 0.3 : 0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        quantity = 0
                    }
                }) {
                    Text("Clear")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(quantity == 0 ? 0.3 : 0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    var saveButtonSection: some View {
        Button(action: saveCollection) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(isLoading ? "Saving..." : "Save to Collection")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
    
    var successMessageOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)
            
            Text("Collection Updated!")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Actions
private extension CardCollectionView {
    
    func incrementQuantity() {
        withAnimation(.easeInOut(duration: 0.1)) {
            quantity += 1
        }
    }
    
    func decrementQuantity() {
        if quantity > 0 {
            withAnimation(.easeInOut(duration: 0.1)) {
                quantity -= 1
            }
        }
    }
    
    func saveCollection() {
        // Prevent multiple saves
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            // Simulate random success/failure for demo
            if Bool.random() {
                // Success
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSuccessMessage = true
                }
                
                // Hide success message after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSuccessMessage = false
                    }
                }
            } else {
                // Simulate error
                errorMessage = "Failed to update collection. Please try again."
            }
        }
        
        // TODO: Replace with actual API call
        // Try await collectionService.updateCardQuantity(cardId: card.id, quantity: quantity)
        print("Saving card \(card.name) with quantity \(quantity)")
    }
}

// MARK: - Preview
struct CardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CardCollectionView(
            card: Card.example,
            cardSet: CardSet.example,
            onBack: {}
        )
    }
}
