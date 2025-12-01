//
//  AppApperanceView.swift
//  NFLPickemApp
//
//  Created by Kashyap Kannajyosula on 11/30/25.
//
import SwiftUI

public enum AppearanceModel: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AppAppearanceView: View {
    let appState: AppState

    var body: some View {
        Rectangle()
            .fill(Color(.systemBackground))
            .overlay(
                Color.clear.background(.ultraThinMaterial)
            )
    }
}

#Preview {
    AppAppearanceView(appState: AppState())
}
