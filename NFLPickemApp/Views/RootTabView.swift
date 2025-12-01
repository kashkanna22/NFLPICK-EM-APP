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
    
    @State private var showLeaveTriviaAlert = false
    @State private var pendingTabSelection: Int? = nil
    @State private var selectedTab: Int = 0
    
    private var appAppearance: AppearanceModel { AppearanceModel(rawValue: appAppearanceRaw) ?? .system }
    
    init() {
        let shared = AppState()
        self._appState = State(initialValue: shared)
        self.gameViewModel = GameViewModel(appState: shared)
    }
    
    var body: some View {
        ZStack {
            AppAppearanceView(appState: appState)
                .ignoresSafeArea()
            TabView(selection: $selectedTab) {
                PicksView(viewModel: gameViewModel)
                    .tabItem {
                        Label("Picks", systemImage: "sportscourt")
                    }
                    .tag(0)
                
                TriviaView(viewModel: TriviaViewModel(appState: appState, gamesProvider: { gameViewModel.games }))
                    .tabItem {
                        Label("Trivia", systemImage: "questionmark.circle")
                    }
                    .tag(1)
                
                ProfileView(appState: $appState, games: gameViewModel.games)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(3)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // If we are leaving Trivia (1) and a trivia session is active, confirm
                if oldValue == 1 && newValue != 1 {
                    // Access the trivia view model through a stored reference is not available here.
                    // Use NotificationCenter to query state: post a request and expect a response boolean in UserDefaults.
                    let active = UserDefaults.standard.bool(forKey: "np_trivia_active")
                    if active {
                        pendingTabSelection = newValue
                        selectedTab = oldValue // revert until confirmed
                        showLeaveTriviaAlert = true
                    }
                }
            }
        }
        .preferredColorScheme(appAppearance.colorScheme)
        .alert("Leave Trivia?", isPresented: $showLeaveTriviaAlert) {
            Button("Stay", role: .cancel) {}
            Button("Leave", role: .destructive) {
                UserDefaults.standard.set(false, forKey: "np_trivia_active")
                if let target = pendingTabSelection { selectedTab = target }
            }
        } message: {
            Text("You have an ongoing trivia session. Are you sure you want to leave?")
        }
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

