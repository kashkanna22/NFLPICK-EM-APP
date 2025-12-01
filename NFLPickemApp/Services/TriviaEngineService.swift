//
//  TriviaEngineService.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/24/25.
//
//

import Foundation

class TriviaEngineService {

    func mostRecentFinishedWeek(from games: [Game]) -> Int? {
        let finished = games.filter { $0.status == "post" }
        let weeks = finished.map { $0.week }
        return weeks.max()
    }

    func generateQuestion(from games: [Game]) -> TriviaQuestion {

        let targetWeek = mostRecentFinishedWeek(from: games)

        // Use only games that are completed
        let finished = games.filter { $0.status == "post" && (targetWeek == nil || $0.week == targetWeek) }

        guard let game = finished.randomElement(),
              let homeScore = game.homeScore,
              let awayScore = game.awayScore
        else {
            return TriviaQuestion(
                id: UUID(),
                kind: .trueFalse,
                text: "True or False: The NFL has 32 teams.",
                correctAnswer: true,
                choices: nil,
                correctIndex: nil,
                numericAnswer: nil,
                tolerance: nil,
                explanation: nil,
                reward: 100
            )
        }

        let homeWon = homeScore > awayScore
        let margin = abs(homeScore - awayScore)

        let total = homeScore + awayScore
        let isBlowout = margin >= 17
        let isOneScore = margin <= 8
        let homeOdd = homeScore % 2 == 1
        let awayOdd = awayScore % 2 == 1
        let totalOdd = total % 2 == 1

        func scoreLine() -> String { "Final score: \(game.awayTeam) \(awayScore) @ \(game.homeTeam) \(homeScore)." }
        func marginLine() -> String { "Margin: \(margin) (\(isOneScore ? "one-score" : (isBlowout ? "blowout" : "two-score+")))." }
        func totalLine() -> String { "Total points: \(total) (\(totalOdd ? "odd" : "even"))." }

        // Randomly select a question kind (weighted for variety)
        enum GenKind { case tf, mcq, numeric }
        let roll = Int.random(in: 0..<100)
        let genKind: GenKind = roll < 50 ? .tf : (roll < 85 ? .mcq : .numeric)

        switch genKind {
        case .tf:
            // Build varied True/False templates (context-rich)
            let options: [(String, Bool)] = [
                ("\(game.homeTeam) defeated \(game.awayTeam).", homeWon),
                ("\(game.awayTeam) outscored \(game.homeTeam).", !homeWon),
                ("The showdown between \(game.awayTeam) and \(game.homeTeam) was decided by more than 10 points.", margin > 10),
                ("\(game.awayTeam) @ \(game.homeTeam) was a one-score game (8 points or fewer).", isOneScore),
                ("\(game.awayTeam) @ \(game.homeTeam) was a blowout (17+ point margin).", isBlowout),
                ("\(game.homeTeam) put up at least 20 points.", homeScore >= 20),
                ("\(game.awayTeam) put up at least 20 points.", awayScore >= 20),
                ("\(game.homeTeam) exploded for 30 or more points.", homeScore >= 30),
                ("\(game.awayTeam) exploded for 30 or more points.", awayScore >= 30),
                ("\(game.homeTeam) was held under 14 points.", homeScore < 14),
                ("\(game.awayTeam) was held under 14 points.", awayScore < 14),
                ("One team pitched a shutout in \(game.awayTeam) @ \(game.homeTeam).", homeScore == 0 || awayScore == 0),
                ("Both teams reached double digits.", homeScore >= 10 && awayScore >= 10),
                ("The total points in \(game.awayTeam) @ \(game.homeTeam) were odd.", totalOdd),
                ("Both \(game.awayTeam) and \(game.homeTeam) finished with odd scores.", homeOdd && awayOdd),
                ("At least one of \(game.awayTeam) or \(game.homeTeam) finished with an even score.", !homeOdd || !awayOdd),
                ("\(game.homeTeam) and \(game.awayTeam) combined for more than 40 points.", total > 40),
                ("\(game.awayTeam) and \(game.homeTeam) combined for at least 50 points.", total >= 50),
                ("\(game.awayTeam) and \(game.homeTeam) combined for under 35 points.", total < 35),
                ("\(game.awayTeam) @ \(game.homeTeam) was decided by a field goal or less (3 points or fewer).", margin <= 3),
                ("\(game.homeTeam) finished on top at the final whistle.", homeWon),
                ("The matchup between \(game.awayTeam) and \(game.homeTeam) featured at least 45 total points.", total >= 45),
                ("Neither \(game.awayTeam) nor \(game.homeTeam) reached 20 points.", homeScore < 20 && awayScore < 20),
                ("\(game.awayTeam) and \(game.homeTeam) combined for an even number of points.", !totalOdd),
                ("\(game.awayTeam) won the game.", !homeWon),
                ("\(game.homeTeam) held \(game.awayTeam) to 10 points or fewer.", awayScore <= 10),
                ("\(game.awayTeam) held \(game.homeTeam) to 10 points or fewer.", homeScore <= 10),
                ("The clash at \(game.homeTeam) was a nail-biter (decided by 2 points or fewer).", margin <= 2),
                ("\(game.awayTeam) @ \(game.homeTeam) soared past 60 total points.", total > 60)
            ]

            let selected = options.randomElement()!
            let statement = selected.0
            let expl: String = {
                switch statement {
                case _ where statement.contains("defeated") || statement.contains("finished on top"):
                    return scoreLine()
                case _ where statement.contains("outscored") || statement.contains("won the game"):
                    return scoreLine()
                case _ where statement.contains("one-score") || statement.contains("field goal or less") || statement.contains("nail-biter"):
                    return scoreLine() + " " + marginLine()
                case _ where statement.contains("blowout"):
                    return scoreLine() + " " + marginLine()
                case _ where statement.contains("shutout"):
                    return scoreLine() + " One side scored 0."
                case _ where statement.contains("double digits") || statement.contains("at least 20") || statement.contains("30 or more") || statement.contains("under 14") || statement.contains("10 points or fewer"):
                    return scoreLine()
                case _ where statement.contains("Total points") || statement.contains("combined for") || statement.contains("soared past"):
                    return scoreLine() + " " + totalLine()
                default:
                    return scoreLine()
                }
            }()
            let rewardsTF = [100, 150, 200, 250]
            return TriviaQuestion(
                id: UUID(),
                kind: .trueFalse,
                text: "True or False: \(statement)",
                correctAnswer: selected.1,
                choices: nil,
                correctIndex: nil,
                numericAnswer: nil,
                tolerance: nil,
                explanation: expl,
                reward: rewardsTF.randomElement() ?? 200
            )

        case .mcq:
            // Build MCQ variants
            enum MCQType { case winner, marginBucket, totalBucket }
            let mcqType = [MCQType.winner, .marginBucket, .totalBucket].randomElement()!

            switch mcqType {
            case .winner:
                let choices = ["\(game.awayTeam)", "\(game.homeTeam)", "Tie"]
                let correctIndex = homeScore == awayScore ? 2 : (homeWon ? 1 : 0)
                return TriviaQuestion(
                    id: UUID(),
                    kind: .multipleChoice,
                    text: "Who emerged with the higher score in \(game.awayTeam) @ \(game.homeTeam)?",
                    correctAnswer: nil,
                    choices: choices,
                    correctIndex: correctIndex,
                    numericAnswer: nil,
                    tolerance: nil,
                    explanation: scoreLine(),
                    reward: 300
                )

            case .marginBucket:
                let choices = ["1–3", "4–7", "8–16", "17+"]
                let bucket: Int
                switch margin {
                case 0...3: bucket = 0
                case 4...7: bucket = 1
                case 8...16: bucket = 2
                default: bucket = 3
                }
                return TriviaQuestion(
                    id: UUID(),
                    kind: .multipleChoice,
                    text: "What was the margin of victory in \(game.awayTeam) @ \(game.homeTeam)? (choose the range)",
                    correctAnswer: nil,
                    choices: choices,
                    correctIndex: bucket,
                    numericAnswer: nil,
                    tolerance: nil,
                    explanation: scoreLine() + " " + marginLine(),
                    reward: 350
                )

            case .totalBucket:
                let choices = ["Under 35", "35–49", "50–59", "60+"]
                let bucket: Int
                switch total {
                case ..<35: bucket = 0
                case 35...49: bucket = 1
                case 50...59: bucket = 2
                default: bucket = 3
                }
                return TriviaQuestion(
                    id: UUID(),
                    kind: .multipleChoice,
                    text: "What was the combined score in \(game.awayTeam) @ \(game.homeTeam)? (choose the range)",
                    correctAnswer: nil,
                    choices: choices,
                    correctIndex: bucket,
                    numericAnswer: nil,
                    tolerance: nil,
                    explanation: scoreLine() + " " + totalLine(),
                    reward: 350
                )
            }

        case .numeric:
            // Build numeric variants
            enum NumType { case totalPoints, margin }
            let numType = [NumType.totalPoints, .margin].randomElement()!

            switch numType {
            case .totalPoints:
                return TriviaQuestion(
                    id: UUID(),
                    kind: .numeric,
                    text: "How many total points were scored in \(game.awayTeam) @ \(game.homeTeam)? (exact within ±3)",
                    correctAnswer: nil,
                    choices: nil,
                    correctIndex: nil,
                    numericAnswer: total,
                    tolerance: 3,
                    explanation: scoreLine() + " " + totalLine(),
                    reward: 400
                )
            case .margin:
                return TriviaQuestion(
                    id: UUID(),
                    kind: .numeric,
                    text: "What was the margin of victory in \(game.awayTeam) @ \(game.homeTeam)? (exact within ±1)",
                    correctAnswer: nil,
                    choices: nil,
                    correctIndex: nil,
                    numericAnswer: margin,
                    tolerance: 1,
                    explanation: scoreLine() + " " + marginLine(),
                    reward: 450
                )
            }
        }
    }
}

