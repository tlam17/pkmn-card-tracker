//
//  CardDetailView.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/30/25.
//

import SwiftUI

struct CardDetailView: View {
    
    // MARK: - Properties
    let card: Card
    let cardSet: CardSet
    let onBack: () -> Void
    
    // MARK: - State Properties
    @State private var selectedImageType: ImageType = .large
    @State private var showingImageZoom = false
    @State private var isImageLoading = true
    
    // MARK: - Image Type Selection
    enum ImageType: String, CaseIterable {
        case large = "High Resolution"
        case small = "Standard"
        
        var systemImage: String {
            switch self {
            case .large:
                return "photo.badge.plus"
            case .small:
                return "photo"
            }
        }
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Card Image Section
                    cardImageSection
                    
                    // Card Information Section
                    cardInfoSection
                    
                    // Bottom padding for navigation
                    Color.clear
                        .frame(height: 100)
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
    }
}

// MARK: - View Components
private extension CardDetailView {
    
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
            
            // Card title and set info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 12) {
                            Text("\(cardSet.series) • \(cardSet.name)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("#\(card.displayNumber)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.15))
                                )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    var cardImageSection: some View {
        VStack(spacing: 16) {
            // Card image
            VStack(spacing: 12) {
                Button(action: {
                    showingImageZoom = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .aspectRatio(0.7, contentMode: .fit)
                            .frame(maxWidth: 280)
                        
                        if let imageUrl = currentImageUrl {
                            CachedAsyncImage(
                                url: imageUrl,
                                placeholderSystemImage: "photo",
                                placeholderColor: .white.opacity(0.6)
                            )
                            .aspectRatio(0.7, contentMode: .fit)
                            .frame(maxWidth: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Image Not Available")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: 280)
                            .aspectRatio(0.7, contentMode: .fit)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Image quality indicator
                if currentImageUrl != nil {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Tap image to zoom")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }
    
    var cardInfoSection: some View {
        VStack(spacing: 16) {
            // Quick stats
            HStack(spacing: 16) {
                StatBoxView(
                    title: "Card Number",
                    value: "#\(card.displayNumber)",
                    icon: "number"
                )
                
                StatBoxView(
                    title: "Set",
                    value: cardSet.name,
                    icon: "rectangle.stack"
                )
            }
            .padding(.horizontal, 20)
            
            // Additional details section
            VStack(spacing: 12) {
                HStack {
                    Text("Card Details")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    DetailRowView(
                        label: "Full Name",
                        value: card.name
                    )
                    
                    DetailRowView(
                        label: "Card ID",
                        value: card.id
                    )
                    
                    DetailRowView(
                        label: "Series",
                        value: cardSet.series
                    )
                    
                    DetailRowView(
                        label: "Set Name",
                        value: cardSet.name
                    )
                    
                    DetailRowView(
                        label: "Release Date",
                        value: cardSet.formattedReleaseDate
                    )
                    
                    DetailRowView(
                        label: "Language",
                        value: cardSet.language
                    )
                    
                    if card.largeImageUrl != nil || card.smallImageUrl != nil {
                        DetailRowView(
                            label: "Image Available",
                            value: "✓ Yes"
                        )
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
}

// MARK: - Supporting Components

// MARK: - Stat Box Component
struct StatBoxView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Detail Row Component
struct DetailRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Card Image Zoom View
struct CardImageZoomView: View {
    let imageUrl: String?
    let cardName: String
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            // Image with zoom and pan capabilities
            if let imageUrl = imageUrl {
                CachedAsyncImage(
                    url: imageUrl,
                    placeholderSystemImage: "photo",
                    placeholderColor: .white.opacity(0.6)
                )
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                            
                            // Limit scale
                            if scale < 0.5 {
                                scale = 0.5
                            } else if scale > 4.0 {
                                scale = 4.0
                            }
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            
                            // Snap back if too small
                            if scale < 1.0 {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            }
                        }
                        .simultaneously(with:
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Image Not Available")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 40, height: 40)
                            )
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                
                Spacer()
            }
            
            // Instructions overlay (shows briefly)
            if scale == 1.0 && offset == .zero {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Double tap to zoom • Pinch to scale • Drag to pan")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.6))
                            )
                    }
                    .padding(.bottom, 50)
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden()
        .onTapGesture {
            if scale == 1.0 {
                onDismiss()
            }
        }
    }
}

// MARK: - Preview
struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(
            card: Card.example,
            cardSet: CardSet.example,
            onBack: {}
        )
    }
}
