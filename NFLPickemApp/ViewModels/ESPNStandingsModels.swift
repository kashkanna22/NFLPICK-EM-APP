//
//  ESPNStandingsModels.swift
//  NFLPickemApp
//
//  Canonical models for ESPN standings
//

import Foundation

// ESPN standings sometimes nest under leagues, sometimes under children.
// This model supports both shapes.

struct ESPNStandingsResponse: Codable {
    let children: [ESPNStandingsNode]?   // conferences -> divisions -> teams
    let leagues: [ESPNStandingsLeague]?  // alternative root
}

struct ESPNStandingsLeague: Codable {
    let name: String?
    let children: [ESPNStandingsNode]?
}

struct ESPNStandingsNode: Codable {
    let name: String?
    let abbreviation: String?
    let children: [ESPNStandingsNode]?
    let standings: ESPNStandingsTable?
}

struct ESPNStandingsTable: Codable {
    let entries: [ESPNStandingsEntry]
}

struct ESPNStandingsEntry: Codable {
    let team: ESPNStandingsTeamRef
    let stats: [ESPNStandingsStat]?
}

struct ESPNStandingsTeamRef: Codable {
    let id: String
    let displayName: String?
    let name: String?           // nickname
    let logos: [ESPNImage]?
}

struct ESPNStandingsStat: Codable {
    let name: String
    let value: Double?
    let displayValue: String?
}

// Convenience helpers to extract W/L/T and winPct from stats array
extension ESPNStandingsEntry {
    var wins: Int {
        Int(stats?.first(where: { $0.name == "wins" })?.value ?? 0)
    }
    var losses: Int {
        Int(stats?.first(where: { $0.name == "losses" })?.value ?? 0)
    }
    var ties: Int {
        Int(stats?.first(where: { $0.name == "ties" })?.value ?? 0)
    }
    var winPct: Double {
        stats?.first(where: { $0.name == "winPercent" })?.value ?? 0
    }
    var teamLogo: String? {
        team.logos?.first?.href
    }
}
