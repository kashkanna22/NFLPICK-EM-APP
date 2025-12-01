//
//  Game.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//
import Foundation

struct Game: Identifiable, Codable, Hashable {
    let id: String
    let week: Int
    let homeTeam: String
    let awayTeam: String
    let date: Date
    let status: String       // MUST be: "pre", "in", "post"
    let homeScore: Int?
    let awayScore: Int?
}

// MARK: - NORMALIZED STATUS LOGIC (THE FIX)
extension Game {

    static func normalizedStatus(from statusType: CompetitionStatusType?) -> String {
        guard let status = statusType else { return "pre" }

        if status.completed == true { return "post" }

        if let desc = status.description?.lowercased() {
            if desc.contains("final") { return "post" }
            if desc.contains("end") { return "post" }
            if desc.contains("complete") { return "post" }
            if desc.contains("scheduled") { return "pre" }
            if desc.contains("pre") { return "pre" }
            if desc.contains("in progress") { return "in" }
            if desc.contains("live") { return "in" }
            if desc.contains("halftime") { return "in" }
        }

        // fallback
        return "pre"
    }
}



