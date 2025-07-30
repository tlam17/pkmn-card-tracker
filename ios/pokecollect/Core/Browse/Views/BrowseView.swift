//
//  BrowseView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/13/25.
//

import SwiftUI

enum BrowseNavigation {
    case setsList
    case setDetail(CardSet)
}

struct BrowseView: View {
    
    // MARK: - State Properties
    @State private var expandedSeries: Set<String> = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var cardSets: [CardSet] = []
    @State private var errorMessage: String? = nil
    @State private var hasLoadedData = false
    @State private var currentNavigation: BrowseNavigation = .setsList
    
    // MARK: - Services
    private let cardSetsService: CardSetsServiceProtocol
    
    // MARK: - Available Series
    private let availableSeries = ["Scarlet & Violet", "Sword & Shield", "Sun & Moon", "X & Y", "Black & White", "HeartGold & SoulSilver", "Platinum", "Diamond & Pearl", "EX", "E-Card", "Neo", "Gym", "Base"]
    
    // MARK: - Computed Properties
    private var organizedSeries: [Series] {
        var seriesDict: [String: [CardSet]] = [:]
        
        // Filter sets based on search text
        let filteredSets = cardSets.filter { set in
            searchText.isEmpty ||
            set.name.localizedCaseInsensitiveContains(searchText) ||
            set.series.localizedCaseInsensitiveContains(searchText)
        }
        
        // Group sets by series
        for set in filteredSets {
            if seriesDict[set.series] == nil {
                seriesDict[set.series] = []
            }
            seriesDict[set.series]?.append(set)
        }
        
        // Convert to Series objects and sort sets by release date (newest first)
        return seriesDict.map { (seriesName, sets) in
            let sortedSets = sets.sorted { first, second in
                // Sort by release date descending (newest first)
                return first.releaseDate > second.releaseDate
            }
            return Series(name: seriesName, sets: sortedSets)
        }.sorted { firstSeries, secondSeries in
            // Sort by the order in availableSeries array
            let firstIndex = availableSeries.firstIndex(of: firstSeries.name) ?? Int.max
            let secondIndex = availableSeries.firstIndex(of: secondSeries.name) ?? Int.max
            return firstIndex < secondIndex }
    }
    
    // MARK: - Initialization
    init(cardSetsService: CardSetsServiceProtocol = CardSetsService()) {
        self.cardSetsService = cardSetsService
    }
    
    var body: some View {
        NavigationView {
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
                    case .setsList:
                        setsListContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    case .setDetail(let cardSet):
                        SetDetailView(
                            cardSet: cardSet,
                            onBack: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentNavigation = .setsList
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
        }
        .navigationBarHidden(true)
        .onAppear {
            if !hasLoadedData {
                loadCardSets()
            }
        }
    }
    
    // MARK: - Sets List Content
    private var setsListContent: some View {
        VStack(spacing: 0) {
            // Header Section
            headerSection
            
            // Search Bar
            searchSection
            
            // Content
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if organizedSeries.isEmpty && hasLoadedData {
                emptyStateView
            } else {
                seriesListView
            }
        }
        .refreshable {
            await refreshData()
        }
    }
}

// MARK: - View Components
private extension BrowseView {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Browse Sets")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
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
                    
                    TextField("Search sets or series...", text: $searchText)
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
            
            Text("Loading card sets...")
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
            
            Text("Error Loading Sets")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                loadCardSets()
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
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No Sets Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Try adjusting your search terms or check back later.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var seriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(organizedSeries, id: \.name) { series in
                    SeriesDropdownView(
                        series: series,
                        isExpanded: expandedSeries.contains(series.name),
                        onToggle: {
                            toggleSeries(series.name)
                        },
                        onSetTapped: { cardSet in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentNavigation = .setDetail(cardSet)
                            }
                        }
                    )
                }
                
                // Bottom padding for tab bar
                Color.clear
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Private Methods
private extension BrowseView {
    
    func toggleSeries(_ seriesName: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedSeries.contains(seriesName) {
                expandedSeries.remove(seriesName)
            } else {
                expandedSeries.insert(seriesName)
            }
        }
    }
    
    func loadCardSets() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                var allSets: [CardSet] = []
                
                // Load sets for each available series
                for series in availableSeries {
                    let sets = try await cardSetsService.getSetsBySeries(series)
                    allSets.append(contentsOf: sets)
                }
                
                await MainActor.run {
                    self.cardSets = allSets
                    self.hasLoadedData = true
                    self.isLoading = false
                    
                    // Auto-expand the first series if we have data
                    if let firstSeries = organizedSeries.first {
                        expandedSeries.insert(firstSeries.name)
                    }
                }
            } catch {
                await MainActor.run {
                    self.hasLoadedData = true
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @MainActor
    func refreshData() async {
        do {
            var allSets: [CardSet] = []
            
            // Load sets for each available series
            for series in availableSeries {
                let sets = try await cardSetsService.getSetsBySeries(series)
                allSets.append(contentsOf: sets)
            }
            
            self.cardSets = allSets
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Series Dropdown Component
struct SeriesDropdownView: View {
    let series: Series
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSetTapped: (CardSet) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Series Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Series icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(series.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Expand/collapse indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Sets List (Expandable)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(series.sets) { set in
                        SetRowView(set: set, onTap: {
                            onSetTapped(set)
                        })
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.top, -8)
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

// MARK: - Set Row Component
struct SetRowView: View {
    let set: CardSet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Set logo/symbol image
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    // Use logo if available, fallback to symbol, then to placeholder
                    if let logoUrl = set.logoUrl, !logoUrl.isEmpty {
                        CachedAsyncImage(
                            url: logoUrl,
                            placeholderSystemImage: "photo",
                            placeholderColor: .white.opacity(0.6)
                        )
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else if let symbolUrl = set.symbolUrl, !symbolUrl.isEmpty {
                        CachedAsyncImage(
                            url: symbolUrl,
                            placeholderSystemImage: "photo",
                            placeholderColor: .white.opacity(0.6)
                        )
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        // Fallback to initials
                        Text(String(set.name.prefix(2)).uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(set.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(cardSetsService: MockCardSetsService())
    }
}
