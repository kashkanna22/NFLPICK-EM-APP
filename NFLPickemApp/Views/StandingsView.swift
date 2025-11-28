import SwiftUI

struct StandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.teams.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView("Loading standings…")
                        if let error = viewModel.teamsError {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                } else if let error = viewModel.teamsError, viewModel.teams.isEmpty {
                    VStack(spacing: 16) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.refreshAll() }
                        }
                    }
                    .padding()
                } else {
                    List(viewModel.teams) { team in
                        HStack(spacing: 12) {
                            if let url = team.primaryLogoURL {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                            }
                            Text(team.displayLabel)
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if let error = viewModel.teamsError, !error.isEmpty {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Standings")
            .task { await viewModel.refreshAll() }
        }
    }
}
