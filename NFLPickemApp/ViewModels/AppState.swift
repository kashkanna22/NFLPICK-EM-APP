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
    // Storage keys
    private let coinsKey = "np_coins"
    private let betHistoryKey = "np_bet_history"
    private let favoriteTeamKey = "np_favorite_team"
    
    // Currency
    var coins: Int = 10_000 {
        didSet { UserDefaults.standard.set(coins, forKey: coinsKey) }
    }
    
    // Bet history (serialized)
    private var betHistoryData: Data? {
        get { UserDefaults.standard.data(forKey: betHistoryKey) }
        set { UserDefaults.standard.set(newValue, forKey: betHistoryKey) }
    }
    
    // Favorite team (ESPN team id or string identifier)
    var favoriteTeamId: String? {
        get { UserDefaults.standard.string(forKey: favoriteTeamKey) }
        set { UserDefaults.standard.set(newValue, forKey: favoriteTeamKey) }
    }
    
    var bets: [BetRecord] = []
    
    init() {
        // load coins
        if let storedCoins = UserDefaults.standard.object(forKey: coinsKey) as? Int {
            coins = storedCoins
        } else {
            UserDefaults.standard.set(coins, forKey: coinsKey)
        }
        // load bets
        loadBets()
    }
    
    private func loadBets() {
        guard let data = betHistoryData else { return }
        if let decoded = try? JSONDecoder().decode([BetRecord].self, from: data) {
            bets = decoded
        }
    }
    
    private func persistBets() {
        if let data = try? JSONEncoder().encode(bets) {
            betHistoryData = data
        }
    }
    
    func placeBet(on game: Game, pickedTeam: String, stake: Int) {
        guard stake > 0, coins >= stake else { return }
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
    
    func settleBets(with games: [Game]) {
        var changed = false
        
        for idx in bets.indices {
            guard bets[idx].outcome == .pending,
                  let game = games.first(where: { $0.id == bets[idx].gameId }),
                  game.status == "post",
                  let homeScore = game.homeScore,
                  let awayScore = game.awayScore else { continue }
            
            let winningTeam: String
            if homeScore > awayScore {
                winningTeam = game.homeTeam
            } else if awayScore > homeScore {
                winningTeam = game.awayTeam
            } else {
                // tie – refund stake
                coins += bets[idx].stake
                bets[idx].outcome = .win
                bets[idx].payout = bets[idx].stake
                changed = true
                continue
            }
            
            if bets[idx].pickedTeam == winningTeam {
                let reward = bets[idx].stake * 2
                coins += reward
                bets[idx].outcome = .win
                bets[idx].payout = reward
            } else {
                bets[idx].outcome = .loss
                bets[idx].payout = 0
            }
            changed = true
        }
        
        if changed {
            persistBets()
        }
    }
    
    func cancelBet(id: UUID, with games: [Game]) {
        // Only allow cancel if the game is still pre
        guard let idx = bets.firstIndex(where: { $0.id == id }) else { return }
        guard let game = games.first(where: { $0.id == bets[idx].gameId }), game.status == "pre" else { return }
        // refund stake
        coins += bets[idx].stake
        // remove bet
        bets.remove(at: idx)
        persistBets()
    }
    
    func updateBet(id: UUID, newStake: Int? = nil, newPick: String? = nil, with games: [Game]) {
        guard let idx = bets.firstIndex(where: { $0.id == id }) else { return }
        guard let game = games.first(where: { $0.id == bets[idx].gameId }), game.status == "pre" else { return }

        var updatedStake = bets[idx].stake
        var updatedPick = bets[idx].pickedTeam

        // adjust stake: refund old stake, then charge new stake if provided
        if let newStake = newStake, newStake > 0 {
            // refund old
            coins += updatedStake
            // charge new if affordable
            guard coins >= newStake else { return }
            coins -= newStake
            updatedStake = newStake
        }

        if let newPick = newPick {
            updatedPick = newPick
        }

        // Recreate an updated BetRecord to avoid mutating let properties
        let existing = bets[idx]
        let updated = BetRecord(
            id: existing.id,
            gameId: existing.gameId,
            week: existing.week,
            homeTeam: existing.homeTeam,
            awayTeam: existing.awayTeam,
            pickedTeam: updatedPick,
            outcome: existing.outcome,
            stake: updatedStake,
            payout: existing.payout,
            placedAt: existing.placedAt
        )

        bets[idx] = updated
        persistBets()
    }
    
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

