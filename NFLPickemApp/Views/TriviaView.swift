//
//  TriviaView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
import SwiftUI

struct TriviaView: View {
    @State var viewModel: TriviaViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                Text("Coins: \(viewModel.appState.coins)")
                    .font(.headline)
                    .padding(.top)
                
                if let q = viewModel.currentQuestion {
                    Text(q.text)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    HStack(spacing: 24) {
                        Button("True") {
                            viewModel.answer(true)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("False") {
                            viewModel.answer(false)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("Difficulty: \(q.difficulty.rawValue)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                } else {
                    if viewModel.canPlayToday {
                        Button("Start Daily Trivia") {
                            viewModel.startSession()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    } else {
                        Text("You’ve already played trivia today. Come back tomorrow.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                if let message = viewModel.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .navigationTitle("Daily Trivia")
        }
    }
}

