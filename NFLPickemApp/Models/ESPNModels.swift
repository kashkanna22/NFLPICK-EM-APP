//
//  ESPNModels.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//
import Foundation

// These mirror the ESPN scoreboard JSON enough for our purposes.

struct ESPNScoreboardResponse: Codable {
    let events: [ESPNEvent]
}

struct ESPNEvent: Codable {
    let id: String
    let competitions: [ESPNCompetition]
    let week: ESPNWeek?
}

struct ESPNWeek: Codable {
    let number: Int?
}

struct ESPNCompetition: Codable {
    let date: String
    let status: ESPNStatus
    let competitors: [ESPNCompetitor]
}

struct ESPNStatus: Codable {
    let type: ESPNStatusType
}

struct ESPNStatusType: Codable {
    let name: String       // "pre", "in", "post"
}

struct ESPNCompetitor: Codable {
    let homeAway: String       // "home" or "away"
    let score: String?
    let team: ESPNTeam
}

struct ESPNTeam: Codable {
    let displayName: String
}
