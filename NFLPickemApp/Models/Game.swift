//
//  Game.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//
import Foundation

struct Game: Identifiable, Codable, Hashable {
    let id: String           // ESPN event id
    let week: Int
    let homeTeam: String
    let awayTeam: String
    let date: Date
    let status: String       // "pre", "in", "post"
    let homeScore: Int?
    let awayScore: Int?
}




