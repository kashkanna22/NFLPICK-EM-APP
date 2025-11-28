import SwiftUI

struct TeamTheme {
    static func gradient(for team: String) -> LinearGradient {
        let colors: [Color]
        
        switch team.lowercased() {
        case "lakers", "la lakers":
            colors = [Color.purple, Color.yellow]
        case "warriors", "golden state warriors":
            colors = [Color.blue, Color.yellow]
        case "celtics", "boston celtics":
            colors = [Color.green, Color.white]
        case "bulls", "chicago bulls":
            colors = [Color.red, Color.black]
        default:
            colors = [Color.gray, Color.black]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
