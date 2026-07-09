//
//  SettingsView.swift
//  xkcd
//
//  Created by Sylvan Lee Martin on 6/28/26.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var searchBarOnTop: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        ForEach(Settings.SettingKey.allCases) { settingKey in
                            SettingItemView(key: settingKey)
                        }
                    }
                    
                    Section {
                        Button(role: .confirm) {
                            print("Download Every Single Comic")
                        } label: {
                            Text("Download All Comics")
                        }
                        Button(role: .destructive) {
                            Settings.writeDefaults(overwritingUserSettings: true)
                        } label: {
                            Text("Reset to Default Settings")
                        }
                    }
                }
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
        VStack {
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
