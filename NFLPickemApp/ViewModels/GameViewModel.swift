//
//  GameViewModel.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/14/25.
//
// ViewModels/GameViewModel.swift
import Foundation
import Observation

@Observable
class GameViewModel {
    var selectedWeek: Int = 1
    let maxWeek: Int = 18
    private var initializedWeek = false
    
    var isLoading = false
    var errorMessage: String?
    var games: [Game] = []
    
    let api = NFLAPIService.shared
    let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func loadGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if !initializedWeek {
                let current = try await api.fetchCurrentScoreboard()
                // derive current week from first event if present
                if let wk = current.events.first?.week?.number, wk >= 1 && wk <= maxWeek {
                    selectedWeek = wk
                }
                initializedWeek = true
            }
            let result = try await api.fetchGames(week: selectedWeek)
            games = result.sorted { $0.date < $1.date }
            appState.settleBets(with: games)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load games: \(error.localizedDescription)"
        }
    }
    
    func changeWeek(offset: Int) async {
        let newWeek = min(max(1, selectedWeek + offset), maxWeek)
        guard newWeek != selectedWeek else { return }
        selectedWeek = newWeek
        await loadGames()
    }
}

