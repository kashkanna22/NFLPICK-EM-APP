//
//  AppState.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class AppState {

    // MARK: - UserDefaults Keys
    private let coinsKey = "np_coins"
    private let betHistoryKey = "np_bet_history"
    private let favoriteTeamKey = "np_favorite_team"

    // MARK: - Stored Properties
    var coins: Int = 10_000 {
        didSet { UserDefaults.standard.set(coins, forKey: coinsKey) }
    }
    
    var bets: [BetRecord] = []

    var favoriteTeamId: String? {
        get { UserDefaults.standard.string(forKey: favoriteTeamKey) }
        set { UserDefaults.standard.set(newValue, forKey: favoriteTeamKey) }
    }

    // MARK: - Initialization
    init() {
        if let storedCoins = UserDefaults.standard.object(forKey: coinsKey) as? Int {
            coins = storedCoins
        } else {
            UserDefaults.standard.set(coins, forKey: coinsKey)
        }

        loadBets()
    }

    // MARK: - Persistence
    private var betHistoryData: Data? {
        get { UserDefaults.standard.data(forKey: betHistoryKey) }
        set { UserDefaults.standard.set(newValue, forKey: betHistoryKey) }
    }

    private func loadBets() {
        guard let data = betHistoryData,
              let decoded = try? JSONDecoder().decode([BetRecord].self, from: data)
        else { return }

        bets = decoded
    }

    private func persistBets() {
        if let data = try? JSONEncoder().encode(bets) {
            betHistoryData = data
        }
    }

    // MARK: - Place Bet
    func placeBet(on game: Game, pickedTeam: String, stake: Int) {
        guard stake > 0, coins >= stake else { return }
        // Only allow bets before game starts
        guard game.status == "pre" else { return }

        coins -= stake

        let bet = BetRecord(
            id: UUID(),
            gameId: game.id,
            week: game.week,
            homeTeam: game.homeTeam,
            awayTeam: game.awayTeam,
            pickedTeam: pickedTeam,
            outcome: .pending,
            stake: stake,
            payout: 0,
            placedAt: Date()
        )

        bets.append(bet)
        persistBets()
    }

    // MARK: - Settle Bets
    func settleBets(with games: [Game]) {
        var changed = false

        for i in bets.indices {
            var bet = bets[i]

            // Only settle pending bets
            guard bet.outcome == .pending else { continue }

            guard let game = games.first(where: { $0.id == bet.gameId }),
                  game.status == "post",
                  let homeScore = game.homeScore,
                  let awayScore = game.awayScore
            else { continue }

            let winner: String

            // Tie = refund stake as a "push"
            if homeScore == awayScore {
                coins += bet.stake
                bet.outcome = .win
                bet.payout = bet.stake
                changed = true
                bets[i] = bet
                continue
            }

            winner = homeScore > awayScore ? game.homeTeam : game.awayTeam

            if bet.pickedTeam == winner {
                let reward = bet.stake * 2
                coins += reward
                bet.outcome = .win
                bet.payout = reward
            } else {
                bet.outcome = .loss
                bet.payout = 0
            }

            changed = true
            bets[i] = bet
        }

        if changed { persistBets() }
    }

    // MARK: - Cancel Bet
    func cancelBet(id: UUID, with games: [Game]) {
        guard let idx = bets.firstIndex(where: { $0.id == id }) else { return }
        let bet = bets[idx]

        guard let game = games.first(where: { $0.id == bet.gameId }) else { return }

        // Allow cancel only while game is pre-game
        guard game.status == "pre" else { return }

        coins += bet.stake
        bets.remove(at: idx)
        persistBets()
    }

    // MARK: - Edit Bet
    func updateBet(id: UUID, newStake: Int? = nil, newPick: String? = nil, with games: [Game]) {
        guard let idx = bets.firstIndex(where: { $0.id == id }) else { return }

        let oldBet = bets[idx]

        guard let game = games.first(where: { $0.id == oldBet.gameId }),
              game.status == "pre"
        else { return }

        var updatedStake = oldBet.stake
        var updatedPick = oldBet.pickedTeam

        // If stake changed
        if let newStake = newStake, newStake > 0 {
            // refund old stake
            coins += updatedStake
            // ensure we can afford new stake
            guard coins >= newStake else { return }
            coins -= newStake
            updatedStake = newStake
        }

        if let newPick = newPick {
            updatedPick = newPick
        }

        bets[idx] = BetRecord(
            id: oldBet.id,
            gameId: oldBet.gameId,
            week: oldBet.week,
            homeTeam: oldBet.homeTeam,
            awayTeam: oldBet.awayTeam,
            pickedTeam: updatedPick,
            outcome: oldBet.outcome,
            stake: updatedStake,
            payout: oldBet.payout,
            placedAt: oldBet.placedAt
        )

        persistBets()
    }

    // MARK: - Stats
    var totalWins: Int {
        bets.filter { $0.outcome == .win }.count
    }

    var totalLosses: Int {
        bets.filter { $0.outcome == .loss }.count
    }

    var winRate: Double {
        let total = totalWins + totalLosses
        guard total > 0 else { return 0 }
        return Double(totalWins) / Double(total)
    }
}
