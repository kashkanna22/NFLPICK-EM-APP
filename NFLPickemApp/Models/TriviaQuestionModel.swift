//
//  TriviaQuestionModel.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/30/25.
//
import Foundation

struct TriviaQuestionModel: Identifiable, Codable {
    let id: UUID
    let text: String
    let correctAnswer: Bool
    let reward: Int
}
