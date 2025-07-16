//
//  ImageCacheService.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/15/25.
//


//
//  ImageCacheService.swift
//  pokecollect
//
//  Created by Tyler Lam on 7/15/25.
//

import SwiftUI
import Foundation

// MARK: - Image Cache Service
final class ImageCacheService: ObservableObject {
    
    // MARK: - Shared Instance
    static let shared = ImageCacheService()
    
    // MARK: - Properties
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    
    // MARK: - Initialization
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        // Configure cache
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Public Methods
    
    /// Load image from URL with caching
    func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return nil
        }
        
        // Check cache first
        let cacheKey = NSString(string: urlString)
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Download image
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(urlString)")
                return nil
            }
            
            // Cache the image
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            print("Failed to load image from URL \(urlString): \(error)")
            return nil
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage<Placeholder: View>: View {
    private let url: String?
    private let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: String?,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { oldValue, newValue in
            loadImage()
        }
    }
    
    private func loadImage() {
        guard url != nil, image == nil else { return }
        
        isLoading = true
        
        Task {
            let loadedImage = await ImageCacheService.shared.loadImage(from: url)
            
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        }
    }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Placeholder == EmptyView {
    init(url: String?) {
        self.init(url: url) {
            EmptyView()
        }
    }
}

extension CachedAsyncImage {
    /// Initializer with a default placeholder
    init(
        url: String?,
        placeholderSystemImage: String = "photo",
        placeholderColor: Color = .white.opacity(0.6)
    ) where Placeholder == AnyView {
        self.init(url: url) {
            AnyView(
                Image(systemName: placeholderSystemImage)
                    .font(.system(size: 16))
                    .foregroundColor(placeholderColor)
            )
        }
    }
}