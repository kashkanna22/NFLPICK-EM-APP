//
//  ESPNModels.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//

import Foundation

// -------------------------------
// MARK: - SCOREBOARD
// -------------------------------

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
    let name: String
    let state: String?
}

struct ESPNCompetitor: Codable {
    let homeAway: String
    let score: String?
    let team: ESPNTeam
}

struct ESPNTeam: Codable {
    let displayName: String
}


// =====================================================
// MARK: - STANDINGS (ESPN standings v2 endpoint)
// =====================================================
//
// URL: https://sports.core.api.espn.com/v2/sports/football/nfl/standings
//
// The JSON structure is nested, so we decode only what we need.
// =====================================================

struct ESPNStandingsResponse: Codable {
    let children: [StandingsGroup]
}

struct StandingsGroup: Codable {
    let standings: [TeamStanding]
}

struct TeamStanding: Codable {
    let team: StandingTeam
    let stats: [StandingStat]
}

struct StandingTeam: Codable {
    let id: String
    let displayName: String
}

struct StandingStat: Codable {
    let name: String
    let value: Double?
}


// =====================================================
// MARK: - LEAGUE LEADERS (NFL Leaders Endpoint)
// =====================================================
//
// URL: https://site.api.espn.com/apis/site/v2/sports/football/nfl/leaders
//
// =====================================================

struct ESPNLeadersResponse: Codable {
    let leaders: [LeaderCategory]
}

struct LeaderCategory: Codable {
    let name: String
    let leaders: [LeaderEntry]
}

struct LeaderEntry: Codable {
    let athlete: LeaderAthlete
    let value: Double
}

struct LeaderAthlete: Codable {
    let displayName: String
    let team: LeaderTeam?
}

struct LeaderTeam: Codable {
    let displayName: String
}


// MARK: - Helpers

extension ESPNStatusType {
    var normalizedGameStatus: String {
        let raw = (state ?? name).lowercased()
        
        if raw.contains("pre") { return "pre" }
        if raw.contains("in") || raw.contains("live") { return "in" }
        if raw.contains("post") || raw.contains("final") { return "post" }
        
        return "pre"
    }
}
