# NFL Pick’em (SwiftUI)

[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](#)
[![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue.svg)](#)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-lightgrey.svg)](#)

A SwiftUI app for making NFL game picks with a virtual coin bankroll, plus a trivia mode powered by recent game results. Track your record, visualize performance, and manage your bets with an easy, clean UI.

- Live/Upcoming/Final game grouping
- Pre-game betting with edit/cancel
- Auto-settlement on finished games
- Bankroll tracking and stats with charts
- Trivia mode (free daily + paid sessions)
- Branded splash overlay with app icon

## Table of Contents
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Key Files](#key-files)
- [Data Flow](#data-flow)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage Tips](#usage-tips)
- [Extending the App](#extending-the-app)
- [Accessibility](#accessibility)
- [License](#license)

## Features
- NFL game list grouped by status: Live, Upcoming, Final
- Weekly navigation with playoff week names (Wildcard, Divisional, Conference Championship, Super Bowl)
- Place, edit, and cancel bets pre-game; automatic settlement after games finish
- Virtual coins with starting bankroll of 10,000; global coin pill updates live
- Trivia mode with free (daily) or paid sessions, rewards/penalties, and a leave-session confirmation
- Profile view with performance charts, win/loss breakdown, and bet history
- Settings for appearance (System/Light/Dark) and resetting bankroll
- Branded splash overlay with app icon while syncing games on first launch

## Screenshots
Add screenshots here:
- Picks (Live/Upcoming/Final)
- Place Bet / Edit Bet
- Profile (charts, history)
- Trivia (questions, strikes)
- Settings (appearance, reset)

## Architecture
- SwiftUI with the Observation framework (`@Observable`, `@Bindable`) for app state and view models
- Single shared `AppState` instance manages coins and bets; passed to `GameViewModel` and across tabs via `RootTabView`
- `NFLAPIService` (actor) fetches data from ESPN endpoints and normalizes statuses to a consistent schema
- Views read from `GameViewModel` and `AppState` and write updates through intent methods (place/edit/cancel/settle)

## Key Files
- `NFLPickemApp.swift`: App entry point
- `RootTabView.swift`: Main tabs (Picks/Trivia/Profile/Settings), global coin pill, splash overlay, trivia leave guard
- `GameViewModel.swift`: Fetches games, manages selected week, triggers bet settlement, playoff week labels
- `BetViewModel.swift` (AppState): Coins, bets, persistence, and bet lifecycle (place/edit/cancel/settle) + stats
- `PicksView.swift`: Betting UI with grouped games, instructions, stake input (numeric + +/-/Max), and week picker
- `ProfileView.swift`: Bankroll, record, win rate, Bets Net and Total Net (incl. trivia), charts, and history rows
- `TriviaViewModel.swift`: Trivia session state, rewards/penalties, and active-session flag for leave guard
- `TriviaView.swift`: Trivia UI, answers, explanations, and instructions
- `NFLAPIService.swift`: Actor-backed ESPN networking
- `ESPNModel.swift`: Codable ESPN response models and status normalization
- `GameModel.swift`: Core `Game` type used throughout

## Data Flow
1. `RootTabView` constructs a single `AppState` and passes it to a single `GameViewModel`.
2. `PicksView` uses `GameViewModel` to show games and `AppState` to place/edit/cancel bets.
3. After fetching games, `GameViewModel` calls `appState.settleBets(with:)` to auto-payout.
4. `ProfileView` reads from `AppState` to compute stats and render charts.
5. `TriviaViewModel` adjusts `AppState.coins` for rewards/penalties and sets an `np_trivia_active` flag for navigation guard.

## Getting Started
- Requirements: Xcode 15+ (Swift 5.9+) and internet access for ESPN endpoints.
- Clone and open the project in Xcode.
- Build & run on iOS simulator or device.

## Configuration
- App Icon:
  - In Assets.xcassets, create an AppIcon set and add your icon images.
  - In target settings > General, set “App Icons Source” to AppIcon.
- Optional splash/logo overlay:
  - Add your logo image asset (e.g., “NFL Pick'Em Game Icon”) for the first-load overlay in `RootTabView`.

## Usage Tips
- Place bets on upcoming games; edit/cancel while still pre-game.
- Stake any amount up to your current coins using the numeric field or quick +/-/Max buttons.
- Use the week picker to jump across weeks; playoff weeks display readable names.
- Start a free trivia session daily or play paid sessions anytime.
- Check the Profile tab to view your record, win rate, and profit charts.

## Extending the App
- ESPN date parsing: Implement `parseESPNDate(_:)` in `NFLAPIService` to show accurate times.
- Stake “chips”: Add 100/250/500/1000 buttons alongside +/- and Max.
- Haptics: Add light haptics for place/edit/cancel bet and trivia answer feedback.
- Favorites: Filter Picks to show a Favorites section using `favoriteTeamId`.
- Deeper stats: Add ROI, average stake, average payout, and streaks.

## Accessibility
- Dynamic type-friendly text where possible
- Accessibility labels on key controls (coin pill, instructions buttons)
