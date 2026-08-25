//
//  AudioPlayerManager.swift
//  musicPlayer
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import Combine
import SwiftUI

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    // Playback State
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    @Published var playbackProgress: Double = 0 // 0.0 to 1.0
    
    // Controls & Queue
    @Published var queue: [Song] = []
    @Published var currentIndex: Int = 0
    @Published var repeatMode: RepeatMode = .off
    @Published var isShuffled: Bool = false
    @Published var playbackSpeed: Float = 1.0
    @Published var activeLyricIndex: Int = 0
    
    // Equalizer & Sleep Timer
    @Published var currentPreset: EqualizerPreset = EqualizerPreset.presets[0]
    @Published var sleepTimerMinutesRemaining: Int? = nil
    @Published var isSpatialAudioEnabled: Bool = true
    @Published var isBassBoostEnabled: Bool = true
    
    // UI Sheets State
    @Published var showFullPlayer: Bool = false
    @Published var showLyricsSheet: Bool = false
    @Published var showQueueSheet: Bool = false
    @Published var isVinylMode: Bool = false
    
    private var avPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var originalQueue: [Song] = []
    private var sleepTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    deinit {
        removeTimeObserver()
        statusObserver?.invalidate()
    }
    
    // MARK: - Audio Session Setup for Background Audio
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Control Functions
    func play(song: Song, in queueList: [Song] = []) {
        self.currentSong = song
        
        if !queueList.isEmpty {
            self.originalQueue = queueList
            if isShuffled {
                var shuffled = queueList.filter { $0.id != song.id }
                shuffled.shuffle()
                self.queue = [song] + shuffled
                self.currentIndex = 0
            } else {
                self.queue = queueList
                if let index = queueList.firstIndex(where: { $0.id == song.id }) {
                    self.currentIndex = index
                } else {
                    self.currentIndex = 0
                }
            }
        } else if self.queue.isEmpty {
            self.queue = [song]
            self.currentIndex = 0
        }
        
        loadAndPlay(song: song)
    }
    
    private func loadAndPlay(song: Song) {
        removeTimeObserver()
        statusObserver?.invalidate()
        
        guard let url = song.audioURL else { return }
        
        let headers: [String: String] = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        ]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        
        if avPlayer == nil {
            avPlayer = AVPlayer(playerItem: playerItem)
        } else {
            avPlayer?.replaceCurrentItem(with: playerItem)
        }
        
        avPlayer?.automaticallyWaitsToMinimizeStalling = false
        avPlayer?.playImmediately(atRate: playbackSpeed)
        avPlayer?.play()
        
        isPlaying = true
        duration = song.duration > 0 ? song.duration : 240
        currentTime = 0
        playbackProgress = 0
        activeLyricIndex = 0
        
        // Observe item readiness to ensure playback starts instantly
        statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    self.avPlayer?.play()
                    self.avPlayer?.rate = self.playbackSpeed
                    self.isPlaying = true
                    let dur = CMTimeGetSeconds(item.duration)
                    if !dur.isNaN && dur > 0 {
                        self.duration = dur
                    }
                } else if item.status == .failed {
                    print("AVPlayerItem error: \(String(describing: item.error?.localizedDescription))")
                }
            }
        }
        
        addTimeObserver()
        updateNowPlayingInfo(song: song)
        
        // Listen for track finished
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            forName: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.trackDidFinish()
        }
    }
    
    func togglePlayPause() {
        guard let avPlayer = avPlayer else {
            if let firstSong = queue.first {
                play(song: firstSong, in: queue)
            }
            return
        }
        
        if isPlaying {
            avPlayer.pause()
            isPlaying = false
        } else {
            avPlayer.play()
            avPlayer.rate = playbackSpeed
            isPlaying = true
        }
        
        if let currentSong = currentSong {
            updateNowPlayingInfo(song: currentSong)
        }
        HapticManager.shared.impact(.medium)
    }
    
    func next() {
        guard !queue.isEmpty else { return }
        
        if currentIndex + 1 < queue.count {
            currentIndex += 1
            play(song: queue[currentIndex])
        } else if repeatMode == .all {
            currentIndex = 0
            play(song: queue[0])
        }
        HapticManager.shared.impact(.light)
    }
    
    func previous() {
        guard !queue.isEmpty else { return }
        
        // If current song has played more than 3 seconds, replay from start
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        
        if currentIndex > 0 {
            currentIndex -= 1
            play(song: queue[currentIndex])
        } else {
            seek(to: 0)
        }
        HapticManager.shared.impact(.light)
    }
    
    func seek(to progress: Double) {
        let clamped = max(0, min(1, progress))
        let targetSeconds = duration * clamped
        seek(toSeconds: targetSeconds)
    }
    
    func seek(toSeconds seconds: TimeInterval) {
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        avPlayer?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
        self.currentTime = seconds
        self.playbackProgress = duration > 0 ? (seconds / duration) : 0
        updateActiveLyric(for: seconds)
    }
    
    func skipForward(seconds: Double = 15) {
        let newTime = min(duration, currentTime + seconds)
        seek(toSeconds: newTime)
        HapticManager.shared.impact(.light)
    }
    
    func skipBackward(seconds: Double = 15) {
        let newTime = max(0, currentTime - seconds)
        seek(toSeconds: newTime)
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - Shuffle & Repeat
    func toggleShuffle() {
        isShuffled.toggle()
        guard let current = currentSong else { return }
        
        if isShuffled {
            var remaining = originalQueue.filter { $0.id != current.id }
            remaining.shuffle()
            queue = [current] + remaining
            currentIndex = 0
        } else {
            queue = originalQueue
            if let index = originalQueue.firstIndex(where: { $0.id == current.id }) {
                currentIndex = index
            }
        }
        HapticManager.shared.selection()
    }
    
    func toggleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
        HapticManager.shared.selection()
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        if isPlaying {
            avPlayer?.rate = speed
        }
        HapticManager.shared.selection()
    }
    
    // MARK: - Track Finish & Queue
    private func trackDidFinish() {
        if repeatMode == .one {
            seek(to: 0)
            avPlayer?.play()
            avPlayer?.rate = playbackSpeed
            isPlaying = true
        } else {
            next()
        }
    }
    
    func addToQueue(song: Song) {
        queue.append(song)
        originalQueue.append(song)
        HapticManager.shared.notification(.success)
    }
    
    func removeFromQueue(at index: Int) {
        guard index < queue.count else { return }
        let removedSong = queue.remove(at: index)
        originalQueue.removeAll { $0.id == removedSong.id }
        if index < currentIndex {
            currentIndex -= 1
        }
    }
    
    // MARK: - Periodic Time Observer
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserverToken = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            if !seconds.isNaN && !seconds.isInfinite {
                self.currentTime = seconds
                if let item = self.avPlayer?.currentItem {
                    let itemDuration = CMTimeGetSeconds(item.duration)
                    if !itemDuration.isNaN && itemDuration > 0 {
                        self.duration = itemDuration
                    }
                }
                self.playbackProgress = self.duration > 0 ? (self.currentTime / self.duration) : 0
                self.updateActiveLyric(for: seconds)
            }
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            avPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func updateActiveLyric(for time: TimeInterval) {
        guard let song = currentSong, !song.lyrics.isEmpty else { return }
        
        var activeIndex = 0
        for (index, line) in song.lyrics.enumerated() {
            if time >= line.time {
                activeIndex = index
            }
        }
        if activeIndex != self.activeLyricIndex {
            self.activeLyricIndex = activeIndex
        }
    }
    
    // MARK: - Sleep Timer
    func setSleepTimer(minutes: Int?) {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerMinutesRemaining = minutes
        
        guard let minutes = minutes, minutes > 0 else { return }
        
        var remainingSeconds = minutes * 60
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            remainingSeconds -= 1
            if remainingSeconds <= 0 {
                timer.invalidate()
                self?.sleepTimer = nil
                self?.sleepTimerMinutesRemaining = nil
                self?.avPlayer?.pause()
                self?.isPlaying = false
            } else {
                self?.sleepTimerMinutesRemaining = (remainingSeconds + 59) / 60
            }
        }
    }
    
    // MARK: - Lockscreen MPNowPlayingInfoCenter & Remote Command Center
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.avPlayer?.play()
            self?.isPlaying = true
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.avPlayer?.pause()
            self?.isPlaying = false
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(toSeconds: event.positionTime)
            return .success
        }
    }
    
    func updateNowPlayingInfo(song: Song) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = song.title
        info[MPMediaItemPropertyArtist] = song.artist
        info[MPMediaItemPropertyAlbumTitle] = song.album
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? playbackSpeed : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    // Helper formatted strings
    var currentTimeString: String {
        formatTime(currentTime)
    }
    
    var remainingTimeString: String {
        let remaining = max(0, duration - currentTime)
        return "-\(formatTime(remaining))"
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
