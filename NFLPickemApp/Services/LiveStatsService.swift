//
//  LiveStatsService.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/30/25.
//
//
//  LiveStatsService.swift
//

import Foundation

actor LiveStatsService {
    static let shared = LiveStatsService()
    
    // --------------------
    // TEAM STANDINGS
    // --------------------
    func fetchTeamStandings() async throws -> [TeamStanding] {
        let url = URL(string: "https://sports.core.api.espn.com/v2/sports/football/nfl/standings")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ESPNStandingsResponse.self, from: data)
        
        return decoded.children.flatMap { $0.standings }
    }
    
    
    // --------------------
    // LEAGUE LEADERS
    // --------------------
    func fetchLeagueLeaders() async throws -> ESPNLeadersResponse {
        let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/leaders")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ESPNLeadersResponse.self, from: data)
    }
}
