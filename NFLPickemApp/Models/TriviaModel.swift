//
//  TriviaModels.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation

enum TriviaKind: String, Codable {
    case trueFalse
    case multipleChoice
    case numeric
}

struct TriviaQuestion: Identifiable, Codable {
    let id: UUID
    let kind: TriviaKind
    let text: String

    // True/False
    var correctAnswer: Bool?

    // Multiple Choice
    var choices: [String]?
    var correctIndex: Int?

    // Numeric
    var numericAnswer: Int?
    var tolerance: Int?

    var explanation: String?

    let reward: Int
}
