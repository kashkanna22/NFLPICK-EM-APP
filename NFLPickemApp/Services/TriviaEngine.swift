//
//  TriviaEngine.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation

struct TriviaEngine {
    
    // For now, this uses simple hard-coded logic.
    // You can later plug in live stats from ESPN’s team/player endpoints.
    
    func generateQuestion(difficulty: TriviaDifficulty) -> TriviaQuestion {
        switch difficulty {
        case .easy:
            return TriviaQuestion(
                id: UUID(),
                text: "Did the Kansas City Chiefs win a Super Bowl with Patrick Mahomes at QB?",
                correctAnswer: true,
                difficulty: .easy,
                reward: 100
            )
        case .medium:
            return TriviaQuestion(
                id: UUID(),
                text: "True or false: A field goal is worth 4 points.",
                correctAnswer: false,
                difficulty: .medium,
                reward: 250
            )
        case .hard:
            return TriviaQuestion(
                id: UUID(),
                text: "True or false: A team can attempt a two-point conversion after a field goal.",
                correctAnswer: false,
                difficulty: .hard,
                reward: 500
            )
        }
    }
}

