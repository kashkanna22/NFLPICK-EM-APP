import Foundation

struct ScoreboardResponse: Decodable {
    let events: [ScoreboardEvent]
}

struct ScoreboardEvent: Decodable, Identifiable {
    let id: String
    let name: String
    let date: String
    let competitions: [Competition]
}

extension ScoreboardEvent {
    private static let dateFormatterInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let dateFormatterOutput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        formatter.locale = Locale.current
        return formatter
    }()
    
    var parsedDate: Date? {
        return Self.dateFormatterInput.date(from: date)
    }
    
    var formattedDate: String {
        guard let parsedDate = parsedDate else { return date }
        return Self.dateFormatterOutput.string(from: parsedDate)
    }
    
    var primaryCompetition: Competition? {
        return competitions.first
    }
    
    var homeTeam: Competitor? {
        return primaryCompetition?.competitors.first(where: { $0.homeAway == "home" })
    }
    
    var awayTeam: Competitor? {
        return primaryCompetition?.competitors.first(where: { $0.homeAway == "away" })
    }
    
    var statusText: String? {
        return primaryCompetition?.status.type?.description
    }
}

struct Competition: Decodable {
    let competitors: [Competitor]
    let status: CompetitionStatus
}

struct Competitor: Decodable {
    let id: String
    let homeAway: String
    let team: TeamRef
    let score: String
}

extension Competitor {
    var displayName: String {
        return team.displayName
    }
    
    var logoURL: URL? {
        return URL(string: team.logo)
    }
    
    var scoreValue: Int? {
        return Int(score)
    }
}

struct TeamRef: Decodable {
    let id: String
    let displayName: String
    let abbreviation: String
    let logo: String
}

struct CompetitionStatus: Decodable {
    let type: CompetitionStatusType?
}

struct CompetitionStatusType: Decodable {
    let state: String?
    let completed: Bool?
    let description: String?
}
