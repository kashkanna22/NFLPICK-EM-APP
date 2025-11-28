//
//  RootTabView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import SwiftUI

struct RootTabView: View {
    @State private var appState = AppState()
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppearanceModel.system.rawValue
    
    private var appAppearance: AppearanceModel { AppearanceModel(rawValue: appAppearanceRaw) ?? .system }
    
    var body: some View {
        ZStack {
            ThemedBackgroundView(appState: appState)
                .ignoresSafeArea()
            TabView {
                PicksView(viewModel: GameViewModel(appState: appState))
                    .tabItem {
                        Label("Picks", systemImage: "sportscourt")
                    }
                
                TriviaView(viewModel: TriviaViewModel(appState: appState))
                    .tabItem {
                        Label("Trivia", systemImage: "questionmark.circle")
                    }
                
                StandingsView()
                    .tabItem {
                        Label("Standings", systemImage: "list.number")
                    }
                
                HistoryView(appState: $appState)
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

