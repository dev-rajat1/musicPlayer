//
//  HomeView.swift
//  musicPlayer
//

import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @ObservedObject var dataService = MusicDataService.shared
    
    @State private var selectedGenre: String = "All"
    let genrePills = ["All", "Romance", "Punjabi", "Lo-Fi", "Party", "Sufi", "Feel Good"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                // Ambient background glow
                RadialGradient(
                    gradient: Gradient(colors: [AppTheme.primaryAccent.opacity(0.18), Color.clear]),
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 350
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Top Greeting Header
                        headerView
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // Genre Filter Pills
                        genrePillBar
                        
                        // Featured Hero Carousel
                        heroBannerSection
                        
                        // Quick Play Grid (Recently Played / Favorites)
                        quickPlaySection
                            .padding(.horizontal, 20)
                        
                        // Trending Bollywood Charts
                        trendingSection
                        
                        // Curated Playlists
                        playlistsSection
                        
                        // Popular Artists
                        popularArtistsSection
                        
                        // Bottom spacer for mini player
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.cyanAccent)
                
                Text("Music Hub")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Notification / Equalizer quick shortcut
            Button(action: {
                HapticManager.shared.impact(.light)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.amberAccent)
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "GOOD MORNING ☀️"
        case 12..<17: return "GOOD AFTERNOON 🌤️"
        default: return "GOOD EVENING 🌙"
        }
    }
    
    // MARK: - Genre Pills
    private var genrePillBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(genrePills, id: \.self) { genre in
                    Button(action: {
                        selectedGenre = genre
                        HapticManager.shared.selection()
                    }) {
                        Text(genre)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedGenre == genre ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedGenre == genre ? AppTheme.primaryAccent : Color.white.opacity(0.06))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Hero Banner Carousel
    private var heroBannerSection: some View {
        let filteredSongs = selectedGenre == "All" ? dataService.allSongs : dataService.allSongs.filter { $0.genre.localizedCaseInsensitiveContains(selectedGenre) }
        let displaySongs = filteredSongs.isEmpty ? dataService.allSongs : filteredSongs
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(displaySongs.prefix(4)) { song in
                    ZStack(alignment: .bottomLeading) {
                        // Background gradient artwork
                        RemoteImageView(
                            url: song.artworkURL,
                            placeholderGradient: LinearGradient(
                                gradient: Gradient(colors: song.gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            cornerRadius: 22
                        )
                        .frame(width: 310, height: 180)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.85)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                        )
                        
                        // Text & Play Button Overlay
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("FEATURED TRACK")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundColor(AppTheme.amberAccent)
                                
                                Text(song.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(song.artist)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            // Play Button
                            Button(action: {
                                playerManager.play(song: song, in: dataService.allSongs)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryGradient)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: AppTheme.primaryAccent.opacity(0.6), radius: 8, x: 0, y: 4)
                                    
                                    Image(systemName: (playerManager.currentSong?.id == song.id && playerManager.isPlaying) ? "pause.fill" : "play.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .frame(width: 310, height: 180)
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Quick Play Grid
    private var quickPlaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Play")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(dataService.allSongs.prefix(6)) { song in
                    Button(action: {
                        playerManager.play(song: song, in: dataService.allSongs)
                    }) {
                        HStack(spacing: 10) {
                            RemoteImageView(
                                url: song.artworkURL,
                                placeholderGradient: LinearGradient(
                                    gradient: Gradient(colors: song.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                cornerRadius: 8
                            )
                            .frame(width: 44, height: 44)
                            
                            Text(song.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(6)
                        .background(Color(hex: "#161C28").opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(playerManager.currentSong?.id == song.id ? AppTheme.primaryAccent : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🔥 Top Bollywood Hits")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {
                    playerManager.play(song: dataService.allSongs[0], in: dataService.allSongs)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.primaryAccent)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(dataService.allSongs.enumerated()), id: \.element.id) { index, song in
                        Button(action: {
                            playerManager.play(song: song, in: dataService.allSongs)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .topTrailing) {
                                    RemoteImageView(
                                        url: song.artworkURL,
                                        placeholderGradient: LinearGradient(
                                            gradient: Gradient(colors: song.gradientColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        cornerRadius: 14
                                    )
                                    .frame(width: 140, height: 140)
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                                    
                                    // Rank Badge
                                    Text("#\(index + 1)")
                                        .font(.system(size: 11, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Capsule())
                                        .padding(8)
                                }
                                
                                Text(song.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(song.artist)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(1)
                            }
                            .frame(width: 140)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Curated Playlists Section
    private var playlistsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Featured Playlists")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(dataService.playlists) { playlist in
                        Button(action: {
                            let songs = dataService.songs(for: playlist)
                            if let first = songs.first {
                                playerManager.play(song: first, in: songs)
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: playlist.coverColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "music.note.list")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white.opacity(0.9))
                                            Text("\(playlist.songIds.count) Songs")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    )
                                    .shadow(color: playlist.coverColors.first?.opacity(0.4) ?? Color.clear, radius: 10, x: 0, y: 5)
                                
                                Text(playlist.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(playlist.description)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(2)
                            }
                            .frame(width: 150)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Popular Artists Section
    private var popularArtistsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Popular Artists")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(dataService.artists) { artist in
                        Button(action: {
                            let artistSongs = dataService.allSongs.filter { artist.topSongIds.contains($0.id) }
                            if let first = artistSongs.first {
                                playerManager.play(song: first, in: artistSongs)
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: artist.gradientColors),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                }
                                .shadow(color: artist.gradientColors.first?.opacity(0.4) ?? Color.clear, radius: 8, x: 0, y: 4)
                                
                                Text(artist.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(artist.monthlyListeners)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                                    .lineLimit(1)
                            }
                            .frame(width: 90)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
