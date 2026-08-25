//
//  ContentView.swift
//  musicPlayer
//
//  Created by enjay on 25/08/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var playerManager = AudioPlayerManager.shared
    @StateObject private var dataService = MusicDataService.shared
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab View
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Discover")
                    }
                    .tag(0)
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
                
                LibraryView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "music.note.list" : "music.note.list")
                        Text("Library")
                    }
                    .tag(2)
                
                EqualizerView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "slider.horizontal.3" : "slider.horizontal.3")
                        Text("Equalizer")
                    }
                    .tag(3)
            }
            .accentColor(AppTheme.primaryAccent)
            .onAppear {
                configureTabBar()
            }
            
            // Floating Mini Player docked right above tab bar
            if playerManager.currentSong != nil {
                MiniPlayerView()
                    .padding(.bottom, 52)
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $playerManager.showFullPlayer) {
            NowPlayingView()
        }
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 10/255, green: 12/255, blue: 18/255, alpha: 0.96)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 0.55, alpha: 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
