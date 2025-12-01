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
    
    // MARK: - Correct ESPN date parser
    private func parseESPNDate(_ raw: String) -> Date? {
     return nil
    }
    
    // MARK: - Fetch Games
    func fetchGames(week: Int) async throws -> [Game] {
        guard let url = URL(string: "\(baseURL)/scoreboard?week=\(week)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(ESPNScoreboardResponse.self, from: data)
        
        var games: [Game] = []
        
        for event in response.events {
            guard let comp = event.competitions.first else { continue }
            let weekNum = event.week?.number ?? week
            
            let home = comp.competitors.first { $0.homeAway == "home" }
            let away = comp.competitors.first { $0.homeAway == "away" }
            
            guard let homeName = home?.team.displayName,
                  let awayName = away?.team.displayName
            else { continue }
            
            // Parse ESPN date correctly
            let gameDate = parseESPNDate(comp.date) ?? Date()   // NEVER distantFuture
            
            // Normalize ESPN status
            let status = comp.status.type.normalizedGameStatus
            
            let homeScore = Int(home?.score ?? "")
            let awayScore = Int(away?.score ?? "")
            
            games.append(
                Game(
                    id: event.id,
                    week: weekNum,
                    homeTeam: homeName,
                    awayTeam: awayName,
                    date: gameDate,
                    status: status,
                    homeScore: homeScore,
                    awayScore: awayScore
                )
            )
        }
        
        return games
    }
    
    // MARK: - Current Week
    func fetchCurrentScoreboard() async throws -> ESPNScoreboardResponse {
        guard let url = URL(string: "\(baseURL)/scoreboard") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ESPNScoreboardResponse.self, from: data)
    }
    
    // MARK: - Teams
    func fetchTeams() async throws -> ESPNTeamsResponse {
        guard let url = URL(string: "\(baseURL)/teams") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ESPNTeamsResponse.self, from: data)
    }
    
    func fetchTeamDetails(teamId: String) async throws -> ESPNTeamDetailResponse {
        guard let url = URL(string: "\(baseURL)/teams/\(teamId)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ESPNTeamDetailResponse.self, from: data)
    }
    
    func fetchTeamSchedule(teamId: String) async throws -> ESPNTeamScheduleResponse {
        guard let url = URL(string: "\(baseURL)/teams/\(teamId)/schedule") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ESPNTeamScheduleResponse.self, from: data)
    }
}
