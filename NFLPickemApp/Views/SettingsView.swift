import SwiftUI

struct SettingsView: View {
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppearanceModel.system.rawValue
    @State var appState = AppState()

    private var appAppearance: AppearanceModel {
        get { AppearanceModel(rawValue: appAppearanceRaw) ?? .system }
        set { appAppearanceRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Mode", selection: $appAppearanceRaw) {
                        ForEach(AppearanceModel.allCases) { appearance in
                            Text(appearance.displayName).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Bankroll")) {
                    Button("Reset Bankroll", role: .destructive) {
                        appState.coins = 10_000
                    }
                    Text("Current coins: \(appState.coins)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
