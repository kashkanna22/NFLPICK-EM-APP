//
//  ProfileView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//

import SwiftUI
import Charts

struct ProfileView: View {
    @Binding var appState: AppState
    let games: [Game]      // from GameViewModel.games

    // MARK: - Derived collections
    
    private var pendingBets: [BetRecord] {
        appState.bets.filter { $0.outcome == .pending }
    }

    private var completedBets: [BetRecord] {
        appState.bets.filter { $0.outcome != .pending }
    }
    
    private var netProfitFromBets: Int {
        completedBets.reduce(0) { partial, bet in
            switch bet.outcome {
            case .win:
                return partial + (bet.payout - bet.stake)
            case .loss:
                return partial - bet.stake
            case .pending:
                return partial
            }
        }
    }
    
    // Total net including trivia: compare current coins to starting bankroll plus net deposits/withdrawals (none) 
    private var totalNetIncludingTrivia: Int {
        // Starting bankroll is 10,000
        let starting = 10_000
        return appState.coins - starting
    }

    /// Cumulative profit over time based on completed bets
    private var profitOverTime: [(Date, Int)] {
        var points: [(Date, Int)] = []
        var cumulative = 0

        let sorted = completedBets.sorted { $0.placedAt < $1.placedAt }

        for bet in sorted {
            let delta: Int
            switch bet.outcome {
            case .win:
                delta = bet.payout - bet.stake
            case .loss:
                delta = -bet.stake
            case .pending:
                delta = 0
            }
            cumulative += delta
            points.append((bet.placedAt, cumulative))
        }

        return points
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // HEADER
                    Text("Bankroll: \(appState.coins) coins")
                        .font(.title3)
                        .padding(.top)

                    Text("Record: \(appState.totalWins)-\(appState.totalLosses)")
                        .font(.subheadline)

                    Text("Win rate: \(String(format: "%.1f", appState.winRate * 100))%")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text("Bets Net: \(netProfitFromBets >= 0 ? "+\(netProfitFromBets)" : "\(netProfitFromBets)") coins")
                        .font(.footnote)
                        .foregroundColor(netProfitFromBets >= 0 ? .green : .red)

                    Text("Total Net (incl. trivia): \(totalNetIncludingTrivia >= 0 ? "+\(totalNetIncludingTrivia)" : "\(totalNetIncludingTrivia)") coins")
                        .font(.footnote)
                        .foregroundColor(totalNetIncludingTrivia >= 0 ? .green : .red)

                    Divider()

                    // PROFIT CHART
                    if !profitOverTime.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profit Over Time")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart {
                                ForEach(profitOverTime.indices, id: \.self) { i in
                                    LineMark(
                                        x: .value("Date", profitOverTime[i].0),
                                        y: .value("Profit", profitOverTime[i].1)
                                    )
                                }
                            }
                            .chartXAxisLabel("Date")
                            .chartYAxisLabel("Profit (coins)")
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                    }

                    // WIN RATE CHART
                    if appState.totalWins + appState.totalLosses > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Win Rate Breakdown")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart {
                                if appState.totalWins > 0 {
                                    SectorMark(
                                        angle: .value("Wins", appState.totalWins),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(.green)
                                }

                                if appState.totalLosses > 0 {
                                    SectorMark(
                                        angle: .value("Losses", appState.totalLosses),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(.red)
                                }
                            }
                            .accessibilityLabel("Win rate chart showing wins and losses")
                            .frame(height: 180)
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 10, height: 10)
                                    Text("Wins")
                                }
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                    Text("Losses")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        }
                    }

                    Divider()

                    // Pending section
                    if !pendingBets.isEmpty {
                        SectionHeader("Pending Bets")
                        ForEach(pendingBets.sorted(by: { $0.placedAt > $1.placedAt })) { bet in
                            HistoryGameRow(
                                bet: bet,
                                appState: appState,
                                games: games
                            )
                            .padding(.horizontal)
                        }
                    }

                    // Completed section
                    if !completedBets.isEmpty {
                        SectionHeader("Completed Bets")
                        ForEach(completedBets.sorted(by: { $0.placedAt > $1.placedAt })) { bet in
                            HistoryGameRow(
                                bet: bet,
                                appState: appState,
                                games: games
                            )
                            .padding(.horizontal)
                        }
                    }

                    if appState.bets.isEmpty {
                        Spacer(minLength: 40)
                        Text("No bets placed yet.")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Your Stats")
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - FULL History Game Row (GREEN/RED + SCORES + EDIT + CANCEL)

struct HistoryGameRow: View {
    let bet: BetRecord
    @State var appState: AppState
    let games: [Game]

    @State private var showEdit = false
    @State private var newStake = 500
    @State private var newPick: String?

    private var relatedGame: Game? {
        games.first(where: { $0.id == bet.gameId })
    }

    private var gameFinalScore: String? {
        if let g = relatedGame,
           let h = g.homeScore,
           let a = g.awayScore,
           g.status == "post" {
            return "Final: \(a)-\(h)"
        }
        return nil
    }

    private var pickedColor: Color {
        switch bet.outcome {
        case .win: return .green
        case .loss: return .red
        case .pending: return .primary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // TEAMS WITH WIN/LOSS COLOR (same idea as PicksView)
            HStack {
                Text(bet.awayTeam)
                    .foregroundColor(teamColor(team: bet.awayTeam))
                Text("@").foregroundColor(.secondary)
                Text(bet.homeTeam)
                    .foregroundColor(teamColor(team: bet.homeTeam))
            }
            .font(.headline)

            // FINAL SCORE IF AVAILABLE
            if let score = gameFinalScore {
                Text(score)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // PICK + OUTCOME PILLS
            HStack(spacing: 8) {
                Text("Picked: \(bet.pickedTeam)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())

                Text(betOutcomeText)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(pickedColor.opacity(0.12))
                    .foregroundColor(pickedColor)
                    .clipShape(Capsule())
            }

            // Stake/Payout line
            HStack {
                Text("Stake: \(bet.stake)")
                Text("Payout: \(bet.payout)")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // EDIT / CANCEL BUTTONS (only while game is still pre)
            if let game = relatedGame, game.status == "pre" {
                HStack(spacing: 12) {
                    Button("Edit Bet") {
                        newStake = bet.stake
                        newPick = bet.pickedTeam
                        showEdit = true
                    }
                    .buttonStyle(.bordered)

                    Button("Cancel Bet", role: .destructive) {
                        appState.cancelBet(id: bet.id, with: games)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $showEdit) {
            editSheet
        }
    }

    // MARK: Helpers

    private var betOutcomeText: String {
        switch bet.outcome {
        case .win: return "Won +\(bet.payout)"
        case .loss: return "Lost \(bet.stake)"
        case .pending: return "Pending"
        }
    }

    private func teamColor(team: String) -> Color {
        if bet.pickedTeam == team && bet.outcome == .win { return .green }
        if bet.pickedTeam == team && bet.outcome == .loss { return .red }
        return .primary
    }

    // MARK: Edit sheet
    private var editSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Bet").font(.title3).bold()

                Picker("Pick", selection: Binding(
                    get: { newPick ?? bet.pickedTeam },
                    set: { newPick = $0 }
                )) {
                    Text(bet.homeTeam).tag(Optional(bet.homeTeam))
                    Text(bet.awayTeam).tag(Optional(bet.awayTeam))
                }
                .pickerStyle(.segmented)

                Stepper("Stake: \(newStake) coins", value: $newStake, in: 100...2000, step: 100)

                Spacer()

                Button("Save") {
                    appState.updateBet(
                        id: bet.id,
                        newStake: newStake,
                        newPick: newPick,
                        with: games
                    )
                    showEdit = false
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") { showEdit = false }
            }
            .padding()
            .navigationTitle("Edit Bet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

