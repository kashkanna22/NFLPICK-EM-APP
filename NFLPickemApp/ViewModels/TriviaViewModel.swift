//
//  TriviaViewModel.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class TriviaViewModel {
    private let lastPlayedKey = "np_trivia_last_date"
    private var lastPlayedString: String {
        get { UserDefaults.standard.string(forKey: lastPlayedKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: lastPlayedKey) }
    }
    
    var currentQuestion: TriviaQuestion?
    var difficulty: TriviaDifficulty = .easy
    var questionsAnsweredToday: Int = 0
    var message: String?
    var canPlayToday: Bool {
        !playedToday
    }
    
    private let engine = TriviaEngine()
    private let calendar = Calendar.current
    unowned let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        if playedToday {
            message = "You’ve already played trivia today. Come back tomorrow!"
        }
    }
    
    private var playedToday: Bool {
        guard let date = dateFromString(lastPlayedString) else { return false }
        return calendar.isDateInToday(date)
    }
    
    private func markPlayedToday() {
        lastPlayedString = stringFromDate(Date())
    }
    
    func startSession() {
        guard !playedToday else {
            message = "You’ve already played trivia today."
            return
        }
        questionsAnsweredToday = 0
        difficulty = .easy
        message = nil
        nextQuestion()
    }
    
    func nextQuestion() {
        let q = engine.generateQuestion(difficulty: difficulty)
        currentQuestion = q
    }
    
    func answer(_ answer: Bool) {
        guard let q = currentQuestion else { return }
        
        if answer == q.correctAnswer {
            // correct!
            appState.coins += q.reward
            questionsAnsweredToday += 1
            message = "Correct! +\(q.reward) coins."
            // increase difficulty
            switch difficulty {
            case .easy: difficulty = .medium
            case .medium: difficulty = .hard
            case .hard: difficulty = .hard
            }
            // continue session, but max 5 questions
            if questionsAnsweredToday >= 5 {
                currentQuestion = nil
                markPlayedToday()
                message = "Great run! Come back tomorrow."
            } else {
                nextQuestion()
            }
        } else {
            // wrong answer: end session, no penalty
            message = "Incorrect, but no coins lost. Come back tomorrow."
            currentQuestion = nil
            markPlayedToday()
        }
    }
    
    // MARK: - Date helpers
    
    private func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func dateFromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}

