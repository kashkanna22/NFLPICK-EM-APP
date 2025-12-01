//
//  ESPNTeamsModels.swift
//  NFLPickemApp
//
//  Canonical models for ESPN teams, team detail, and team schedule
//

import Foundation

// MARK: - Teams List (GET /teams)
struct ESPNTeamsResponse: Codable {
    let sports: [ESPNTeamsSport]
}

struct ESPNTeamsSport: Codable {
    let leagues: [ESPNTeamsLeague]
}

struct ESPNTeamsLeague: Codable {
    let teams: [ESPNTeamsContainer]
}

struct ESPNTeamsContainer: Codable {
    let team: ESPNTeamInfo
}

struct ESPNTeamInfo: Codable {
    let id: String
    let name: String?
    let displayName: String?
    let logos: [ESPNImage]?
}

struct ESPNImage: Codable {
    let href: String?
}

extension ESPNTeamInfo {
    var primaryLogo: String? { logos?.first?.href }
}

// MARK: - Team Detail (GET /teams/{teamId})
struct ESPNTeamDetailResponse: Codable {
    let team: ESPNTeamDetail
}

struct ESPNTeamDetail: Codable {
    let id: String
    let name: String?
    let displayName: String?
    let logos: [ESPNImage]?
    let record: ESPNTeamRecordWrapper?
}

struct ESPNTeamRecordWrapper: Codable {
    let items: [ESPNTeamRecordItem]?
}

struct ESPNTeamRecordItem: Codable {
    let summary: String?
}

// MARK: - Team Schedule (GET /teams/{teamId}/schedule)
struct ESPNTeamScheduleResponse: Codable {
    let events: [ESPNTeamScheduleEvent]
}

struct ESPNTeamScheduleEvent: Codable {
    let id: String
    let date: String
    let competitions: [ESPNTeamScheduleCompetition]
}

struct ESPNTeamScheduleCompetition: Codable {
    let competitors: [ESPNTeamScheduleCompetitor]
    let status: ESPNStatus
}

struct ESPNTeamScheduleCompetitor: Codable {
    let team: ESPNTeamScheduleTeam
    let homeAway: String
    let score: String?
}

struct ESPNTeamScheduleTeam: Codable {
    let id: String
    let displayName: String
}
