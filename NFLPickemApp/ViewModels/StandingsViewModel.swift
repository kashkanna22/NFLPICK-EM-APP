//
//  StandingsViewModel.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/25/25.
//
import Foundation
import Combine

// Uses shared models and helpers from: NetworkClient.swift, JSONDecodingHelpers.swift, DateFormattingHelpers.swift, TeamsModel.swift, NewsModel.swift, ScoreboardModel.swift

// MARK: - View Model
@MainActor
final class StandingsViewModel: ObservableObject {
    // MARK: - Published UI State
    @Published private(set) var isLoading: Bool = false

    @Published private(set) var scores: [ScoreboardEvent] = []
    @Published private(set) var news: [NewsArticle] = []
    @Published private(set) var teams: [TeamSummary] = []
    @Published private(set) var selectedTeam: TeamDetail?

    // Section-specific errors for better UX
    @Published private(set) var scoresError: String?
    @Published private(set) var newsError: String?
    @Published private(set) var teamsError: String?
    @Published private(set) var teamError: String?

    // MARK: - Endpoints
    struct Endpoint {
        static let scores = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard")!
        static let news = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/news")!
        static let teams = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams")!
        static func team(_ idOrSlug: String) -> URL { URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/\(idOrSlug)")! }
    }

    private let client = NetworkClient()

    // MARK: - Public API
    func refreshAll() async {
        clearErrors()
        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadScores() }
            group.addTask { await self.loadNews() }
            group.addTask { await self.loadTeams() }
        }
    }

    func loadScores() async {
        do {
            let data = try await client.get(Endpoint.scores)
            let decoded = try JSONDecoder.nfl.decode(ScoreboardResponse.self, from: data)
            self.scores = decoded.events
            self.scoresError = nil
        } catch {
            self.scoresError = friendlyError(prefix: "Scores", error: error)
        }
    }

    func loadNews() async {
        do {
            let data = try await client.get(Endpoint.news)
            let decoded = try JSONDecoder.nfl.decode(NewsResponse.self, from: data)
            self.news = decoded.articles
            self.newsError = nil
        } catch {
            self.newsError = friendlyError(prefix: "News", error: error)
        }
    }

    func loadTeams() async {
        do {
            let data = try await client.get(Endpoint.teams)
            let decoded = try JSONDecoder.nfl.decode(TeamsResponse.self, from: data)
            self.teams = decoded.sports.first?.leagues.first?.teams.map { $0.team } ?? []
            self.teamsError = nil
        } catch {
            self.teamsError = friendlyError(prefix: "Teams", error: error)
        }
    }

    func loadTeam(idOrSlug: String) async {
        do {
            let data = try await client.get(Endpoint.team(idOrSlug))
            let decoded = try JSONDecoder.nfl.decode(TeamDetail.self, from: data)
            self.selectedTeam = decoded
            self.teamError = nil
        } catch {
            self.teamError = friendlyError(prefix: "Team", error: error)
        }
    }

    func retryAll() async { await refreshAll() }

    // MARK: - Helpers
    private func clearErrors() { scoresError = nil; newsError = nil; teamsError = nil; teamError = nil }

    private func friendlyError(prefix: String, error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return "\(prefix): No internet connection."
            case .timedOut: return "\(prefix): Request timed out."
            default: break
            }
        }
        return "\(prefix): \(error.localizedDescription)"
    }
}
