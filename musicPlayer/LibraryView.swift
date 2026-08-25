//
//  LibraryView.swift
//  musicPlayer
//

import SwiftUI
import UIKit

struct LibraryView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @ObservedObject var dataService = MusicDataService.shared
    
    @State private var selectedTab: Int = 0
    @State private var showCreatePlaylistSheet: Bool = false
    @State private var newPlaylistName: String = ""
    @State private var newPlaylistDesc: String = ""
    @State private var selectedColorHex: String = "#8B5CF6"
    
    let colorOptions = ["#8B5CF6", "#EC4899", "#06B6D4", "#10B981", "#F59E0B", "#EF4444"]
    
    var favoriteSongs: [Song] {
        dataService.allSongs.filter { $0.isFavorite }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Text("Your Library")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showCreatePlaylistSheet = true
                            HapticManager.shared.impact(.light)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primaryAccent)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Segmented Tabs
                    Picker("Library Filter", selection: $selectedTab) {
                        Text("Favorites (\(favoriteSongs.count))").tag(0)
                        Text("Playlists (\(dataService.playlists.count))").tag(1)
                        Text("Artists").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    
                    // Segment Content
                    if selectedTab == 0 {
                        favoritesSection
                    } else if selectedTab == 1 {
                        playlistsSection
                    } else {
                        artistsSection
                    }
                    
                    // Bottom Spacer for mini player
                    Spacer().frame(height: 80)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreatePlaylistSheet) {
                createPlaylistModal
            }
        }
    }
    
    // MARK: - Favorites Section
    private var favoritesSection: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Hero Liked Banner
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppTheme.sunsetGradient)
                        .frame(height: 120)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Liked Bollywood Songs")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.white)
                            
                            Text("\(favoriteSongs.count) songs saved")
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Play All Button
                        if let first = favoriteSongs.first {
                            Button(action: {
                                playerManager.play(song: first, in: favoriteSongs)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 46, height: 46)
                                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(hex: "#F43F5E"))
                                        .offset(x: 1)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                // Song Items
                if favoriteSongs.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 36))
                            .foregroundColor(Color.white.opacity(0.3))
                        Text("No liked songs yet.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(favoriteSongs) { song in
                            Button(action: {
                                playerManager.play(song: song, in: favoriteSongs)
                            }) {
                                HStack(spacing: 12) {
                                    RemoteImageView(
                                        url: song.artworkURL,
                                        placeholderGradient: LinearGradient(
                                            gradient: Gradient(colors: song.gradientColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        cornerRadius: 10
                                    )
                                    .frame(width: 48, height: 48)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(song.title)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(playerManager.currentSong?.id == song.id ? AppTheme.cyanAccent : Color.white)
                                            .lineLimit(1)
                                        
                                        Text(song.artist)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.white.opacity(0.6))
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        dataService.toggleFavorite(song: song)
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(AppTheme.secondaryAccent)
                                            .font(.system(size: 18))
                                    }
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
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Playlists Section
    private var playlistsSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dataService.playlists) { playlist in
                    Button(action: {
                        let songs = dataService.songs(for: playlist)
                        if let first = songs.first {
                            playerManager.play(song: first, in: songs)
                        }
                    }) {
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: playlist.coverColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(Color.white.opacity(0.9))
                                        .font(.system(size: 20))
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(playlist.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .lineLimit(1)
                                
                                Text("\(playlist.songIds.count) songs • \(playlist.isCustom ? "Custom" : "Curated")")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.primaryAccent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Artists Section
    private var artistsSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dataService.artists) { artist in
                    Button(action: {
                        let artistSongs = dataService.allSongs.filter { artist.topSongIds.contains($0.id) }
                        if let first = artistSongs.first {
                            playerManager.play(song: first, in: artistSongs)
                        }
                    }) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: artist.gradientColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 54, height: 54)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 22))
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(artist.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.white)
                                
                                Text(artist.monthlyListeners)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Create Playlist Modal Sheet
    private var createPlaylistModal: some View {
        ZStack {
            AppTheme.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("New Playlist")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showCreatePlaylistSheet = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                
                // Color Themes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cover Theme Color")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColorHex = hex
                                    HapticManager.shared.selection()
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Title Field
                TextField("Playlist Name (e.g. My Bollywood Favorites)", text: $newPlaylistName)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .foregroundColor(Color.white)
                
                // Description Field
                TextField("Description (optional)", text: $newPlaylistDesc)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                // Create Button
                Button(action: {
                    guard !newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    dataService.createPlaylist(
                        name: newPlaylistName,
                        description: newPlaylistDesc,
                        gradientHexes: [selectedColorHex, "#3B82F6"]
                    )
                    newPlaylistName = ""
                    newPlaylistDesc = ""
                    showCreatePlaylistSheet = false
                    selectedTab = 1
                    HapticManager.shared.notification(.success)
                }) {
                    Text("Create Playlist")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(16)
                }
            }
            .padding(24)
        }
    }
}
