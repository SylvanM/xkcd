//
//  xkcdApp.swift
//  xkcd
//
//  Created by Sylvan Martin on 10/9/25.
//

import SwiftUI
import SwiftData

@main
struct xkcdApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ComicTag.self,
            ComicDetail.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        ComicManager.shared.initializeActor(container: self.sharedModelContainer)
    }
    
    var body: some Scene {
        WindowGroup {
            ComicListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
