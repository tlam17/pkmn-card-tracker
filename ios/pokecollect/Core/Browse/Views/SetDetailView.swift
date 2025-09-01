//
//  SetDetailView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/21/25.
//

import SwiftUI

enum SetDetailNavigation: Equatable {
    case cardsList
    case cardDetail(Card)
    case cardCollection(Card)
    
    static func == (lhs: SetDetailNavigation, rhs: SetDetailNavigation) -> Bool {
        switch (lhs, rhs) {
        case (.cardsList, .cardsList):
            return true
        case (.cardDetail(let lhsCard), .cardDetail(let rhsCard)):
            return lhsCard.id == rhsCard.id
        case (.cardCollection(let lhsCard), .cardCollection(let rhsCard)):
            return lhsCard.id == rhsCard.id
        default:
            return false
        }
    }
}

struct SetDetailView: View {
    
    // MARK: - Properties
    let cardSet: CardSet
    let onBack: () -> Void
    
    // MARK: - State Properties
    @State private var cards: [Card] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var currentNavigation: SetDetailNavigation = .cardsList
    
    // MARK: - Services
    private let cardsService: CardsServiceProtocol
    
    // MARK: - Grid Configuration
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 12)
    ]
    
    // MARK: - Computed Properties
    private var filteredCards: [Card] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.displayNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var sortedCards: [Card] {
        filteredCards.sorted { first, second in
            // Sort by card number (convert to Int for proper ordering)
            let firstNum = Int(first.displayNumber) ?? Int.max
            let secondNum = Int(second.displayNumber) ?? Int.max
            return firstNum < secondNum
        }
    }
    
    // MARK: - Initialization
    init(
        cardSet: CardSet,
        onBack: @escaping () -> Void,
        cardsService: CardsServiceProtocol = CardsService()
    ) {
        self.cardSet = cardSet
        self.onBack = onBack
        self.cardsService = cardsService
    }
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            // Content based on current navigation
            Group {
                switch currentNavigation {
                case .cardsList:
                    cardsListContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                case .cardDetail(let card):
                    CardDetailView(
                        card: card,
                        cardSet: cardSet,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentNavigation = .cardsList
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                case .cardCollection(let card):
                    CardCollectionView(
                        card: card,
                        cardSet: cardSet,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentNavigation = .cardsList
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
        .onAppear {
            if currentNavigation == .cardsList && cards.isEmpty {
                loadCards()
            }
        }
        .refreshable {
            if currentNavigation == .cardsList {
                await refreshCards()
            }
        }
    }
    
    // MARK: - Cards List Content
    private var cardsListContent: some View {
        VStack(spacing: 0) {
            // Header Section
            headerSection
            
            // Search Bar
            if !cards.isEmpty {
                searchSection
            }
            
            // Content
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if sortedCards.isEmpty && !cards.isEmpty {
                noSearchResultsView
            } else if cards.isEmpty {
                emptyStateView
            } else {
                cardsGridView
            }
        }
    }
}

// MARK: - View Components
private extension SetDetailView {
    
    var headerSection: some View {
        VStack(spacing: 12) {
            // Back button and set info
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
            
            // Set information
            HStack(spacing: 16) {
                // Set logo/symbol
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    if let logoUrl = cardSet.logoUrl, !logoUrl.isEmpty {
                        CachedAsyncImage(
                            url: logoUrl,
                            placeholderSystemImage: "photo",
                            placeholderColor: .white.opacity(0.6)
                        )
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if let symbolUrl = cardSet.symbolUrl, !symbolUrl.isEmpty {
                        CachedAsyncImage(
                            url: symbolUrl,
                            placeholderSystemImage: "photo",
                            placeholderColor: .white.opacity(0.6)
                        )
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cardSet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(cardSet.series)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    if !cards.isEmpty {
                        Text("\(cards.count) cards")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    var searchSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16))
                    
                    TextField("Search cards...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Loading cards...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Error Loading Cards")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                loadCards()
            }) {
                Text("Try Again")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var noSearchResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No Cards Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("No cards match '\(searchText)'. Try adjusting your search.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                searchText = ""
            }) {
                Text("Clear Search")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No Cards Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("This set doesn't have any cards loaded yet.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var cardsGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedCards) { card in
                    CardGridItemView(
                        card: card,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentNavigation = .cardCollection(card)
                            }
                        },
                        onViewDetails: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentNavigation = .cardDetail(card)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra padding for tab bar
        }
    }
}

// MARK: - Private Methods
private extension SetDetailView {
    
    func loadCards() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedCards = try await cardsService.getCardsBySetId(cardSet.id)
                
                await MainActor.run {
                    self.cards = fetchedCards
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @MainActor
    func refreshCards() async {
        do {
            let fetchedCards = try await cardsService.getCardsBySetId(cardSet.id)
            self.cards = fetchedCards
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Card Grid Item Component
struct CardGridItemView: View {
    let card: Card
    let onTap: () -> Void
    let onViewDetails: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Card image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                        .aspectRatio(0.7, contentMode: .fit) // Standard card aspect ratio
                    
                    if let imageUrl = card.bestImageUrl {
                        CachedAsyncImage(
                            url: imageUrl,
                            placeholderSystemImage: "photo",
                            placeholderColor: .white.opacity(0.6)
                        )
                        .aspectRatio(0.7, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("No Image")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .contextMenu {
            // Context menu for additional actions
            Button(action: onViewDetails) {
                Label("View Details", systemImage: "info.circle")
            }
            
            Button(action: onTap) {
                Label("Manage Collection", systemImage: "square.stack.3d.up")
            }
            
            Button(action: {
                // Future wishlist functionality
                print("Add to wishlist: \(card.name)")
            }) {
                Label("Add to Wishlist", systemImage: "heart")
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview
struct SetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SetDetailView(
            cardSet: CardSet.example,
            onBack: {},
            cardsService: MockCardsService()
        )
    }
}
