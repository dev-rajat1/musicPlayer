//
//  MiniPlayerView.swift
//  musicPlayer
//

import SwiftUI
import UIKit

struct MiniPlayerView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @ObservedObject var dataService = MusicDataService.shared
    
    var body: some View {
        if let song = playerManager.currentSong {
            VStack(spacing: 0) {
                // Mini Progress Bar on top of mini player
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 2.5)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: song.gradientColors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(playerManager.playbackProgress))), height: 2.5)
                    }
                }
                .frame(height: 2.5)
                
                HStack(spacing: 12) {
                    // Artwork with glow
                    RemoteImageView(
                        url: song.artworkURL,
                        placeholderGradient: LinearGradient(
                            gradient: Gradient(colors: song.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        cornerRadius: 8
                    )
                    .frame(width: 46, height: 46)
                    .shadow(color: song.gradientColors.first?.opacity(0.4) ?? Color.clear, radius: 6, x: 0, y: 3)
                    
                    // Song Info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(song.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                        
                        Text(song.artist)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Favorite Heart Button
                    Button(action: {
                        dataService.toggleFavorite(song: song)
                        HapticManager.shared.impact(.light)
                    }) {
                        Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(song.isFavorite ? AppTheme.secondaryAccent : Color.white.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 4)
                    
                    // Play / Pause Button
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
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.white)
                                .offset(x: playerManager.isPlaying ? 0 : 1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Next Button
                    Button(action: {
                        playerManager.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.white.opacity(0.85))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#151B28").opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
            .contentShape(Rectangle())
            .onTapGesture {
                playerManager.showFullPlayer = true
                HapticManager.shared.impact(.medium)
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            playerManager.next()
                        } else if value.translation.width > 50 {
                            playerManager.previous()
                        } else if value.translation.height < -40 {
                            playerManager.showFullPlayer = true
                        }
                    }
            )
            .transition(AnyTransition.move(edge: Edge.bottom).combined(with: AnyTransition.opacity))
        }
    }
}
