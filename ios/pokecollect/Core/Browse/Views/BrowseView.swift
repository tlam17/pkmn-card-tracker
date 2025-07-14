//
//  BrowseView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/13/25.
//

import SwiftUI

// MARK: - Mock Data Models
struct MockCardSet {
    let id: String
    let name: String
    let series: String
    let totalCards: Int
    let releaseDate: String
    let symbolUrl: String?
    let logoUrl: String?
}

struct MockSeries {
    let name: String
    let sets: [MockCardSet]
}

struct BrowseView: View {
    
    // MARK: - State Properties
    @State private var expandedSeries: Set<String> = []
    @State private var isLoading = false
    @State private var searchText = ""
    
    // MARK: - Mock Data
    private let mockSeriesData: [MockSeries] = [
        MockSeries(name: "Scarlet & Violet", sets: [
            MockCardSet(id: "sv6", name: "Twilight Masquerade", series: "Scarlet & Violet", totalCards: 226, releaseDate: "2024-05-24", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sv5", name: "Temporal Forces", series: "Scarlet & Violet", totalCards: 218, releaseDate: "2024-03-22", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sv4", name: "Paradox Rift", series: "Scarlet & Violet", totalCards: 266, releaseDate: "2023-11-03", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sv3", name: "Obsidian Flames", series: "Scarlet & Violet", totalCards: 230, releaseDate: "2023-08-11", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sv2", name: "Paldea Evolved", series: "Scarlet & Violet", totalCards: 279, releaseDate: "2023-06-09", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sv1", name: "Scarlet & Violet Base Set", series: "Scarlet & Violet", totalCards: 198, releaseDate: "2023-03-31", symbolUrl: nil, logoUrl: nil)
        ]),
        MockSeries(name: "Sword & Shield", sets: [
            MockCardSet(id: "swsh12", name: "Silver Tempest", series: "Sword & Shield", totalCards: 245, releaseDate: "2022-11-11", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "swsh11", name: "Lost Origin", series: "Sword & Shield", totalCards: 196, releaseDate: "2022-09-09", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "swsh10", name: "Astral Radiance", series: "Sword & Shield", totalCards: 189, releaseDate: "2022-05-27", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "swsh9", name: "Brilliant Stars", series: "Sword & Shield", totalCards: 172, releaseDate: "2022-02-25", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "swsh8", name: "Fusion Strike", series: "Sword & Shield", totalCards: 264, releaseDate: "2021-11-12", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "swsh7", name: "Evolving Skies", series: "Sword & Shield", totalCards: 237, releaseDate: "2021-08-27", symbolUrl: nil, logoUrl: nil)
        ]),
        MockSeries(name: "Sun & Moon", sets: [
            MockCardSet(id: "sm12", name: "Cosmic Eclipse", series: "Sun & Moon", totalCards: 236, releaseDate: "2019-11-01", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sm11", name: "Unified Minds", series: "Sun & Moon", totalCards: 236, releaseDate: "2019-08-02", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sm10", name: "Unbroken Bonds", series: "Sun & Moon", totalCards: 214, releaseDate: "2019-05-03", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sm9", name: "Team Up", series: "Sun & Moon", totalCards: 181, releaseDate: "2019-02-01", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sm8", name: "Lost Thunder", series: "Sun & Moon", totalCards: 214, releaseDate: "2018-11-02", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "sm1", name: "Sun & Moon Base Set", series: "Sun & Moon", totalCards: 149, releaseDate: "2017-02-03", symbolUrl: nil, logoUrl: nil)
        ]),
        MockSeries(name: "XY", sets: [
            MockCardSet(id: "xy12", name: "Evolutions", series: "XY", totalCards: 108, releaseDate: "2016-11-02", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "xy11", name: "Steam Siege", series: "XY", totalCards: 114, releaseDate: "2016-08-03", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "xy10", name: "Fates Collide", series: "XY", totalCards: 124, releaseDate: "2016-05-02", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "xy1", name: "XY Base Set", series: "XY", totalCards: 146, releaseDate: "2014-02-05", symbolUrl: nil, logoUrl: nil)
        ]),
        MockSeries(name: "Classic", sets: [
            MockCardSet(id: "base1", name: "Base Set", series: "Classic", totalCards: 102, releaseDate: "1999-01-09", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "jungle", name: "Jungle", series: "Classic", totalCards: 64, releaseDate: "1999-06-16", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "fossil", name: "Fossil", series: "Classic", totalCards: 62, releaseDate: "1999-10-10", symbolUrl: nil, logoUrl: nil),
            MockCardSet(id: "base2", name: "Base Set 2", series: "Classic", totalCards: 130, releaseDate: "2000-02-24", symbolUrl: nil, logoUrl: nil)
        ])
    ]
    
    // MARK: - Computed Properties
    private var filteredSeries: [MockSeries] {
        if searchText.isEmpty {
            return mockSeriesData
        } else {
            return mockSeriesData.compactMap { series in
                let filteredSets = series.sets.filter { set in
                    set.name.localizedCaseInsensitiveContains(searchText) ||
                    set.series.localizedCaseInsensitiveContains(searchText)
                }
                
                if !filteredSets.isEmpty || series.name.localizedCaseInsensitiveContains(searchText) {
                    return MockSeries(name: series.name, sets: filteredSets.isEmpty ? series.sets : filteredSets)
                }
                return nil
            }
        }
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
                
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Search Bar
                    searchSection
                    
                    // Content
                    if isLoading {
                        loadingView
                    } else {
                        seriesListView
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Simulate loading
            simulateDataLoad()
        }
    }
}

// MARK: - View Components
private extension BrowseView {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Browse Cards")
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
    
    var seriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredSeries, id: \.name) { series in
                    SeriesDropdownView(
                        series: series,
                        isExpanded: expandedSeries.contains(series.name),
                        onToggle: {
                            toggleSeries(series.name)
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
    
    func toggleSeries(_ seriesName: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedSeries.contains(seriesName) {
                expandedSeries.remove(seriesName)
            } else {
                expandedSeries.insert(seriesName)
            }
        }
    }
    
    func simulateDataLoad() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
}

// MARK: - Series Dropdown Component
struct SeriesDropdownView: View {
    let series: MockSeries
    let isExpanded: Bool
    let onToggle: () -> Void
    
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
                        
                        Text("\(series.sets.count) sets")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Expand/collapse indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: isExpanded ? 16 : 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Sets List (Expandable)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(series.sets, id: \.id) { set in
                        SetRowView(set: set)
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
    let set: MockCardSet
    
    var body: some View {
        Button(action: {
            // TODO: Navigate to set detail
            print("Tapped on set: \(set.name)")
        }) {
            HStack(spacing: 16) {
                // Set symbol placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    if let symbolUrl = set.symbolUrl {
                        // TODO: Load actual image
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
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
                    
                    HStack(spacing: 12) {
                        Text("\(set.totalCards) cards")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(formatDate(set.releaseDate))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
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
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Preview
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
