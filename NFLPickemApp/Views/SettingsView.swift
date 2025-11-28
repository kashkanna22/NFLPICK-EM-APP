import SwiftUI

struct SettingsView: View {
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppearanceModel.system.rawValue

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
            }
            .navigationTitle("Settings")
        }
    }
}
