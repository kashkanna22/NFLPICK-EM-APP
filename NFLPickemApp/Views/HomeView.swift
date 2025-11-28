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
    
    init(appState: AppState) {
        self._appState = State(initialValue: appState)
        self._viewModel = State(initialValue: GameViewModel(appState: appState))
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
                    List(viewModel.games) { game in
                        VStack(alignment: .leading) {
                            Text("\(game.awayTeam) @ \(game.homeTeam)")
                                .font(.headline)
                            
                            Text(formatDate(game.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedGame = game
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
