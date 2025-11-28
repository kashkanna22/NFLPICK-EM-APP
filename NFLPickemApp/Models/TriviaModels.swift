//
//  TriviaModels.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation

enum TriviaDifficulty: Int, Codable {
    case easy = 1
    case medium = 2
    case hard = 3
}

struct TriviaQuestion: Identifiable, Codable {
    let id: UUID
    let text: String
    let correctAnswer: Bool      // true / false style questions
    let difficulty: TriviaDifficulty
    let reward: Int
}

