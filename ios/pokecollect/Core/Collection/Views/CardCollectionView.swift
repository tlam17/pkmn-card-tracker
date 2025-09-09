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
    
    // MARK: - State
    @State private var quantity: Int = 0
    @State private var originalQuantity: Int = 0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: Bool = false
    @State private var collectionEntry: CollectionEntry?
    @State private var showingImageZoom: Bool = false
    
    // MARK: - Services
    private let collectionService: CollectionServiceProtocol
    
    // MARK: - Image Selection
    enum ImageType {
        case large, small
    }
    @State private var selectedImageType: ImageType = .large
    
    // MARK: - Initialization
    init(
        card: Card,
        cardSet: CardSet,
        onBack: @escaping () -> Void,
        collectionService: CollectionServiceProtocol = CollectionService()
    ) {
        self.card = card
        self.cardSet = cardSet
        self.onBack = onBack
        self.collectionService = collectionService
    }
    
    // MARK: - Computed Properties
    private var currentImageUrl: String? {
        switch selectedImageType {
        case .large:
            return card.largeImageUrl ?? card.smallImageUrl
        case .small:
            return card.smallImageUrl ?? card.largeImageUrl
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient (keeping as requested)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.gray.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Card Image Section
                    cardImageSection
                    
                    // Collection Management Section
                    collectionSection
                    
                    // Bottom padding for navigation
                    Color.clear
                        .frame(height: 100)
                }
            }
            
            // Success message overlay
            if showSuccessMessage {
                VStack {
                    Spacer()
                    successMessageOverlay
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showingImageZoom) {
            CardImageZoomView(
                imageUrl: currentImageUrl,
                cardName: card.name,
                onDismiss: {
                    showingImageZoom = false
                }
            )
        }
        .task {
            await loadCollectionData()
        }
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
                    )
                }
                
                Spacer()
            }
            
            // Collection title
            HStack {
                Text("Manage Your Collection")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    var cardImageSection: some View {
        VStack(spacing: 16) {
            // Card image with tap to zoom
            Button(action: { showingImageZoom = true }) {
                AsyncImage(url: URL(string: currentImageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
                .frame(maxWidth: 300, maxHeight: 420)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Card stats grid
            HStack(spacing: 12) {
                StatBoxView(
                    title: "Number",
                    value: "\(card.number) / \(cardSet.printedTotal)",
                    icon: "number"
                )
                
                StatBoxView(
                    title: "Rarity",
                    value: card.rarity,
                    icon: "star.fill"
                )
                
                StatBoxView(
                    title: "Set",
                    value: cardSet.name,
                    icon: "rectangle.stack.fill"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }
    
    var collectionSection: some View {
        VStack(spacing: 16) {
            // Collection management section
            VStack(spacing: 12) {
                
                // Current quantity display
                VStack(spacing: 16) {
                    // Quantity controls
                    HStack(spacing: 24) {
                        // Decrement button
                        Button(action: decrementQuantity) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(quantity > 0 ? .red : .gray.opacity(0.5))
                        }
                        .disabled(quantity <= 0 || isLoading)
                        
                        // Current quantity
                        Text("\(quantity)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 60)
                            .animation(.easeInOut(duration: 0.2), value: quantity)
                        
                        // Increment button
                        Button(action: incrementQuantity) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(isLoading ? .gray.opacity(0.5) : .green)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.vertical, 8)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        // Save changes button
                        Button(action: { Task { await saveCollection() } }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                }
                                
                                Text(isLoading ? "Saving..." : "Save Changes")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(hasChanges ? Color.blue : Color.gray.opacity(0.5))
                            )
                        }
                        .disabled(!hasChanges || isLoading)
                        
                        // Reset button
                        if hasChanges {
                            Button(action: resetQuantity) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.title3)
                                    
                                    Text("Reset")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .disabled(isLoading)
                        }
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Button("Dismiss") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.errorMessage = nil
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
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
    
    // Computed properties
    var hasChanges: Bool {
        quantity != originalQuantity
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
    
    func resetQuantity() {
        withAnimation(.easeInOut(duration: 0.2)) {
            quantity = originalQuantity
        }
        errorMessage = nil
    }
    
    func loadCollectionData() async {
        // TODO: Get user ID from auth service
        // For now, using a placeholder user ID
        let userId = 1
        
        do {
            let userCollection = try await collectionService.getUserCollection(userId: userId)
            
            // Find this card in the user's collection
            if let entry = userCollection.first(where: { $0.card.id == card.id }) {
                await MainActor.run {
                    self.collectionEntry = CollectionEntry(
                        id: entry.id,
                        userId: entry.userId,
                        quantity: entry.quantity,
                        acquiredDate: entry.acquiredDate,
                        card: nil
                    )
                    self.quantity = entry.quantity
                    self.originalQuantity = entry.quantity
                }
            } else {
                await MainActor.run {
                    self.quantity = 0
                    self.originalQuantity = 0
                }
            }
        } catch {
            await MainActor.run {
                print("Failed to load collection data: \(error)")
                // Set defaults if unable to load
                self.quantity = 0
                self.originalQuantity = 0
            }
        }
    }
    
    func saveCollection() async {
        // Prevent multiple saves
        guard !isLoading else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // TODO: Get user ID from auth service
        let userId = 1
        
        do {
            if quantity == 0 && collectionEntry != nil {
                // Delete the entry if quantity is 0 and entry exists
                try await collectionService.removeFromCollection(entryId: collectionEntry.id)
                await MainActor.run {
                    self.collectionEntry = nil
                }
            } else if quantity > 0 {
                // Add or update the entry
                let updatedEntry = try await collectionService.addToCollection(
                    cardId: card.id,
                    userId: userId,
                    quantity: quantity
                )
                await MainActor.run {
                    self.collectionEntry = updatedEntry
                }
            }
            
            // Success handling
            await MainActor.run {
                self.originalQuantity = self.quantity
                self.isLoading = false
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showSuccessMessage = true
                }
                
                // Hide success message after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showSuccessMessage = false
                    }
                }
            }
        } catch {
            // Error handling
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to update collection. Please try again."
                print("Failed to save collection: \(error)")
            }
        }
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
