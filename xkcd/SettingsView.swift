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
                    PreferUnreadOptionView()
                    SearchBarPositionOptionView(searchBarOnTop: $searchBarOnTop)
                    DownloadOnViewOption()
                    
                    Button {
                        print("Download Every Single Comic")
                    } label: {
                        Text("Download All Comics")
                    }
                    Button {
                        Settings.writeDefaults(overwritingUserSettings: true)
                    } label: {
                        Text("Reset to Default Settings")
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct PreferUnreadOptionView: View {
    @State var preferUnread: Bool = Settings.preferUnread
    
    var body: some View {
        Toggle("Shuffle to Unread Comic", isOn: $preferUnread)
            .onChange(of: preferUnread) { _, newValue in
                Settings.preferUnread = newValue
            }
    }
}

struct SearchBarPositionOptionView: View {
    @Binding var searchBarOnTop: Bool
    
    var body: some View {
        Toggle("Search bar on top", isOn: $searchBarOnTop)
            .onChange(of: searchBarOnTop) { _, newValue in
                Settings.searchBarOnTop = newValue
            }
    }
}

struct DownloadOnViewOption: View {
    @State var downloadOnView: Bool = Settings.downloadOnView
    
    var body: some View {
        Toggle("Download on View", isOn: $downloadOnView)
            .onChange(of: downloadOnView) { _, newValue in
                Settings.downloadOnView = newValue
            }
    }
}
