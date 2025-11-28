//
//  PicksView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import SwiftUI

struct PicksView: View {
    @State var viewModel: GameViewModel
    @State private var showWeekPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                weekSelector
                
                if viewModel.isLoading {
                    ProgressView("Loading Week \(viewModel.selectedWeek)…")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.games.isEmpty {
                    Text("No games found for this week yet.")
                        .padding()
                } else {
                    List(viewModel.games) { game in
                        GameRow(game: game, appState: viewModel.appState)
                    }
                }
            }
            .navigationTitle("NFL Pick’em")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Jump Week") { showWeekPicker = true }
                }
            }
            .sheet(isPresented: $showWeekPicker) {
                NavigationView {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(1...viewModel.maxWeek, id: \.self) { w in
                                Button(action: {
                                    showWeekPicker = false
                                    Task { viewModel.selectedWeek = w; await viewModel.loadGames() }
                                }) {
                                    Text("Week \(w)")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(w == viewModel.selectedWeek ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Jump to Week")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showWeekPicker = false }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadGames()
            }
        }
    }
    
    private var weekSelector: some View {
        HStack {
            Button {
                Task { await viewModel.changeWeek(offset: -1) }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(viewModel.selectedWeek == 1)
            
            Spacer()
            
            Text("Week \(viewModel.selectedWeek)")
                .font(.headline)
            
            Spacer()
            
            Button {
                Task { await viewModel.changeWeek(offset: 1) }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(viewModel.selectedWeek == viewModel.maxWeek)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct GameRow: View {
    let game: Game
    @State var appState: AppState
    @State private var showSheet = false
    @State private var showEdit = false
    @State private var editStake: Int = 500
    @State private var editPick: String?
    
    private var existingBet: BetRecord? {
        appState.bets.first(where: { $0.gameId == game.id && $0.outcome == .pending })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(game.awayTeam) @ \(game.homeTeam)")
                .font(.headline)
            
            Text(dateString)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let homeScore = game.homeScore,
               let awayScore = game.awayScore,
               game.status == "post" {
                Text("Final: \(awayScore) - \(homeScore)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                Text(statusText)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
                if let bet = existingBet {
                    Text("Your bet: \(bet.pickedTeam) • \(bet.stake)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
            
            Button {
                showSheet = true
            } label: {
                Text("Pick Winner")
                    .font(.subheadline)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(8)
            }
            .padding(.top, 4)
            
            if game.status == "pre", let bet = existingBet {
                HStack(spacing: 12) {
                    Button("Edit Bet") {
                        editStake = bet.stake
                        editPick = bet.pickedTeam
                        showEdit = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Cancel Bet", role: .destructive) {
                        appState.cancelBet(id: bet.id, with: [game])
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showSheet) {
            PlaceBetSheet(game: game, appState: appState)
        }
        .sheet(isPresented: $showEdit) {
            NavigationView {
                VStack(spacing: 16) {
                    Text("Edit Bet")
                        .font(.title3)
                        .bold()
                    Picker("Pick", selection: Binding(
                        get: { editPick ?? existingBet?.pickedTeam },
                        set: { editPick = $0 }
                    )) {
                        Text(game.homeTeam).tag(Optional(game.homeTeam))
                        Text(game.awayTeam).tag(Optional(game.awayTeam))
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    Stepper("Stake: \(editStake) coins", value: $editStake, in: 100...2_000, step: 100)
                        .padding(.horizontal)
                    
                    Spacer()
                    Button("Save") {
                        appState.updateBet(id: existingBet!.id, newStake: editStake, newPick: editPick, with: [game])
                        showEdit = false
                    }
                    .disabled(existingBet == nil)
                    
                    Button("Cancel") { showEdit = false }
                        .padding(.top, 4)
                }
                .padding(.top)
                .navigationTitle("Edit Bet")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private var dateString: String {
        formatGameDate(game.date)
    }
    
    private var statusText: String {
        switch game.status {
        case "pre": return "Not started"
        case "in": return "In progress"
        case "post": return "Final"
        default: return game.status
        }
    }
    
    private var statusColor: Color {
        switch game.status {
        case "pre": return .gray
        case "in": return .green
        case "post": return .secondary
        default: return .secondary
        }
    }
}

struct PlaceBetSheet: View {
    let game: Game
    @State var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var stake: Int = 500
    @State private var pickedTeam: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("\(game.awayTeam) @ \(game.homeTeam)")
                    .font(.title3)
                    .bold()
                
                Text("Your coins: \(appState.coins)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Pick", selection: $pickedTeam) {
                    Text(game.homeTeam).tag(Optional(game.homeTeam))
                    Text(game.awayTeam).tag(Optional(game.awayTeam))
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Stepper("Stake: \(stake) coins", value: $stake, in: 100...2_000, step: 100)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    if let team = pickedTeam {
                        appState.placeBet(on: game, pickedTeam: team, stake: stake)
                        dismiss()
                    }
                } label: {
                    Text("Place Bet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pickedTeam == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(pickedTeam == nil || stake > appState.coins)
                
                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 4)
            }
            .padding(.top)
            .navigationTitle("Place Bet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

