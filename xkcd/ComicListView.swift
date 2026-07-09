//
//  ComicListView.swift
//  xkcd
//
//  Created by Sylvan Martin on 10/9/25.
//

import SwiftUI
import SwiftData

struct ComicListView: View {
    
    @Query(sort: \ComicTag.number, order: .reverse) private var allComicTags: [ComicTag]
    
    @State private var searchText: String = ""
    @State private var searchBarOnTop: Bool = Settings[.searchBarOnTop]
    
    var body: some View {
        NavigationSplitView {
            ScrollViewReader { proxy in
                List(allComicTags) { comicTag in
                    NavigationLink(value: comicTag) { // What does value: comicTag do?
                        HStack {
                            if !comicTag.hasBeenRead {
                                Label("read_indicator", systemImage: "circle.fill")
                                    .imageScale(.small)
                                    .font(.system(size: 10))
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.blue)
                            }
                            Text("\(comicTag.number). \(comicTag.name)")
                            Spacer()
                            if comicTag.isSaved {
                                Label("is_saved", systemImage: "arrow.down.circle.fill")
                                    .imageScale(.small)
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.gray)
                                    .disabled(!comicTag.isSaved)
                            }
                        }
                    }
                    .id(comicTag.number)
                }
                .refreshable {
                    await ComicManager.refresh { totalToDownload in
    //                    total = Double(totalToDownload)
                    } addOne: {
                        // Nothing
                    } completion: {
                        // Just be done?
                    }
                }
                .navigationTitle("xkcd")
                .navigationDestination(for: ComicTag.self) { tag in
                    ComicDetailView(tag)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView(searchBarOnTop: $searchBarOnTop)) {
                            Image(systemName: "gearshape")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let url = URL(string: "https://xkcd.com/license.html") {
                               UIApplication.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Menu {
                                Button {
                                    let oldestUnread = ComicManager.getOldestUnread()!
                                    
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        proxy.scrollTo(oldestUnread.number, anchor: .center)
                                    }
                                } label: {
                                    Text("Oldest Unread")
                                    Image(systemName: "clock.badge")
                                }.disabled(allComicTags.allSatisfy { $0.hasBeenRead } )
                                
                                Button {
                                    let randomTag = allComicTags.randomElement()!
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        proxy.scrollTo(randomTag.number, anchor: .center)
                                    }
                                } label: {
                                    Text("Random")
                                    Image(systemName: "die.face.3")
                                }.disabled(allComicTags.isEmpty)
                            } label: {
                                Text("Jump to")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .searchable(text: $searchText, placement: .automatic)
            }
        } detail: {
            Text("Huh?")
        }
    }
}

#Preview {
    ComicListView()
        .modelContainer(for: ComicTag.self, inMemory: true)
}
