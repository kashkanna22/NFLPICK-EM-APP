//
//  BetRecord.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation

enum BetOutcome: String, Codable {
    case pending
    case win
    case loss
}

struct BetRecord: Identifiable, Codable {
    let id: UUID
    let gameId: String
    let week: Int
    let homeTeam: String
    let awayTeam: String
    let pickedTeam: String
    var outcome: BetOutcome
    let stake: Int
    var payout: Int
    let placedAt: Date
}

