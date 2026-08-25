<div align="center">

# 🎵 Beats - Modern Bollywood Music Player for iOS

An ultra-modern, aesthetic, and feature-packed iOS Music Streaming Application built natively with **SwiftUI** & **AVFoundation**. Packed with real-time audio visualizers, synchronized lyrics, 5-band manual equalizer, 360° vinyl mode, and on-the-fly DES decrypted full-length CD-quality Bollywood music streaming!

[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://apple.com/ios)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Author](https://img.shields.io/badge/Developer-@dev--rajat1-8A2BE2?style=for-the-badge&logo=github&logoColor=white)](https://github.com/dev-rajat1)

---

</div>

## ✨ Key Features

### 🎧 1. Full-Length Master Audio Streaming (3–5 Minutes)
- **Unlimited & Free Streaming**: No paywalls, subscriptions, or 30-second previews. Streams 100% complete, uncompressed master tracks (160kbps CD-Quality).
- **On-the-Fly DES Decryption Engine**: Direct native CommonCrypto DES-ECB decryption (`38346591`) of master streams.
- **Background Playback & Lock Screen Controls**: Complete integration with `MPNowPlayingInfoCenter`, `MPRemoteCommandCenter`, and `AVAudioSession` for continuous background audio and headphone controls.

### 🌟 2. Rich Glassmorphic & Cyber-Dark Aesthetics
- **Dynamic Ambient Glow**: Player background dynamically blurs and shifts colors matching the current track's album cover palette.
- **Glassmorphism UI**: Frosted glass cards, glowing borders, smooth spring micro-interactions, and custom haptic feedback (`UIImpactFeedbackGenerator`).
- **100% Responsive Design**: Custom adaptive layout that scales seamlessly on any iPhone (iPhone SE, Mini, 14/15/16 Pro, Pro Max) and iPad.

### 🎙️ 3. Real-Time Synced Karaoke Lyrics
- Live scrolling synchronized lyrics that automatically track playback progress with karaoke-style highlighting and interactive tap-to-seek.

### 🎚️ 4. Professional 5-Band Equalizer & Audio FX
- **5-Band Frequency Sliders**: Sub (60Hz), Bass (230Hz), Mid (910Hz), High (3.6kHz), Treble (14kHz) with -12dB to +12dB manual control.
- **8 Tailored Presets**: *Bass Booster*, *Bollywood Pop*, *Vocal / Sufi*, *Acoustic*, *EDM / Dance*, *Rock*, *Lo-Fi Chill*, and *Flat*.
- **Sound Stage Effects**: 3D Spatial Audio simulation and Dynamic Bass Boost toggle.
- **Sleep Timer**: Auto-shutoff timer (15m, 30m, 45m, 60m) with live countdown.

### 💿 5. 360° Rotating Vinyl Disc Mode
- Toggle between high-definition 500x500 album art posters and an authentic spinning 360° retro vinyl record with realistic groove light reflections.

### 🔍 6. Instant Live Search & Discovery
- Discover trending Bollywood hits, curated genre playlists (*Romance, Punjabi Pop, 90s Evergreen, Sufi, Lo-Fi, Party*), and popular artists (*Arijit Singh, Diljit Dosanjh, Pritam, Jubin Nautiyal, etc.*).
- Search any Hindi/Bollywood/Punjabi song, album, or artist on-demand.

---

## 📱 App Architecture & Tech Stack

```
musicPlayer/
├── App/
│   ├── musicPlayerApp.swift       # App Entry Point
│   ├── ContentView.swift          # Main TabView & Floating MiniPlayer
│   └── Info.plist                 # Background Audio & Network Capabilities
├── Models/
│   └── MusicModels.swift          # Song, Playlist, Artist, LyricLine & Decodables
├── Services/
│   ├── AudioPlayerManager.swift   # AVPlayer Engine, Lockscreen Controls & Sleep Timer
│   └── MusicDataService.swift     # Streaming API Client, Decryption & Catalog Store
├── Views/
│   ├── HomeView.swift             # Discover Feed, Hero Banner & Quick Picks
│   ├── SearchView.swift           # Live Search Engine & Mood Explorer
│   ├── LibraryView.swift          # Liked Songs, Custom Playlist Manager & Artists
│   ├── NowPlayingView.swift       # Full Screen Player, Scrubber, Vinyl & Utility Bar
│   ├── MiniPlayerView.swift       # Floating Bottom Player with Gesture Controls
│   ├── EqualizerView.swift        # 5-Band EQ, Audio FX & Live Visualizer Spectrum
│   ├── LyricsView.swift           # Synced Karaoke Lyrics ScrollView
│   └── QueueView.swift            # Up Next Queue with Reordering & Clear
└── Utilities/
    ├── Theme.swift                # Color Gradients, Glass Card Modifiers & Haptics
    └── CustomComponents.swift     # Visualizer Bars, Vinyl Disc, Sliders & Image Loader
```

---

## 🚀 Getting Started

### Prerequisites
- **macOS Ventura / Sonoma / Sequoia**
- **Xcode 15.0+**
- **iOS 15.0+** (Simulator or Physical Device)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dev-rajat1/musicPlayer.git
   cd musicPlayer
   ```

2. **Open in Xcode:**
   ```bash
   open musicPlayer.xcodeproj
   ```

3. **Run the Project:**
   - Select your target simulator (e.g., `iPhone 15 Pro` or `iPhone 16 Pro Max`) or connected iPhone.
   - Press **`Cmd + R`** to build and run the application!

---

## 👨‍💻 Author

Crafted with ❤️ by **Rajat** ([@dev-rajat1](https://github.com/dev-rajat1))

- **GitHub:** [@dev-rajat1](https://github.com/dev-rajat1)
- **Project Repository:** [musicPlayer](https://github.com/dev-rajat1/musicPlayer)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
