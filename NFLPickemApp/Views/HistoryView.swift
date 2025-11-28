//
//  HistoryView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import SwiftUI

struct HistoryView: View {
    @Binding var appState: AppState
    @State private var showTeamPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Bankroll: \(appState.coins) coins")
                    .font(.title3)
                    .padding(.top)
                
                Text("Record: \(appState.totalWins)-\(appState.totalLosses)")
                    .font(.subheadline)
                
                Text("Win rate: \(String(format: "%.1f", appState.winRate * 100))%")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Divider().padding(.vertical, 4)
                
                HStack { Text("Settings").font(.headline); Spacer() }
                    .padding(.horizontal)
                
                Button {
                    showTeamPicker = true
                } label: {
                    HStack {
                        Text("Favorite Team: ")
                        Text(appState.favoriteTeamId ?? "None")
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showTeamPicker) {
                    NavigationView {
                        VStack(spacing: 16) {
                            Text("Team picker coming soon")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .navigationTitle("Pick Favorite")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showTeamPicker = false } }
                        }
                    }
                }
                
                if appState.bets.isEmpty {
                    Spacer()
                    Text("No bets placed yet.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(appState.bets.sorted(by: { $0.placedAt > $1.placedAt })) { bet in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(bet.awayTeam) @ \(bet.homeTeam)")
                                .font(.headline)
                            Text("Picked: \(bet.pickedTeam)")
                                .font(.subheadline)
                            
                            HStack {
                                Text("Stake: \(bet.stake)")
                                Text("Outcome: \(bet.outcome.rawValue.capitalized)")
                                Text("Payout: \(bet.payout)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Your Stats")
        }
    }
}

