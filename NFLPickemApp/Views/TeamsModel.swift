import Foundation

struct TeamsResponse: Decodable {
    let sports: [SportsContainer]
}

struct SportsContainer: Decodable {
    let leagues: [LeagueContainer]
}

struct LeagueContainer: Decodable {
    let teams: [TeamContainer]
}

struct TeamContainer: Decodable {
    let team: TeamSummary
}

struct TeamSummary: Decodable, Identifiable {
    let id: Int
    let name: String
    let market: String
    let abbreviation: String
    let logos: [TeamLogo]
}

extension TeamSummary {
    var primaryLogoURL: URL? {
        guard let logoURLString = logos.first?.href else {
            return nil
        }
        return URL(string: logoURLString)
    }
    
    var displayLabel: String {
        return "\(market) \(name)"
    }
}

struct TeamLogo: Decodable {
    let href: String
}

struct TeamDetail: Decodable, Identifiable {
    let id: Int
    let name: String
    let market: String
    let abbreviation: String
    let logos: [TeamLogo]
}

extension TeamDetail {
    var primaryLogoURL: URL? {
        guard let logoURLString = logos.first?.href else {
            return nil
        }
        return URL(string: logoURLString)
    }
}
