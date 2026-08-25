//
//  CustomComponents.swift
//  musicPlayer
//

import SwiftUI
import UIKit
import Combine

// MARK: - Image Loader / Remote Image View
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private static let cache = NSCache<NSURL, UIImage>()
    
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 4
        config.timeoutIntervalForResource = 8
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    func load(from url: URL?) {
        guard let url = url else { return }
        
        if let cachedImage = Self.cache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = Self.session.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                if let downloadedImage = downloadedImage {
                    Self.cache.setObject(downloadedImage, forKey: url as NSURL)
                }
                self?.image = downloadedImage
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

struct RemoteImageView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL?
    var placeholderGradient: LinearGradient = AppTheme.primaryGradient
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderGradient
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.85))
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            if let url = url {
                loader.load(from: url)
            }
        }
        .onChange(of: url) { newUrl in
            if let newUrl = newUrl {
                loader.load(from: newUrl)
            }
        }
    }
}

// MARK: - Animated Audio Visualizer Bars
struct AudioVisualizerView: View {
    let isPlaying: Bool
    var barCount: Int = 18
    var accentColors: [Color] = [AppTheme.primaryAccent, AppTheme.secondaryAccent]
    
    @State private var barHeights: [CGFloat] = []
    let timer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: accentColors),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(
                        width: 3.5,
                        height: isPlaying ? (barHeights.indices.contains(index) ? barHeights[index] : 8) : 4
                    )
                    .animation(Animation.easeInOut(duration: 0.12), value: barHeights)
            }
        }
        .frame(height: 36)
        .onAppear {
            setupInitialBars()
        }
        .onReceive(timer) { _ in
            if isPlaying {
                updateBars()
            } else {
                barHeights = Array(repeating: 4, count: barCount)
            }
        }
    }
    
    private func setupInitialBars() {
        barHeights = (0..<barCount).map { _ in CGFloat.random(in: 6...32) }
    }
    
    private func updateBars() {
        barHeights = (0..<barCount).map { index in
            let factor = sin(Double(index) * 0.4 + Date().timeIntervalSince1970 * 4)
            let base = CGFloat.random(in: 8...34)
            return max(5, min(36, base + CGFloat(factor * 6)))
        }
    }
}

// MARK: - Vinyl Record Disc View
struct VinylRecordView: View {
    let song: Song
    let isPlaying: Bool
    var size: CGFloat = 260
    
    @State private var rotationAngle: Double = 0
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Vinyl outer shadow & base
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color(hex: "#1E1E24"), Color(hex: "#0A0A0C"), Color.black]),
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: song.gradientColors.first?.opacity(0.35) ?? Color.black.opacity(0.6), radius: 24, x: 0, y: 12)
            
            // Vinyl Groove rings
            ForEach([0.88, 0.76, 0.64, 0.52, 0.42], id: \.self) { scale in
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 1.2)
                    .frame(width: size * CGFloat(scale), height: size * CGFloat(scale))
            }
            
            // Subtle Vinyl Gloss Reflection
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.clear,
                            Color.white.opacity(0.12),
                            Color.clear,
                            Color.white.opacity(0.08)
                        ]),
                        center: .center
                    ),
                    lineWidth: size * 0.35
                )
                .frame(width: size * 0.65, height: size * 0.65)
                .blendMode(.screen)
            
            // Center Album Artwork Label
            RemoteImageView(
                url: song.artworkURL,
                placeholderGradient: LinearGradient(
                    gradient: Gradient(colors: song.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cornerRadius: size * 0.175
            )
            .frame(width: size * 0.35, height: size * 0.35)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            
            // Center Spindle Hole
            Circle()
                .fill(Color(hex: "#090B10"))
                .frame(width: size * 0.08, height: size * 0.08)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                )
        }
        .rotationEffect(.degrees(rotationAngle))
        .onReceive(timer) { _ in
            if isPlaying {
                rotationAngle += 0.8
                if rotationAngle >= 360 {
                    rotationAngle = 0
                }
            }
        }
    }
}

// MARK: - Custom Audio Scrubber Slider
struct CustomScrubberSlider: View {
    @Binding var progress: Double // 0.0 to 1.0
    let currentTimeText: String
    let durationText: String
    var accentGradient: LinearGradient = AppTheme.primaryGradient
    var onScrubStart: (() -> Void)? = nil
    var onScrubEnd: ((Double) -> Void)? = nil
    
    @State private var isDragging: Bool = false
    @State private var dragProgress: Double = 0.0
    
    var activeProgress: Double {
        isDragging ? dragProgress : progress
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track Background
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: isDragging ? 7 : 5)
                    
                    // Filled Track with Glow
                    Capsule()
                        .fill(accentGradient)
                        .frame(
                            width: max(0, min(geo.size.width, geo.size.width * CGFloat(activeProgress))),
                            height: isDragging ? 7 : 5
                        )
                    
                    // Thumb Handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: isDragging ? 18 : 12, height: isDragging ? 18 : 12)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        )
                        .offset(x: max(0, min(geo.size.width - (isDragging ? 18 : 12), (geo.size.width * CGFloat(activeProgress)) - (isDragging ? 9 : 6))))
                }
                .frame(height: 24)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                                onScrubStart?()
                                HapticManager.shared.selection()
                            }
                            let newProgress = max(0, min(1, Double(value.location.x / geo.size.width)))
                            dragProgress = newProgress
                        }
                        .onEnded { value in
                            let finalProgress = max(0, min(1, Double(value.location.x / geo.size.width)))
                            isDragging = false
                            onScrubEnd?(finalProgress)
                            HapticManager.shared.impact(.light)
                        }
                )
            }
            .frame(height: 24)
            
            // Timestamps
            HStack {
                Text(currentTimeText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Spacer()
                
                Text(durationText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Animated Heart Favorite Button
struct HeartBurstButton: View {
    @Binding var isFavorite: Bool
    var onToggle: (() -> Void)? = nil
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            isFavorite.toggle()
            HapticManager.shared.impact(.medium)
            
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
                scale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            onToggle?()
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isFavorite ? AppTheme.secondaryAccent : Color.white.opacity(0.8))
                .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
