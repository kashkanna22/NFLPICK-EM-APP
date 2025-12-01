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
    
    // MARK: - Public state
    
    var currentQuestion: TriviaQuestion?
    var questionsAnsweredInRun: Int = 0
    var message: String?
    var showingExplanation: Bool = false
    var strikes: Int = 0
    let maxStrikes: Int = 3
    var triviaWeek: Int? = nil
    
    // Track if a session is active to guard tab changes
    private let activeKey = "np_trivia_active"
    private var isActive: Bool {
        get { UserDefaults.standard.bool(forKey: activeKey) }
        set { UserDefaults.standard.set(newValue, forKey: activeKey) }
    }
    
    /// Free mode: can user still play a free session today?
    var canPlayFree: Bool {
        !playedToday
    }
    
    /// Are we currently in a paid session?
    private var isPaidSession: Bool = false
    
    private let engine = TriviaEngineService()
    private let gamesProvider: () -> [Game]
    private let calendar = Calendar.current
    unowned let appState: AppState
    
    init(appState: AppState, gamesProvider: @escaping () -> [Game]) {
        self.appState = appState
        self.gamesProvider = gamesProvider
        if playedToday {
            message = "You’ve already used your free trivia today. You can still play using coins!"
        }
    }
    
    // MARK: - Daily tracking
    
    private var playedToday: Bool {
        guard let date = dateFromString(lastPlayedString) else { return false }
        return calendar.isDateInToday(date)
    }
    
    private func markPlayedToday() {
        lastPlayedString = stringFromDate(Date())
    }
    
    // MARK: - Start sessions
    
    /// Free session: allowed once per calendar day.
    func startFreeSession() {
        guard !playedToday else {
            message = "You’ve already used your free trivia today. Try a coin session!"
            return
        }
        
        resetRun(isPaid: false)
        message = "Free trivia session started!"
        
        Task {
            await nextQuestion()
        }
    }
    
    /// Paid session: costs coins, but can be used unlimited times.
    func startPaidSession(cost: Int = 250) {
        guard appState.coins >= cost else {
            message = "Not enough coins to start a paid trivia session."
            return
        }
        
        appState.coins -= cost
        resetRun(isPaid: true)
        message = "Paid trivia session started (−\(cost) coins)."
        
        Task {
            await nextQuestion()
        }
    }
    
    private func resetRun(isPaid: Bool) {
        questionsAnsweredInRun = 0
        isPaidSession = isPaid
        currentQuestion = nil
        strikes = 0
        showingExplanation = false
        isActive = true
    }
    
    // MARK: - Question generation
    
    func nextQuestion() async {
        // Determine most recent finished week for display and generation context
        let games = gamesProvider()
        let engineWeek = engine.mostRecentFinishedWeek(from: games)
        triviaWeek = engineWeek

        // TriviaEngine.generateQuestion(from:) is synchronous; no need to await
        let base = engine.generateQuestion(from: games)
        // Ensure difficulty is present; default to medium if not already set
        showingExplanation = false
        currentQuestion = base
    }

    // MARK: - Answering
    
    func answer(_ answer: Bool) {
        guard let q = currentQuestion else { return }

        switch q.kind {
        case .trueFalse:
            guard let correct = q.correctAnswer else { return }
            handleResult(isCorrect: answer == correct, reward: q.reward)
        case .multipleChoice, .numeric:
            // Ignore wrong handler usage
            return
        }
    }
    
    func answer(choiceIndex: Int) {
        guard let q = currentQuestion, q.kind == .multipleChoice,
              let correct = q.correctIndex else { return }
        handleResult(isCorrect: choiceIndex == correct, reward: q.reward)
    }
    
    func answer(numeric: Int) {
        guard let q = currentQuestion, q.kind == .numeric,
              let target = q.numericAnswer else { return }
        let tol = q.tolerance ?? 0
        let isCorrect = abs(numeric - target) <= tol
        handleResult(isCorrect: isCorrect, reward: q.reward)
    }
    
    private func handleResult(isCorrect: Bool, reward: Int) {
        if isCorrect {
            // Reward on correct regardless of session type
            appState.coins += reward
            questionsAnsweredInRun += 1
            message = "Correct! +\(reward) coins."
            showingExplanation = true

            if questionsAnsweredInRun >= 5 {
                currentQuestion = nil
                isActive = false
                if !isPaidSession {
                    markPlayedToday()
                    message = "Nice run! Free trivia done for today."
                } else {
                    message = "Nice run! Paid trivia session finished."
                }
            } 
            // Removed immediate nextQuestion call to wait for proceedAfterExplanation()
        } else {
            // Apply strikes and optional penalty (paid sessions only)
            strikes += 1

            // Penalty scheme: 20% of prospective reward, rounded to nearest 25; min 50, max 200
            if isPaidSession {
                let base = max(50, min(200, Int((Double(reward) * 0.2).rounded())))
                // Round to nearest 25 for nicer numbers
                let rounded = max(50, min(200, Int((Double(base) / 25.0).rounded()) * 25))
                appState.coins = max(0, appState.coins - rounded)
                message = "Strike \(strikes)/\(maxStrikes). −\(rounded) coins."
            } else {
                message = "Strike \(strikes)/\(maxStrikes). Keep going!"
            }
            showingExplanation = true

            if strikes >= maxStrikes {
                currentQuestion = nil
                isActive = false
                if !isPaidSession {
                    markPlayedToday()
                    message = (message ?? "") + " Free session finished."
                } else {
                    message = (message ?? "") + " Paid session finished."
                }
            } 
            // Removed immediate nextQuestion call to wait for proceedAfterExplanation()
        }
    }
    
    func proceedAfterExplanation() {
        guard showingExplanation else { return }
        if currentQuestion == nil { return }
        showingExplanation = false
        Task { await self.nextQuestion() }
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

