//
//  NFLAPIService.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation

actor NFLAPIService {
    static let shared = NFLAPIService()
    
    private let baseURL = "https://site.api.espn.com/apis/site/v2/sports/football/nfl"
    
    func fetchGames(week: Int) async throws -> [Game] {
        guard let url = URL(string: "\(baseURL)/scoreboard?week=\(week)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(ESPNScoreboardResponse.self, from: data)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var games: [Game] = []
        
        for event in response.events {
            guard let comp = event.competitions.first else { continue }
            let weekNum = event.week?.number ?? week
            
            let home = comp.competitors.first { $0.homeAway == "home" }
            let away = comp.competitors.first { $0.homeAway == "away" }
            
            guard let homeTeam = home?.team.displayName,
                  let awayTeam = away?.team.displayName else { continue }
            
            let date: Date = {
                if let d = formatter.date(from: comp.date) { return d }
                let alt = ISO8601DateFormatter()
                alt.formatOptions = [.withInternetDateTime]
                if let d2 = alt.date(from: comp.date) { return d2 }
                // final fallback: try DateFormatter with common format
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                return df.date(from: comp.date) ?? Date.distantFuture
            }()
            let statusName = comp.status.type.name
            
            let homeScore = Int(home?.score ?? "")
            let awayScore = Int(away?.score ?? "")
            
            let game = Game(
                id: event.id,
                week: weekNum,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                date: date,
                status: statusName,
                homeScore: homeScore,
                awayScore: awayScore
            )
            
            games.append(game)
        }
        
        return games
    }
    
    // MARK: - Standings
    func fetchStandings() async throws -> ESPNStandingsResponse {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/standings") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNStandingsResponse.self, from: data)
    }

    // MARK: - Teams
    func fetchTeams() async throws -> ESPNTeamsResponse {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNTeamsResponse.self, from: data)
    }

    func fetchTeamDetails(teamId: String) async throws -> ESPNTeamDetailResponse {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/\(teamId)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNTeamDetailResponse.self, from: data)
    }

    func fetchTeamSchedule(teamId: String) async throws -> ESPNTeamScheduleResponse {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/\(teamId)/schedule") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNTeamScheduleResponse.self, from: data)
    }
    
    // MARK: - Current Scoreboard / Week
    func fetchCurrentScoreboard() async throws -> ESPNScoreboardResponse {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNScoreboardResponse.self, from: data)
    }
}
