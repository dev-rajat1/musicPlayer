//
//  MusicModels.swift
//  musicPlayer
//

import Foundation
import SwiftUI

// MARK: - Repeat Mode
enum RepeatMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case all = "Repeat All"
    case one = "Repeat One"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }
}

// MARK: - Lyric Line Model
struct LyricLine: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    let time: TimeInterval
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case time, text
    }
}

// MARK: - Song Model
struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let audioURLString: String
    let artworkURLString: String?
    let genre: String
    var isFavorite: Bool
    var lyrics: [LyricLine]
    var year: String?
    var plays: Int
    
    // UI Color themes for background glow & vinyl center
    var gradientHexes: [String] = ["#6366F1", "#EC4899"]
    
    var audioURL: URL? {
        URL(string: audioURLString)
    }
    
    var artworkURL: URL? {
        guard let artworkURLString = artworkURLString, !artworkURLString.isEmpty else { return nil }
        return URL(string: artworkURLString)
    }
    
    var gradientColors: [Color] {
        gradientHexes.compactMap { Color(hex: $0) }
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Playlist Model
struct Playlist: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var coverGradientHexes: [String] = ["#8B5CF6", "#3B82F6"]
    var songIds: [String]
    var isCustom: Bool = false
    var createdAt: Date = Date()
    
    var coverColors: [Color] {
        coverGradientHexes.compactMap { Color(hex: $0) }
    }
}

// MARK: - Artist Model
struct Artist: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let name: String
    let monthlyListeners: String
    let imageName: String
    let topSongIds: [String]
    let gradientColors: [Color]
}

// MARK: - Equalizer Preset Model
struct EqualizerPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let bandGains: [Float] // 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz in dB (-12 to +12)
    
    static let presets: [EqualizerPreset] = [
        EqualizerPreset(name: "Flat", icon: "slider.horizontal.3", bandGains: [0, 0, 0, 0, 0]),
        EqualizerPreset(name: "Bass Booster", icon: "waveform.path.ecg", bandGains: [8, 6, 2, -1, -3]),
        EqualizerPreset(name: "Bollywood Pop", icon: "music.note", bandGains: [4, 2, 0, 3, 5]),
        EqualizerPreset(name: "Vocal / Sufi", icon: "mic.fill", bandGains: [-2, 1, 4, 3, 1]),
        EqualizerPreset(name: "Acoustic", icon: "guitars.fill", bandGains: [3, 2, 1, 3, 4]),
        EqualizerPreset(name: "EDM / Dance", icon: "bolt.fill", bandGains: [7, 5, -1, 4, 6]),
        EqualizerPreset(name: "Rock", icon: "flame.fill", bandGains: [5, 3, -2, 4, 5]),
        EqualizerPreset(name: "Lo-Fi Chill", icon: "moon.stars.fill", bandGains: [4, 1, -2, -1, -4])
    ]
}

// MARK: - JioSaavn / Online API Response Decodables
struct JioSaavnSearchResponse: Codable {
    let status: String?
    let message: String?
    let data: JioSaavnSearchData?
}

struct JioSaavnSearchData: Codable {
    let total: Int?
    let start: Int?
    let results: [JioSaavnSongItem]?
}

struct JioSaavnSongItem: Codable {
    let id: String
    let name: String?
    let title: String?
    let type: String?
    let year: String?
    let duration: String?
    let label: String?
    let primaryArtists: String?
    let artists: [JioSaavnArtistItem]?
    let featuredArtists: String?
    let language: String?
    let hasLyrics: String?
    let url: String?
    let copyright: String?
    let image: [JioSaavnMediaLink]?
    let downloadUrl: [JioSaavnMediaLink]?
    let album: JioSaavnAlbumItem?
    
    var resolvedTitle: String {
        name ?? title ?? "Unknown Song"
    }
    
    var resolvedArtist: String {
        if let primaryArtists = primaryArtists, !primaryArtists.isEmpty {
            return primaryArtists
        }
        if let artists = artists, !artists.isEmpty {
            return artists.compactMap { $0.name }.joined(separator: ", ")
        }
        return "Various Artists"
    }
    
    var bestImageURL: String? {
        image?.last?.url ?? image?.first?.url
    }
    
    var bestDownloadURL: String? {
        downloadUrl?.last?.url ?? downloadUrl?.first?.url
    }
}

struct JioSaavnArtistItem: Codable {
    let id: String?
    let name: String?
    let role: String?
}

struct JioSaavnAlbumItem: Codable {
    let id: String?
    let name: String?
    let url: String?
}

struct JioSaavnMediaLink: Codable {
    let quality: String?
    let url: String?
    let link: String?
}
