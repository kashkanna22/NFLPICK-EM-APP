//
//  HomeView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//
import SwiftUI

struct HomeView: View {
    @State var appState: AppState
    @State var viewModel: GameViewModel
    @State private var selectedGame: Game? = nil
    @AppStorage("favoriteTeamId") private var favoriteTeamId: String = ""
    
    init(appState: AppState) {
        self._appState = State(initialValue: appState)
        self._viewModel = State(initialValue: GameViewModel(appState: appState))
    }
    
    // MARK: - Derived collections
    private var favoriteGames: [Game] {
        guard !favoriteTeamId.isEmpty else { return [] }
        return viewModel.games.filter { g in
            g.homeTeam == favoriteTeamId || g.awayTeam == favoriteTeamId
        }
    }
    private var liveGames: [Game] {
        viewModel.games.filter { $0.status == "in" }
            .sorted { $0.date < $1.date }
    }
    private var upcomingGames: [Game] {
        viewModel.games.filter { $0.status == "pre" }
            .sorted { $0.date < $1.date }
    }
    private var finalGames: [Game] {
        viewModel.games.filter { $0.status == "post" }
            .sorted { $0.date < $1.date }
    }

    private func teamColor(for game: Game, home: Bool) -> Color {
        guard game.status == "post",
              let hs = game.homeScore,
              let awayScore = game.awayScore else { return .primary }

        if hs == awayScore { return .primary }
        let homeWon = hs > awayScore
        return (home && homeWon) || (!home && !homeWon) ? .green : .red
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.isLoading {
                    ProgressView("Loading NFL Games…")
                        .padding()
                }
                
                else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                else {
                    List {
                        if !favoriteGames.isEmpty {
                            Section(header: Text("Favorites")) {
                                ForEach(favoriteGames) { game in
                                    gameRow(game)
                                }
                            }
                        }

                        if !liveGames.isEmpty {
                            Section(header: Text("Live")) {
                                ForEach(liveGames) { game in
                                    gameRow(game)
                                }
                            }
                        }

                        if !upcomingGames.isEmpty {
                            Section(header: Text("Upcoming")) {
                                ForEach(upcomingGames) { game in
                                    gameRow(game)
                                }
                            }
                        }

                        if !finalGames.isEmpty {
                            Section(header: Text("Final")) {
                                ForEach(finalGames) { game in
                                    gameRow(game)
                                }
                            }
                        }
                    }
                }
                
                Button {
                    Task { await viewModel.loadGames() }
                } label: {
                    Text("Fetch Games")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("NFL Pick’em")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 6) {
                        Text("🪙")
                        Text("\(appState.coins)")
                            .monospacedDigit()
                    }
                    .accessibilityLabel("Coins: \(appState.coins)")
                }
            }
            .task {
                await viewModel.loadGames()
            }
            .sheet(item: $selectedGame) { game in
                PredictionSheet(game: game, appState: appState)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .short
        return output.string(from: date)
    }
    
    @ViewBuilder
    private func gameRow(_ game: Game) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(game.awayTeam)
                    .foregroundColor(teamColor(for: game, home: false))
                if let a = game.awayScore, game.status != "pre" {
                    Text("\(a)").foregroundColor(teamColor(for: game, home: false))
                }
                Text("@")
                    .foregroundColor(.secondary)
                Text(game.homeTeam)
                    .foregroundColor(teamColor(for: game, home: true))
                if let h = game.homeScore, game.status != "pre" {
                    Text("\(h)").foregroundColor(teamColor(for: game, home: true))
                }
            }
            .font(.headline)

            Text(formatDate(game.date))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedGame = game }
    }
}

struct PredictionSheet: View {
    let game: Game
    @State var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Who will win?")
                .font(.title2)
                .bold()
            
            Text("\(game.awayTeam) @ \(game.homeTeam)")
                .font(.headline)
            
            Button(game.homeTeam) {
                appState.placeBet(on: game, pickedTeam: game.homeTeam, stake: 100)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button(game.awayTeam) {
                appState.placeBet(on: game, pickedTeam: game.awayTeam, stake: 100)
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
    }
}
