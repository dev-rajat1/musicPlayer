//
//  MusicModels.swift
//  musicPlayer
//

import Foundation
import SwiftUI
import CommonCrypto

// MARK: - HTML Entity Decoder Extension
extension String {
    func decodingHTMLEntities() -> String {
        return self
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }
}

// MARK: - JioSaavn DES Cryptor for Direct Media Audio URLs
class SaavnCrypto {
    static func decryptMediaURL(encrypted: String) -> String? {
        guard let data = Data(base64Encoded: encrypted),
              let keyData = "38346591".data(using: .utf8) else { return nil }
        
        let keyLength = kCCKeySizeDES
        let dataLength = data.count
        let bufferLength = dataLength + kCCBlockSizeDES
        var result = Data(count: bufferLength)
        var numBytesDecrypted: Int = 0
        
        let status = result.withUnsafeMutableBytes { resultBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmDES),
                        CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, keyLength,
                        nil,
                        dataBytes.baseAddress, dataLength,
                        resultBytes.baseAddress, bufferLength,
                        &numBytesDecrypted
                    )
                }
            }
        }
        
        guard status == kCCSuccess else { return nil }
        result.removeSubrange(numBytesDecrypted..<bufferLength)
        
        if let decryptedString = String(data: result, encoding: .utf8) {
            return decryptedString
                .replacingOccurrences(of: "_96.mp4", with: "_160.mp4")
                .replacingOccurrences(of: "http://", with: "https://")
        }
        return nil
    }
}

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
    var audioURLString: String
    var artworkURLString: String?
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

// MARK: - Direct JioSaavn API Models
struct DirectSaavnResponse: Codable {
    let results: [DirectSaavnSong]?
}

struct DirectSaavnSong: Codable {
    let id: String
    let song: String?
    let title: String?
    let singers: String?
    let primary_artists: String?
    let image: String?
    let duration: String?
    let year: String?
    let media_preview_url: String?
    let encrypted_media_url: String?
    let album: String?
    let language: String?
    
    var resolvedTitle: String {
        let raw = (song ?? title ?? "Bollywood Song")
        return raw.decodingHTMLEntities()
    }
    
    var resolvedArtist: String {
        let raw = (singers ?? primary_artists ?? "Bollywood Artist")
        return raw.decodingHTMLEntities()
    }
    
    var bestImageURL: String? {
        guard let img = image else { return nil }
        return img.replacingOccurrences(of: "150x150", with: "500x500")
                  .replacingOccurrences(of: "http://", with: "https://")
    }
    
    var streamURL: String? {
        if let encrypted = encrypted_media_url, !encrypted.isEmpty,
           let decrypted = SaavnCrypto.decryptMediaURL(encrypted: encrypted), !decrypted.isEmpty {
            return decrypted
        }
        
        if let preview = media_preview_url, !preview.isEmpty {
            let full = preview.replacingOccurrences(of: "_preview.mp4", with: "_160.mp4")
                              .replacingOccurrences(of: "http://", with: "https://")
            return full
        }
        
        return nil
    }
}
