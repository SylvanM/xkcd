//
//  SettingsView.swift
//  xkcd
//
//  Created by Sylvan Lee Martin on 6/28/26.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(Settings.SettingKey.allCases) { settingKey in
                        SettingItemView(key: settingKey)
                    }
                }
                Button("Download All Comics") {
                    print("Download Every Single Comic")
                }
                .buttonStyle(.bordered)

                Button("Reset to Default Settings", role: .destructive) {
                    withAnimation {
                        Settings.writeDefaults(overwritingUserSettings: true)
                    }
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingItemView: View {
    
    private let key: Settings.SettingKey
    
    @State var settingToggle: Bool
    
    init(key: Settings.SettingKey) {
        self.key = key
        self._settingToggle = State(initialValue: Settings[key])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(Settings.title(forSetting: key), isOn: $settingToggle)
                .onChange(of: settingToggle) { _, newValue in
                    Settings[key] = newValue
                }
            Text(Settings.description(forSetting: key))
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }
}
