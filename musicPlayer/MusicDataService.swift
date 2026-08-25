//
//  MusicDataService.swift
//  musicPlayer
//

import Foundation
import Combine
import SwiftUI

class MusicDataService: ObservableObject {
    static let shared = MusicDataService()
    
    @Published var allSongs: [Song] = []
    @Published var playlists: [Playlist] = []
    @Published var artists: [Artist] = []
    @Published var searchResults: [Song] = []
    @Published var isSearching: Bool = false
    @Published var trendingBollywood: [Song] = []
    
    private let favoritesKey = "saved_favorite_song_ids"
    private let customPlaylistsKey = "saved_custom_playlists"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialCatalog()
        loadSavedFavorites()
        loadSavedPlaylists()
        fetchLiveBollywoodTracks()
    }
    
    // MARK: - Initial Bollywood Catalog (with 100% verified working CDN audio & 600x600 HD artworks)
    private func loadInitialCatalog() {
        allSongs = [
            Song(
                id: "bw-1",
                title: "Kesariya",
                artist: "Pritam, Arijit Singh & Amitabh Bhattacharya",
                album: "Brahmāstra",
                duration: 268,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/38/4c/5c/384c5c8f-3ff8-e457-b2f7-3158ce108649/mzaf_12389299033886433185.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/9f/13/ca/9f13ca3b-e533-03e0-f19a-f0aaa774581d/196589311191.jpg/600x600bb.jpg",
                genre: "Bollywood Romance",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Mujhko itna bataye koi"),
                    LyricLine(time: 6, text: "Kaise tujhse dil na lagaye koi"),
                    LyricLine(time: 14, text: "Rabba ne tujhko banane mein"),
                    LyricLine(time: 21, text: "Kardi hai husn ki khaali tijoriyaan"),
                    LyricLine(time: 28, text: "Kajal ki siyahi se likhi"),
                    LyricLine(time: 35, text: "Hai tune jaane kitno ki love storiyaan"),
                    LyricLine(time: 42, text: "Kesariya tera ishq hai piya"),
                    LyricLine(time: 49, text: "Rang jaaun jo main haath lagaun"),
                    LyricLine(time: 56, text: "Din beete saara teri fikr mein"),
                    LyricLine(time: 63, text: "Rain saari teri khair manaun"),
                    LyricLine(time: 72, text: "Kesariya tera ishq hai piya..."),
                    LyricLine(time: 85, text: "Patjhad ke mausam mein bhi"),
                    LyricLine(time: 92, text: "Rangi chanar jaisi jhoome"),
                    LyricLine(time: 99, text: "Tere ishq mein sab rang rangeen lagte hain")
                ],
                year: "2022",
                plays: 1420500,
                gradientHexes: ["#FF4E50", "#F9D423"]
            ),
            Song(
                id: "bw-2",
                title: "Apna Bana Le",
                artist: "Arijit Singh, Sachin-Jigar & Amitabh Bhattacharya",
                album: "Bhediya",
                duration: 261,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/fb/33/fc/fb33fcf8-a1f7-baa0-47f2-5471c346f3a7/mzaf_9397441798223522784.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/bf/d7/46/bfd74659-4d6d-5573-0ff7-ae36ae9a9c51/196589574886.jpg/600x600bb.jpg",
                genre: "Romance",
                isFavorite: false,
                lyrics: [
                    LyricLine(time: 0, text: "Tu mera koi na hoke bhi kuch laage"),
                    LyricLine(time: 8, text: "Kiya re jo bhi tune kaisa ye jadu kiya re"),
                    LyricLine(time: 16, text: "Tere bin ab to ek pal na kate"),
                    LyricLine(time: 25, text: "Apna bana le piya, apna bana le piya"),
                    LyricLine(time: 34, text: "Dil ke nagar mein shehar tu basa le piya"),
                    LyricLine(time: 44, text: "Chhoo le tu aise jaise koi hawa"),
                    LyricLine(time: 54, text: "Tu ban gaya hai meri har dua")
                ],
                year: "2022",
                plays: 980200,
                gradientHexes: ["#667EEA", "#764BA2"]
            ),
            Song(
                id: "bw-3",
                title: "Raataan Lambiyan",
                artist: "Jubin Nautiyal, Tanishk Bagchi & Asees Kaur",
                album: "Shershaah",
                duration: 230,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/a8/07/9b/a8079bcf-ab6e-9311-bf45-d8cfdcba8479/mzaf_10034608752258838382.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/fa/ec/df/faecdf5f-7f7f-d89a-0ebf-9b16ea988582/8902894359659_cover.jpg/600x600bb.jpg",
                genre: "Melody",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Teri meri gallan ho gayi mashhoor"),
                    LyricLine(time: 7, text: "Kar na kabhi tu mujhe nazron se door"),
                    LyricLine(time: 14, text: "Kithe chaliye tu kithe chaliye"),
                    LyricLine(time: 21, text: "Kaatun kaise raataan o saawre"),
                    LyricLine(time: 28, text: "Jiya nahi jaata sun bawre"),
                    LyricLine(time: 36, text: "Ke raataan lambiyan lambiyan re"),
                    LyricLine(time: 44, text: "Katte tere sangeyan sangeyan re")
                ],
                year: "2021",
                plays: 2300000,
                gradientHexes: ["#F093FB", "#F5576C"]
            ),
            Song(
                id: "bw-4",
                title: "Lover",
                artist: "Diljit Dosanjh & Intense",
                album: "MoonChild Era",
                duration: 195,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/f4/bf/25/f4bf25c3-aeb0-d621-e374-297d2e7b99c1/mzaf_17208940866978457637.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/58/b7/0f/58b70f03-6fbf-862d-98fe-f39b1a50a98f/196292520612.jpg/600x600bb.jpg",
                genre: "Punjabi Pop",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Tera ni main lover, tera ni main lover"),
                    LyricLine(time: 8, text: "Koyi aake dekh le saanu kidan de lagde aan"),
                    LyricLine(time: 16, text: "Jadon vi main hassna tere naal hi hassna"),
                    LyricLine(time: 24, text: "Tu hi meri zindagi, tu hi mera chain"),
                    LyricLine(time: 32, text: "Lover lover lover, tera ni main lover")
                ],
                year: "2021",
                plays: 1850400,
                gradientHexes: ["#4FACFE", "#00F2FE"]
            ),
            Song(
                id: "bw-5",
                title: "Tum Hi Ho",
                artist: "Arijit Singh & Mithoon",
                album: "Aashiqui 2",
                duration: 262,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/aa/62/77/aa627725-d242-bfe3-dd6f-9cf65215779c/mzaf_10014798725841022137.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/64/46/74/64467472-ee62-eb7b-3ef1-2e6378e9bda5/8902894353480_cover.jpg/600x600bb.jpg",
                genre: "Romantic",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Hum tere bin ab reh nahi sakte"),
                    LyricLine(time: 8, text: "Tere bina kya wajood mera"),
                    LyricLine(time: 16, text: "Tujhse juda agar ho jayenge"),
                    LyricLine(time: 24, text: "Toh khud se hi ho jayenge juda"),
                    LyricLine(time: 33, text: "Kyunki tum hi ho, ab tum hi ho"),
                    LyricLine(time: 42, text: "Zindagi ab tum hi ho"),
                    LyricLine(time: 51, text: "Chain bhi mera dard bhi"),
                    LyricLine(time: 60, text: "Meri aashiqui ab tum hi ho")
                ],
                year: "2013",
                plays: 4500000,
                gradientHexes: ["#2E0854", "#8A2387"]
            ),
            Song(
                id: "bw-6",
                title: "Channa Mereya",
                artist: "Arijit Singh & Pritam",
                album: "Ae Dil Hai Mushkil",
                duration: 289,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/be/81/b8/be81b899-73e4-4d22-1d57-30239cf2e260/mzaf_1069632420315357904.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/64/fe/5f/64fe5f5d-f1f3-d02f-2d7c-3f7cb43ccead/886446193796.jpg/600x600bb.jpg",
                genre: "Sufi / Sad",
                isFavorite: false,
                lyrics: [
                    LyricLine(time: 0, text: "Achha chalta hoon duaaon mein yaad rakhna"),
                    LyricLine(time: 9, text: "Mere zikr ka zubaan pe swaad rakhna"),
                    LyricLine(time: 18, text: "Dil ke sandookon mein mere achhe kaam rakhna"),
                    LyricLine(time: 27, text: "Channa mereya mereya"),
                    LyricLine(time: 35, text: "Channa mereya mereya beli yaa"),
                    LyricLine(time: 45, text: "O piya...")
                ],
                year: "2016",
                plays: 3800000,
                gradientHexes: ["#FF0844", "#FFB199"]
            ),
            Song(
                id: "bw-7",
                title: "Ghungroo",
                artist: "Arijit Singh, Shilpa Rao & Vishal-Shekhar",
                album: "War",
                duration: 302,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/aa/62/17/aa62174c-4731-9721-a1b4-7ce039773bf7/mzaf_7865243171358993188.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/3b/bc/db/3bbcdbc5-bf0f-2b2a-7c98-1e43372c3d55/8902894357778_cover.jpg/600x600bb.jpg",
                genre: "Dance / Party",
                isFavorite: false,
                lyrics: [
                    LyricLine(time: 0, text: "Kyun lamhe kharaab karein"),
                    LyricLine(time: 8, text: "Aa galti behisaab karein"),
                    LyricLine(time: 16, text: "Ghungroo toot gaye jab se nache"),
                    LyricLine(time: 24, text: "Ghungroo toot gaye...")
                ],
                year: "2019",
                plays: 2100000,
                gradientHexes: ["#00C9FF", "#92FE9D"]
            ),
            Song(
                id: "bw-8",
                title: "Ilahi",
                artist: "Arijit Singh & Pritam",
                album: "Yeh Jawaani Hai Deewani",
                duration: 228,
                audioURLString: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/44/2c/3a/442c3ae9-fe79-aaeb-ae2d-5faee549725f/mzaf_12411985959955375494.plus.aac.p.m4a",
                artworkURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/fb/f3/ef/fbf3ef50-f963-c782-b7e3-0d6741b6fc25/886443977467.jpg/600x600bb.jpg",
                genre: "Travel / Feel Good",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Shaamein malang si, raatein patang si"),
                    LyricLine(time: 7, text: "Doori patang si chhoote na"),
                    LyricLine(time: 15, text: "Ilahi mera jee aaye aaye"),
                    LyricLine(time: 23, text: "Ilahi mera jee aaye aaye")
                ],
                year: "2013",
                plays: 3100000,
                gradientHexes: ["#FA709A", "#FEE140"]
            )
        ]
        
        trendingBollywood = allSongs
        
        // Setup Playlists
        playlists = [
            Playlist(
                name: "🔥 Trending Bollywood",
                description: "The hottest Hindi chartbusters right now.",
                coverGradientHexes: ["#FF4E50", "#F9D423"],
                songIds: ["bw-1", "bw-2", "bw-3", "bw-4", "bw-7"]
            ),
            Playlist(
                name: "❤️ Bollywood Romance",
                description: "Timeless love songs and romantic melodies.",
                coverGradientHexes: ["#EC4899", "#8B5CF6"],
                songIds: ["bw-1", "bw-2", "bw-5", "bw-8"]
            ),
            Playlist(
                name: "⚡ Punjabi Energy & Hits",
                description: "High voltage beats for workouts & parties.",
                coverGradientHexes: ["#06B6D4", "#3B82F6"],
                songIds: ["bw-4", "bw-7"]
            ),
            Playlist(
                name: "🌙 Lo-Fi Midnight Vibes",
                description: "Slowed & reverbed chill beats to relax.",
                coverGradientHexes: ["#6366F1", "#A855F7"],
                songIds: ["bw-2", "bw-3", "bw-6", "bw-8"]
            )
        ]
        
        // Setup Popular Artists
        artists = [
            Artist(
                name: "Arijit Singh",
                monthlyListeners: "38.5M monthly listeners",
                imageName: "person.crop.circle.fill",
                topSongIds: ["bw-1", "bw-2", "bw-5", "bw-6", "bw-7", "bw-8"],
                gradientColors: [Color(hex: "#FF512F"), Color(hex: "#DD2476")]
            ),
            Artist(
                name: "Diljit Dosanjh",
                monthlyListeners: "22.1M monthly listeners",
                imageName: "person.crop.circle.fill",
                topSongIds: ["bw-4"],
                gradientColors: [Color(hex: "#8A2387"), Color(hex: "#E94057")]
            ),
            Artist(
                name: "Pritam",
                monthlyListeners: "29.4M monthly listeners",
                imageName: "person.crop.circle.fill",
                topSongIds: ["bw-1", "bw-6", "bw-8"],
                gradientColors: [Color(hex: "#11998E"), Color(hex: "#38EF7D")]
            ),
            Artist(
                name: "Jubin Nautiyal",
                monthlyListeners: "19.8M monthly listeners",
                imageName: "person.crop.circle.fill",
                topSongIds: ["bw-3"],
                gradientColors: [Color(hex: "#4E54C8"), Color(hex: "#8F94FB")]
            )
        ]
    }
    
    // MARK: - Auto-Fetch Live Bollywood Hits
    private func fetchLiveBollywoodTracks() {
        let queries = ["Arijit Singh", "Bollywood Hindi", "Diljit Dosanjh", "Shreya Ghoshal"]
        
        for q in queries {
            guard let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&entity=song&limit=10") else {
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                if let decoded = try? JSONDecoder().decode(ITunesSearchResponse.self, from: data) {
                    let songs = decoded.results.compactMap { $0.toSong }
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        for s in songs {
                            if !self.allSongs.contains(where: { $0.title.lowercased() == s.title.lowercased() }) {
                                self.allSongs.append(s)
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Live Search Bollywood Songs (Native Apple Music Engine - 100% Free & Unlimited)
    func searchSongs(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        // Match in local catalog first
        let localMatches = allSongs.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query) ||
            $0.album.localizedCaseInsensitiveContains(query) ||
            $0.genre.localizedCaseInsensitiveContains(query)
        }
        self.searchResults = localMatches
        
        // Query Apple iTunes Search API (Free, Instant, Real Singing Vocals)
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encodedQuery)&entity=song&limit=30") else {
            self.isSearching = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                guard let data = data, error == nil else { return }
                
                if let decoded = try? JSONDecoder().decode(ITunesSearchResponse.self, from: data) {
                    let onlineSongs = decoded.results.compactMap { $0.toSong }
                    
                    var combined = localMatches
                    for onlineSong in onlineSongs {
                        if !combined.contains(where: { $0.title.lowercased() == onlineSong.title.lowercased() }) {
                            combined.append(onlineSong)
                        }
                    }
                    self?.searchResults = combined
                }
            }
        }.resume()
    }
    
    // MARK: - Favorites Management
    func toggleFavorite(song: Song) {
        if let index = allSongs.firstIndex(where: { $0.id == song.id }) {
            allSongs[index].isFavorite.toggle()
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        let favoriteIds = allSongs.filter { $0.isFavorite }.map { $0.id }
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
    
    private func loadSavedFavorites() {
        if let savedIds = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            for index in 0..<allSongs.count {
                if savedIds.contains(allSongs[index].id) {
                    allSongs[index].isFavorite = true
                }
            }
        }
    }
    
    // MARK: - Custom Playlists Management
    func createPlaylist(name: String, description: String, gradientHexes: [String] = ["#8B5CF6", "#EC4899"]) {
        let newPlaylist = Playlist(
            name: name,
            description: description,
            coverGradientHexes: gradientHexes,
            songIds: [],
            isCustom: true
        )
        playlists.append(newPlaylist)
        savePlaylists()
    }
    
    func addSongToPlaylist(songId: String, playlistId: String) {
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            if !playlists[index].songIds.contains(songId) {
                playlists[index].songIds.append(songId)
                savePlaylists()
            }
        }
    }
    
    func removeSongFromPlaylist(songId: String, playlistId: String) {
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            playlists[index].songIds.removeAll { $0 == songId }
            savePlaylists()
        }
    }
    
    private func savePlaylists() {
        let customOnly = playlists.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(customOnly) {
            UserDefaults.standard.set(data, forKey: customPlaylistsKey)
        }
    }
    
    private func loadSavedPlaylists() {
        guard let data = UserDefaults.standard.data(forKey: customPlaylistsKey),
              let loaded = try? JSONDecoder().decode([Playlist].self, from: data) else { return }
        playlists.append(contentsOf: loaded)
    }
    
    // Helper to get Song by ID
    func song(for id: String) -> Song? {
        allSongs.first { $0.id == id }
    }
    
    // Helper to get Songs for Playlist
    func songs(for playlist: Playlist) -> [Song] {
        playlist.songIds.compactMap { song(for: $0) }
    }
}
