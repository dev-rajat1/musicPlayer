//
//  EqualizerView.swift
//  musicPlayer
//

import SwiftUI
import UIKit

struct EqualizerView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    
    @State private var bandGains: [Float] = [4, 2, 0, 3, 5]
    let bandLabels = ["60Hz\nSub", "230Hz\nBass", "910Hz\nMid", "3.6kHz\nHigh", "14kHz\nTreble"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AUDIO FX & EQUALIZER")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.primaryAccent)
                                
                                Text("Sound Master")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Live Visualizer Display Card
                        visualizerDisplayCard
                            .padding(.horizontal, 20)
                        
                        // Sound Presets Carousel
                        presetsSection
                        
                        // 5-Band Equalizer Sliders
                        equalizerSlidersSection
                            .padding(.horizontal, 20)
                        
                        // Audio FX Toggles (Bass Boost & Spatial Audio)
                        audioFxToggles
                            .padding(.horizontal, 20)
                        
                        // Sleep Timer Settings
                        sleepTimerSection
                            .padding(.horizontal, 20)
                        
                        // Bottom spacer for mini player
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Visualizer Display Card
    private var visualizerDisplayCard: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(playerManager.isPlaying ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(playerManager.isPlaying ? "LIVE AUDIO SPECTRUM" : "AUDIO PAUSED")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text(playerManager.currentPreset.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.cyanAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Audio visualizer bars
            AudioVisualizerView(
                isPlaying: playerManager.isPlaying,
                barCount: 28,
                accentColors: [AppTheme.primaryAccent, AppTheme.cyanAccent]
            )
            .frame(height: 50)
            .padding(.vertical, 8)
        }
        .padding(16)
        .glassCard(cornerRadius: 18)
    }
    
    // MARK: - Presets Section
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Presets")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(EqualizerPreset.presets) { preset in
                        let isSelected = playerManager.currentPreset.name == preset.name
                        
                        Button(action: {
                            playerManager.currentPreset = preset
                            bandGains = preset.bandGains
                            HapticManager.shared.selection()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: preset.icon)
                                    .font(.system(size: 13))
                                Text(preset.name)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isSelected ? AppTheme.primaryAccent : Color.white.opacity(0.06))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - 5-Band Equalizer Sliders
    private var equalizerSlidersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Manual 5-Band Frequency (dB)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Reset") {
                    bandGains = [0, 0, 0, 0, 0]
                    HapticManager.shared.impact(.light)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.secondaryAccent)
            }
            
            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    VStack(spacing: 10) {
                        Text("\(Int(bandGains[index]))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(bandGains[index] > 0 ? AppTheme.cyanAccent : (bandGains[index] < 0 ? AppTheme.secondaryAccent : .white.opacity(0.6)))
                        
                        // Custom Vertical Slider
                        GeometryReader { geo in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 6, height: max(0, min(geo.size.height, CGFloat((bandGains[index] + 12) / 24) * geo.size.height)))
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let normalized = 1 - Float(value.location.y / geo.size.height)
                                        let clamped = max(0, min(1, normalized))
                                        let gain = (clamped * 24) - 12
                                        bandGains[index] = gain
                                    }
                            )
                        }
                        .frame(height: 120)
                        
                        Text(bandLabels[index])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .padding(18)
        .glassCard(cornerRadius: 18)
    }
    
    // MARK: - Audio FX Toggles
    private var audioFxToggles: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $playerManager.isBassBoostEnabled) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 36, height: 36)
                        Image(systemName: "waveform.path.badge.plus")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dynamic Bass Boost")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Enhances low frequencies & deep beats")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryAccent))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 16)
            
            Toggle(isOn: $playerManager.isSpatialAudioEnabled) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.neonCyanGradient)
                            .frame(width: 36, height: 36)
                        Image(systemName: "headphones")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("3D Spatial Sound Stage")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Immersive 360° concert hall simulation")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.cyanAccent))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 16)
        }
    }
    
    // MARK: - Sleep Timer Section
    private var sleepTimerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sleep Timer")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let remaining = playerManager.sleepTimerMinutesRemaining {
                    Text("Stops in \(remaining)m")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.amberAccent)
                }
            }
            
            HStack(spacing: 8) {
                ForEach([nil, 15, 30, 45, 60], id: \.self) { minutes in
                    let isSelected = playerManager.sleepTimerMinutesRemaining == minutes
                    
                    Button(action: {
                        playerManager.setSleepTimer(minutes: minutes)
                        HapticManager.shared.selection()
                    }) {
                        Text(minutes == nil ? "Off" : "\(minutes!)m")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isSelected ? AppTheme.amberAccent : Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }
}
