//
//  ScoreboardModel.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/30/25.
//
import Foundation

struct ScoreboardResponse: Decodable {
    let events: [ScoreboardEvent]
}

struct ScoreboardEvent: Decodable, Identifiable {
    let id: String
    let name: String
    let date: String
    let competitions: [Competition]
}

extension ScoreboardEvent {
    
    var primaryCompetition: Competition? {
        return competitions.first
    }
    
    var homeTeam: Competitor? {
        return primaryCompetition?.competitors.first(where: { $0.homeAway == "home" })
    }
    
    var awayTeam: Competitor? {
        return primaryCompetition?.competitors.first(where: { $0.homeAway == "away" })
    }
    
    var statusText: String? {
        return primaryCompetition?.status.type?.description
    }
}

struct Competition: Decodable {
    let competitors: [Competitor]
    let status: CompetitionStatus
}

struct Competitor: Decodable {
    let id: String
    let homeAway: String
    let team: TeamRef
    let score: String
}

extension Competitor {
    var displayName: String {
        return team.displayName
    }
    
    var logoURL: URL? {
        return URL(string: team.logo)
    }
    
    var scoreValue: Int? {
        return Int(score)
    }
}

struct TeamRef: Decodable {
    let id: String
    let displayName: String
    let abbreviation: String
    let logo: String
}

struct CompetitionStatus: Decodable {
    let type: CompetitionStatusType?
}

struct CompetitionStatusType: Decodable {
    let state: String?
    let completed: Bool?
    let description: String?
}

