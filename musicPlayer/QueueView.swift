//
//  QueueView.swift
//  musicPlayer
//

import SwiftUI
import UIKit

struct QueueView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var playerManager = AudioPlayerManager.shared
    
    var body: some View {
        ZStack {
            AppTheme.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Up Next Queue")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.white)
                        
                        Text("\(playerManager.queue.count) tracks in queue")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Currently Playing Section
                        if let currentSong = playerManager.currentSong {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("NOW PLAYING")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.primaryAccent)
                                    .padding(.horizontal, 24)
                                
                                HStack(spacing: 12) {
                                    RemoteImageView(
                                        url: currentSong.artworkURL,
                                        placeholderGradient: LinearGradient(
                                            gradient: Gradient(colors: currentSong.gradientColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        cornerRadius: 10
                                    )
                                    .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(currentSong.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color.white)
                                            .lineLimit(1)
                                        
                                        Text(currentSong.artist)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    AudioVisualizerView(
                                        isPlaying: playerManager.isPlaying,
                                        barCount: 8,
                                        accentColors: currentSong.gradientColors
                                    )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .glassCard(cornerRadius: 16)
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Up Next Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("UPCOMING TRACKS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.5))
                                
                                Spacer()
                                
                                if playerManager.queue.count > 1 {
                                    Button(action: {
                                        if let current = playerManager.currentSong {
                                            playerManager.queue = [current]
                                            playerManager.currentIndex = 0
                                        }
                                    }) {
                                        Text("Clear Queue")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.secondaryAccent)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            
                            if playerManager.queue.count <= 1 {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "music.note.list")
                                            .font(.system(size: 32))
                                            .foregroundColor(Color.white.opacity(0.3))
                                        Text("No upcoming songs in queue.")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                    .padding(.vertical, 40)
                                    Spacer()
                                }
                            } else {
                                ForEach(Array(playerManager.queue.enumerated()), id: \.offset) { index, song in
                                    if index != playerManager.currentIndex {
                                        HStack(spacing: 12) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color.white.opacity(0.4))
                                                .frame(width: 24)
                                            
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
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(song.title)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(Color.white)
                                                    .lineLimit(1)
                                                
                                                Text(song.artist)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.white.opacity(0.6))
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                playerManager.removeFromQueue(at: index)
                                            }) {
                                                Image(systemName: "minus.circle")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(Color.white.opacity(0.5))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.04))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            playerManager.play(song: song, in: playerManager.queue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
