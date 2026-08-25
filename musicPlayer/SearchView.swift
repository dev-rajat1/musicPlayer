//
//  SearchView.swift
//  musicPlayer
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @ObservedObject var dataService = MusicDataService.shared
    
    @State private var searchText: String = ""
    @State private var recentSearches: [String] = ["Arijit Singh", "Kesariya", "Diljit Dosanjh", "Lo-Fi Bollywood", "Pritam"]
    
    let browseCategories: [(title: String, gradient: LinearGradient, icon: String)] = [
        ("Bollywood Romance", AppTheme.sunsetGradient, "heart.fill"),
        ("Punjabi Pop & Beats", AppTheme.neonCyanGradient, "flame.fill"),
        ("90s Evergreen Hindi", AppTheme.purpleNightGradient, "sparkles"),
        ("Sufi & Soulful", AppTheme.emeraldGradient, "moon.stars.fill"),
        ("Party & Dance Club", AppTheme.primaryGradient, "bolt.fill"),
        ("Lo-Fi & Study Chill", AppTheme.darkGlassGradient, "headphones")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header Title
                    HStack {
                        Text("Search")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search Bollywood songs, artists, lyrics...", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .onChange(of: searchText) { newValue in
                                dataService.searchSongs(query: newValue)
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                dataService.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#1A202E").opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Content
                    if dataService.isSearching {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryAccent))
                                .scaleEffect(1.2)
                            Text("Searching Bollywood music...")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    } else if !searchText.isEmpty {
                        // Search Results List
                        if dataService.searchResults.isEmpty {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("No tracks found for \"\(searchText)\"")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                        } else {
                            searchResultsList
                        }
                    } else {
                        // Default Browse & Recent Searches View
                        defaultBrowseView
                    }
                    
                    // Bottom Spacer for mini player
                    Spacer().frame(height: 80)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(dataService.searchResults) { song in
                    Button(action: {
                        playerManager.play(song: song, in: dataService.searchResults)
                        if !recentSearches.contains(song.title) {
                            recentSearches.insert(song.title, at: 0)
                        }
                    }) {
                        HStack(spacing: 12) {
                            RemoteImageView(
                                url: song.artworkURL,
                                placeholderGradient: LinearGradient(
                                    colors: song.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                cornerRadius: 10
                            )
                            .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(song.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(playerManager.currentSong?.id == song.id ? AppTheme.cyanAccent : .white)
                                    .lineLimit(1)
                                
                                Text(song.artist)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.65))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Visualizer if playing
                            if playerManager.currentSong?.id == song.id {
                                AudioVisualizerView(
                                    isPlaying: playerManager.isPlaying,
                                    barCount: 6,
                                    accentColors: song.gradientColors
                                )
                            }
                            
                            Text(song.formattedDuration)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(playerManager.currentSong?.id == song.id ? 0.08 : 0.03))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Default Browse & Category Cards
    private var defaultBrowseView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Searches")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(recentSearches, id: \.self) { search in
                                    Button(action: {
                                        searchText = search
                                        dataService.searchSongs(query: search)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .font(.system(size: 11))
                                            Text(search)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .foregroundColor(.white.opacity(0.85))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                // Browse Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Explore Genres & Moods")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(browseCategories, id: \.title) { item in
                            Button(action: {
                                searchText = item.title
                                dataService.searchSongs(query: item.title)
                            }) {
                                ZStack(alignment: .bottomLeading) {
                                    item.gradient
                                        .frame(height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    
                                    HStack {
                                        Text(item.title)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .padding(12)
                                        
                                        Spacer()
                                        
                                        Image(systemName: item.icon)
                                            .font(.system(size: 26))
                                            .foregroundColor(.white.opacity(0.3))
                                            .padding(12)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 20)
        }
    }
}
