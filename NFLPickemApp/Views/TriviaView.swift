//
//  TriviaView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//

import SwiftUI

struct TriviaView: View {
    @State var viewModel: TriviaViewModel
    @State private var showInstructions = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // COINS DISPLAY
                Text("Coins: \(viewModel.appState.coins)")
                    .font(.headline)
                    .padding(.top)

                // STRIKES DISPLAY
                if viewModel.questionsAnsweredInRun > 0 || viewModel.currentQuestion != nil || viewModel.message != nil || viewModel.strikes > 0 {
                    HStack(spacing: 6) {
                        ForEach(0..<viewModel.maxStrikes, id: \.self) { i in
                            Text(i < viewModel.strikes ? "✖︎" : "○")
                                .font(.title3)
                                .foregroundColor(i < viewModel.strikes ? .red : .secondary)
                        }
                    }
                    .accessibilityLabel("Strikes: \(viewModel.strikes) of \(viewModel.maxStrikes)")
                }

                // CURRENT QUESTION
                if let q = viewModel.currentQuestion {
                    Text(q.text)
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding()

                    switch q.kind {
                    case .trueFalse:
                        HStack(spacing: 24) {
                            Button("True") { viewModel.answer(true) }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.showingExplanation)
                            Button("False") { viewModel.answer(false) }
                                .buttonStyle(.bordered)
                                .disabled(viewModel.showingExplanation)
                        }

                    case .multipleChoice:
                        if let choices = q.choices {
                            VStack(spacing: 12) {
                                ForEach(Array(choices.enumerated()), id: \.0) { idx, title in
                                    Button(title) { viewModel.answer(choiceIndex: idx) }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .buttonStyle(.bordered)
                                        .disabled(viewModel.showingExplanation)
                                }
                            }
                            .padding(.horizontal)
                        }

                    case .numeric:
                        NumericAnswerView { value in
                            if !viewModel.showingExplanation { viewModel.answer(numeric: value) }
                        }
                    }

                    if viewModel.showingExplanation, let expl = q.explanation {
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                            Text("Explanation")
                                .font(.subheadline).bold()
                            Text(expl)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Button("Next") { viewModel.proceedAfterExplanation() }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 6)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                // NO QUESTION → SHOW START BUTTON
                else {
                    if let week = viewModel.triviaWeek {
                        Text("Week \(week) Trivia")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    VStack(spacing: 12) {
                        
                        // Free Play
                        Button("Start Trivia (Free)") {
                            viewModel.startFreeSession()
                        }
                        .buttonStyle(.borderedProminent)

                        // Paid Play
                        Button("Play Again for 250 Coins") {
                            viewModel.startPaidSession()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }

                // MESSAGE AREA
                if let msg = viewModel.message {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .navigationTitle("Trivia")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showInstructions = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("Trivia Instructions")
                }
            }
            .sheet(isPresented: $showInstructions) {
                NavigationView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How Trivia Works").font(.title3).bold()
                            Text("• Free session once per day.\n• Paid sessions cost 250 coins and can be played anytime.\n• Answer up to 5 questions per session.\n• 3 strikes ends the session.\n• Correct answers earn coins based on difficulty.\n• In paid sessions, wrong answers deduct a small coin penalty.")
                            Text("Tips").font(.headline)
                            Text("Numeric questions accept answers within a small tolerance (shown in the prompt). Explanations show the final score and why the statement is true or false.")
                        }
                        .padding()
                    }
                    .navigationTitle("Trivia Instructions")
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showInstructions = false } } }
                }
            }
        }
    }
}

struct NumericAnswerView: View {
    @State private var text: String = ""
    var onSubmit: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter a number", text: $text)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Submit") {
                if let val = Int(text.trimmingCharacters(in: .whitespaces)) {
                    onSubmit(val)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }
}
