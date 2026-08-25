//
//  NowPlayingView.swift
//  musicPlayer
//

import SwiftUI

struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @ObservedObject var dataService = MusicDataService.shared
    
    @State private var showSpeedMenu: Bool = false
    @State private var showSleepTimerMenu: Bool = false
    
    var body: some View {
        if let song = playerManager.currentSong {
            ZStack {
                // MARK: - Dynamic Ambient Blurred Background
                ZStack {
                    AppTheme.backgroundDark.ignoresSafeArea()
                    
                    // Ambient Gradient Orbs
                    RadialGradient(
                        gradient: Gradient(colors: [
                            song.gradientColors.first?.opacity(0.55) ?? AppTheme.primaryAccent.opacity(0.5),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 380
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        gradient: Gradient(colors: [
                            song.gradientColors.last?.opacity(0.45) ?? AppTheme.secondaryAccent.opacity(0.4),
                            Color.clear
                        ]),
                        center: .bottomTrailing,
                        startRadius: 80,
                        endRadius: 420
                    )
                    .ignoresSafeArea()
                    
                    // Subtle Noise / Blur overlay
                    Color.black.opacity(0.25).ignoresSafeArea()
                }
                
                // MARK: - Main Content
                VStack(spacing: 0) {
                    // Top Bar
                    topBar(song: song)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                    
                    Spacer(minLength: 12)
                    
                    // Album Artwork / Vinyl Record Disc Center
                    ZStack {
                        if playerManager.isVinylMode {
                            VinylRecordView(
                                song: song,
                                isPlaying: playerManager.isPlaying,
                                size: min(UIScreen.main.bounds.width - 64, 300)
                            )
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            VStack {
                                RemoteImageView(
                                    url: song.artworkURL,
                                    placeholderGradient: LinearGradient(
                                        gradient: Gradient(colors: song.gradientColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    cornerRadius: 24
                                )
                                .frame(
                                    width: min(UIScreen.main.bounds.width - 64, 310),
                                    height: min(UIScreen.main.bounds.width - 64, 310)
                                )
                                .shadow(
                                    color: song.gradientColors.first?.opacity(0.5) ?? Color.black.opacity(0.4),
                                    radius: playerManager.isPlaying ? 28 : 14,
                                    x: 0,
                                    y: 12
                                )
                                .scaleEffect(playerManager.isPlaying ? 1.0 : 0.94)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: playerManager.isPlaying)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 320)
                    
                    Spacer(minLength: 16)
                    
                    // Track Title & Favorite Button
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(song.artist)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                                .lineLimit(1)
                            
                            if let year = song.year {
                                Text("\(song.album) • \(year)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.45))
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Animated Live Visualizer
                        AudioVisualizerView(
                            isPlaying: playerManager.isPlaying,
                            barCount: 10,
                            accentColors: song.gradientColors
                        )
                        .padding(.trailing, 8)
                        
                        // Like Button
                        Button(action: {
                            dataService.toggleFavorite(song: song)
                            HapticManager.shared.impact(.medium)
                        }) {
                            Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(song.isFavorite ? AppTheme.secondaryAccent : .white.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Scrubber Slider
                    CustomScrubberSlider(
                        progress: $playerManager.playbackProgress,
                        currentTimeText: playerManager.currentTimeString,
                        durationText: playerManager.remainingTimeString,
                        accentGradient: LinearGradient(
                            gradient: Gradient(colors: song.gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        onScrubEnd: { newProgress in
                            playerManager.seek(to: newProgress)
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
                    
                    // MARK: - Main Playback Controls
                    HStack(spacing: 20) {
                        // Shuffle Toggle
                        Button(action: {
                            playerManager.toggleShuffle()
                        }) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(playerManager.isShuffled ? AppTheme.cyanAccent : .white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Skip -15s
                        Button(action: {
                            playerManager.skipBackward(seconds: 15)
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        // Previous Track
                        Button(action: {
                            playerManager.previous()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Play / Pause Large Glow Button
                        Button(action: {
                            playerManager.togglePlayPause()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: song.gradientColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .shadow(color: song.gradientColors.first?.opacity(0.6) ?? AppTheme.primaryAccent.opacity(0.6), radius: 18, x: 0, y: 8)
                                
                                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: playerManager.isPlaying ? 0 : 2)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Next Track
                        Button(action: {
                            playerManager.next()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Skip +15s
                        Button(action: {
                            playerManager.skipForward(seconds: 15)
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        Spacer()
                        
                        // Repeat Toggle
                        Button(action: {
                            playerManager.toggleRepeat()
                        }) {
                            Image(systemName: playerManager.repeatMode.iconName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(playerManager.repeatMode != .off ? AppTheme.cyanAccent : .white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 16)
                    
                    // MARK: - Bottom Utility Bar (Speed, Timer, Lyrics, Queue, Vinyl Toggle)
                    bottomUtilityBar(song: song)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $playerManager.showLyricsSheet) {
                LyricsView(song: song)
            }
            .sheet(isPresented: $playerManager.showQueueSheet) {
                QueueView()
            }
        }
    }
    
    // MARK: - Top Bar
    private func topBar(song: Song) -> some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                playerManager.showFullPlayer = false
                HapticManager.shared.impact(.light)
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("PLAYING FROM")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(song.genre.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Vinyl / Card Artwork View Mode Toggle
            Button(action: {
                withAnimation(.spring()) {
                    playerManager.isVinylMode.toggle()
                }
                HapticManager.shared.selection()
            }) {
                Image(systemName: playerManager.isVinylMode ? "square.fill" : "opticaldisc")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(playerManager.isVinylMode ? AppTheme.amberAccent : .white.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Bottom Utility Bar
    private func bottomUtilityBar(song: Song) -> some View {
        HStack(spacing: 16) {
            // Playback Speed Button / Menu
            Menu {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { speed in
                    Button(action: {
                        playerManager.setPlaybackSpeed(Float(speed))
                    }) {
                        HStack {
                            Text(String(format: "%.2fx", speed))
                            if playerManager.playbackSpeed == Float(speed) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(String(format: "%.2fx", playerManager.playbackSpeed))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Sleep Timer Menu
            Menu {
                Button("Off") { playerManager.setSleepTimer(minutes: nil) }
                Button("15 Minutes") { playerManager.setSleepTimer(minutes: 15) }
                Button("30 Minutes") { playerManager.setSleepTimer(minutes: 30) }
                Button("45 Minutes") { playerManager.setSleepTimer(minutes: 45) }
                Button("60 Minutes") { playerManager.setSleepTimer(minutes: 60) }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                    if let remaining = playerManager.sleepTimerMinutesRemaining {
                        Text("\(remaining)m")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .foregroundColor(playerManager.sleepTimerMinutesRemaining != nil ? AppTheme.amberAccent : .white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Synced Lyrics Sheet Toggle
            Button(action: {
                playerManager.showLyricsSheet = true
                HapticManager.shared.impact(.light)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 14))
                    Text("Lyrics")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
            }
            
            // Up Next Queue Sheet Toggle
            Button(action: {
                playerManager.showQueueSheet = true
                HapticManager.shared.impact(.light)
            }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
        }
    }
}
