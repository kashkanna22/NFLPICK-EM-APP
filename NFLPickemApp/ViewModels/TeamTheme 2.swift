import SwiftUI

struct NFLTeamTheme {
    static func colors(for teamId: String?) -> [Color] {
        guard let id = teamId else {
            return defaultColors
        }
        switch id {
        case "patriots":
            // New England Patriots: Navy and Red
            return [Color(red: 0.0/255.0, green: 34.0/255.0, blue: 68.0/255.0), Color(red: 198.0/255.0, green: 12.0/255.0, blue: 48.0/255.0)]
        case "packers":
            // Green Bay Packers: Green and Gold
            return [Color(red: 24.0/255.0, green: 48.0/255.0, blue: 40.0/255.0), Color(red: 255.0/255.0, green: 184.0/255.0, blue: 28.0/255.0)]
        case "cowboys":
            // Dallas Cowboys: Navy and Silver
            return [Color(red: 0.0/255.0, green: 34.0/255.0, blue: 68.0/255.0), Color(red: 134.0/255.0, green: 147.0/255.0, blue: 151.0/255.0)]
        case "niners", "49ers":
            // San Francisco 49ers: Red and Gold
            return [Color(red: 170.0/255.0, green: 0.0/255.0, blue: 0.0/255.0), Color(red: 173.0/255.0, green: 153.0/255.0, blue: 93.0/255.0)]
        case "chiefs":
            // Kansas City Chiefs: Red and Gold
            return [Color(red: 227.0/255.0, green: 24.0/255.0, blue: 55.0/255.0), Color(red: 255.0/255.0, green: 184.0/255.0, blue: 28.0/255.0)]
        case "eagles":
            // Philadelphia Eagles: Midnight Green and Silver
            return [Color(red: 0.0/255.0, green: 76.0/255.0, blue: 84.0/255.0), Color(red: 165.0/255.0, green: 172.0/255.0, blue: 175.0/255.0)]
        case "giants":
            // New York Giants: Blue and Red
            return [Color(red: 1.0/255.0, green: 35.0/255.0, blue: 82.0/255.0), Color(red: 163.0/255.0, green: 13.0/255.0, blue: 45.0/255.0)]
        case "bears":
            // Chicago Bears: Navy and Orange
            return [Color(red: 11.0/255.0, green: 22.0/255.0, blue: 42.0/255.0), Color(red: 200.0/255.0, green: 56.0/255.0, blue: 3.0/255.0)]
        case "jets":
            // New York Jets: Green and White
            return [Color(red: 18.0/255.0, green: 87.0/255.0, blue: 64.0/255.0), Color.white]
        case "ravens":
            // Baltimore Ravens: Purple and Black
            return [Color(red: 26.0/255.0, green: 25.0/255.0, blue: 95.0/255.0), Color.black]
        default:
            return defaultColors
        }
    }

    private static var defaultColors: [Color] {
        [Color.gray.opacity(0.6), Color.gray.opacity(0.3)]
    }
}
