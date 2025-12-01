//
//  RootTabView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import SwiftUI

struct RootTabView: View {
    @State private var appState = AppState()
    private let gameViewModel: GameViewModel
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppearanceModel.system.rawValue
    
    private var appAppearance: AppearanceModel { AppearanceModel(rawValue: appAppearanceRaw) ?? .system }
    
    init() {
        // Initialize a single shared GameViewModel tied to the same appState instance
        self.gameViewModel = GameViewModel(appState: AppState())
    }
    
    var body: some View {
        ZStack {
            AppAppearanceView(appState: appState)
                .ignoresSafeArea()
            TabView {
                PicksView(viewModel: gameViewModel)
                    .tabItem {
                        Label("Picks", systemImage: "sportscourt")
                    }
                
                TriviaView(viewModel: TriviaViewModel(appState: appState, gamesProvider: { gameViewModel.games }))
                    .tabItem {
                        Label("Trivia", systemImage: "questionmark.circle")
                    }
                
                ProfileView(appState: $appState, games: gameViewModel.games)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
        .preferredColorScheme(appAppearance.colorScheme)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                    Text("\(appState.coins)")
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: appState.coins)
            }
        }
    }
}

