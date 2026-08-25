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
    
    // MARK: - Initial Bollywood Catalog (100% FULL-LENGTH Complete 3-5min Songs)
    private func loadInitialCatalog() {
        allSongs = [
            Song(
                id: "bw-1",
                title: "Kesariya",
                artist: "Pritam, Arijit Singh & Amitabh Bhattacharya",
                album: "Brahmāstra",
                duration: 268,
                audioURLString: "https://aac.saavncdn.com/871/c2febd353f3a076a406fa37510f31f9f_160.mp4",
                artworkURLString: "https://c.saavncdn.com/871/Brahmastra-Original-Motion-Picture-Soundtrack-Hindi-2022-20221006155213-500x500.jpg",
                genre: "Romance",
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
                audioURLString: "https://aac.saavncdn.com/815/483a6e118e8108cbb3e5cd8701674f32_160.mp4",
                artworkURLString: "https://c.saavncdn.com/815/Bhediya-Hindi-2023-20230927155213-500x500.jpg",
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
                audioURLString: "https://aac.saavncdn.com/238/35726d4394604604e961bf5b846870d0_160.mp4",
                artworkURLString: "https://c.saavncdn.com/238/Shershaah-Original-Motion-Picture-Soundtrack--Hindi-2021-20210815181610-500x500.jpg",
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
                duration: 190,
                audioURLString: "https://aac.saavncdn.com/209/88cd9a1cc0af8768d67272876bb09851_160.mp4",
                artworkURLString: "https://c.saavncdn.com/209/MoonChild-Era-Punjabi-2021-20240715073449-500x500.jpg",
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
                audioURLString: "https://aac.saavncdn.com/430/5c5ea5cc00e3bff45616013226f376fe_160.mp4",
                artworkURLString: "https://c.saavncdn.com/430/Aashiqui-2-Hindi-2013-500x500.jpg",
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
                audioURLString: "https://aac.saavncdn.com/597/6da0627cfcc4b937160f664841e4572d_160.mp4",
                artworkURLString: "https://c.saavncdn.com/257/Ae-Dil-Hai-Mushkil-Hindi-2016-500x500.jpg",
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
                audioURLString: "https://aac.saavncdn.com/881/604fb2ba41aac81b5db565fcbf4fca9b_160.mp4",
                artworkURLString: "https://c.saavncdn.com/881/War-Hindi-2019-20191001104931-500x500.jpg",
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
                title: "Kabira / Ilahi",
                artist: "Arijit Singh, Rekha Bhardwaj & Pritam",
                album: "Yeh Jawaani Hai Deewani",
                duration: 224,
                audioURLString: "https://aac.saavncdn.com/440/664097ba2ddb94e9a8c9e9527b3010ec_160.mp4",
                artworkURLString: "https://c.saavncdn.com/440/Yeh-Jawaani-Hai-Deewani-2013-500x500.jpg",
                genre: "Travel / Feel Good",
                isFavorite: true,
                lyrics: [
                    LyricLine(time: 0, text: "Banno re banno meri chali sasuraal ko"),
                    LyricLine(time: 8, text: "Ankhiyon mein paani de gayi"),
                    LyricLine(time: 16, text: "Duaa mein meethi gudd dhaani de gayi"),
                    LyricLine(time: 25, text: "Re Kabira maan jaa, re Fakeera maan jaa")
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
    
    // MARK: - Auto-Fetch Live Full-Length Bollywood Tracks
    private func fetchLiveBollywoodTracks() {
        let queries = ["Arijit Singh hits", "Bollywood Hindi latest", "Diljit Dosanjh", "Shreya Ghoshal"]
        
        for q in queries {
            guard let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://www.jiosaavn.com/api.php?__call=search.getResults&_format=json&_marker=0&ctx=web6dot0&api_version=4&n=8&p=1&q=\(encoded)") else {
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                if let decoded = try? JSONDecoder().decode(DirectSaavnResponse.self, from: data),
                   let results = decoded.results, !results.isEmpty {
                    let songs: [Song] = results.compactMap { item in
                        guard let stream = item.streamURL, !stream.isEmpty else { return nil }
                        return Song(
                            id: "saavn-\(item.id)",
                            title: item.resolvedTitle,
                            artist: item.resolvedArtist,
                            album: item.albumName,
                            duration: item.durationSeconds,
                            audioURLString: stream,
                            artworkURLString: item.bestImageURL,
                            genre: "Bollywood",
                            isFavorite: false,
                            lyrics: [
                                LyricLine(time: 0, text: "♪ \(item.resolvedTitle) ♪"),
                                LyricLine(time: 15, text: "Artist: \(item.resolvedArtist)"),
                                LyricLine(time: 30, text: "Album: \(item.albumName)")
                            ],
                            year: item.year ?? "2023",
                            plays: Int.random(in: 500000...4500000),
                            gradientHexes: ["#FF4E50", "#6366F1"]
                        )
                    }
                    
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
    
    // MARK: - Live Search Full-Length Bollywood Songs (Decrypted 100% Complete Audio)
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
        
        // Query JioSaavn full-song endpoint
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.jiosaavn.com/api.php?__call=search.getResults&_format=json&_marker=0&ctx=web6dot0&api_version=4&n=25&p=1&q=\(encodedQuery)") else {
            self.isSearching = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                guard let data = data, error == nil else { return }
                
                if let decoded = try? JSONDecoder().decode(DirectSaavnResponse.self, from: data),
                   let results = decoded.results, !results.isEmpty {
                    let onlineSongs: [Song] = results.compactMap { item in
                        guard let stream = item.streamURL, !stream.isEmpty else { return nil }
                        return Song(
                            id: "saavn-\(item.id)",
                            title: item.resolvedTitle,
                            artist: item.resolvedArtist,
                            album: item.albumName,
                            duration: item.durationSeconds,
                            audioURLString: stream,
                            artworkURLString: item.bestImageURL,
                            genre: "Bollywood",
                            isFavorite: false,
                            lyrics: [
                                LyricLine(time: 0, text: "♪ \(item.resolvedTitle) ♪"),
                                LyricLine(time: 15, text: "Artist: \(item.resolvedArtist)"),
                                LyricLine(time: 30, text: "Album: \(item.albumName)")
                            ],
                            year: item.year,
                            plays: Int.random(in: 100000...3500000),
                            gradientHexes: ["#\(String(format: "%06X", arc4random_uniform(0xFFFFFF)))", "#6366F1"]
                        )
                    }
                    
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
