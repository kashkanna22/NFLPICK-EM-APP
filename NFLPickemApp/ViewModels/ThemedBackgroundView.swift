import SwiftUI

struct ThemedBackgroundView: View {
    private let opacity: Double
    private let favoriteTeamId: String?

    public init(appState: AppState, opacity: Double = 1.0) {
        self.favoriteTeamId = appState.favoriteTeamId
        self.opacity = opacity
    }

    var body: some View {
        let background: LinearGradient = {
            if let id = favoriteTeamId {
                return TeamTheme.gradient(for: id)  // no optional binding needed
            }
            
            // fallback
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.12, green: 0.14, blue: 0.20),
                    Color(.sRGB, red: 0.08, green: 0.09, blue: 0.12)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }()

        return background
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.4), value: favoriteTeamId ?? "none")
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.15),
                        .clear,
                        Color.black.opacity(0.25)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }
}
