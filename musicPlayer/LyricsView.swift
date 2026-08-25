//
//  LyricsView.swift
//  musicPlayer
//

import SwiftUI

struct LyricsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var playerManager = AudioPlayerManager.shared
    let song: Song
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundDark.ignoresSafeArea()
            
            // Ambient subtle artwork glow
            RadialGradient(
                gradient: Gradient(colors: [
                    song.gradientColors.first?.opacity(0.4) ?? AppTheme.primaryAccent.opacity(0.3),
                    Color.clear
                ]),
                center: .top,
                startRadius: 40,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lyrics")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(song.title) • \(song.artist)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                // Real-time Synced Lyrics ScrollView
                if song.lyrics.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "music.mic")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.4))
                        Text("No synchronized lyrics available for this song.")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 24) {
                                ForEach(Array(song.lyrics.enumerated()), id: \.element.id) { index, line in
                                    let isActive = (index == playerManager.activeLyricIndex)
                                    
                                    Button(action: {
                                        playerManager.seek(toSeconds: line.time)
                                        HapticManager.shared.impact(.light)
                                    }) {
                                        Text(line.text)
                                            .font(.system(size: isActive ? 26 : 20, weight: isActive ? .bold : .medium))
                                            .foregroundColor(isActive ? .white : .white.opacity(0.35))
                                            .multilineTextAlignment(.leading)
                                            .blur(radius: isActive ? 0 : 0.4)
                                            .scaleEffect(isActive ? 1.05 : 1.0, anchor: .leading)
                                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isActive)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(index)
                                    .padding(.horizontal, 24)
                                }
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 120)
                        }
                        .onChange(of: playerManager.activeLyricIndex) { newIndex in
                            withAnimation(.easeInOut(duration: 0.4)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}
