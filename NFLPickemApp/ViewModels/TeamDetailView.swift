import SwiftUI

struct TeamDetailView: View {
    let teamId: String
    @State private var detail: ESPNTeamDetail?
    @State private var schedule: ESPNTeamScheduleResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var appState = AppState()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading team…")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let d = detail {
                ScrollView {
                    VStack(spacing: 16) {
                        if let logo = d.logos?.first?.href, let url = URL(string: logo) {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFit()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(height: 80)
                            .padding(.top)
                        }
                        
                        Text(d.name ?? "")
                            .font(.largeTitle).bold()
                        if let full = d.displayName { Text(full).font(.subheadline).foregroundColor(.secondary) }
                        if let rec = d.record?.items?.first?.summary { Text("Record: \(rec)") }
                        
                        Button {
                            appState.favoriteTeamId = teamId
                        } label: {
                            Label("Set as Favorite", systemImage: "star.fill")
                        }
                        .buttonStyle(.bordered)
                        
                        Divider().padding(.vertical, 8)
                        
                        if let events = schedule?.events {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent Results").font(.headline)
                                ForEach(events.prefix(5), id: \.id) { ev in
                                    if let comp = ev.competitions.first {
                                        HStack {
                                            Text(resultLine(comp))
                                                .font(.subheadline)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No team data")
            }
        }
        .navigationTitle("Team")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }
    
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let d = NFLAPIService.shared.fetchTeamDetails(teamId: teamId)
            async let s = NFLAPIService.shared.fetchTeamSchedule(teamId: teamId)
            let (detailResp, scheduleResp) = try await (d, s)
            self.detail = detailResp.team
            self.schedule = scheduleResp
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load team: \(error.localizedDescription)"
        }
    }
    
    private func resultLine(_ comp: ESPNTeamScheduleCompetition) -> String {
        // Build a simple result like "W 27-20 vs Opponent" or "L 20-27 @ Opponent"
        let home = comp.competitors.first { $0.homeAway == "home" }
        let away = comp.competitors.first { $0.homeAway == "away" }
        let homeScore = Int(home?.score ?? "") ?? 0
        let awayScore = Int(away?.score ?? "") ?? 0
        let isHomeTeam = home?.team.id == teamId
        let opponentName = isHomeTeam ? (away?.team.displayName ?? "Opponent") : (home?.team.displayName ?? "Opponent")
        let weScore = isHomeTeam ? homeScore : awayScore
        let theyScore = isHomeTeam ? awayScore : homeScore
        let venue = isHomeTeam ? "vs" : "@"
        let outcome = weScore == theyScore ? "T" : (weScore > theyScore ? "W" : "L")
        return "\(outcome) \(weScore)-\(theyScore) \(venue) \(opponentName)"
    }
}
