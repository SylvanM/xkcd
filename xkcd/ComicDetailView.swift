//
//  ComicDetailView.swift
//  xkcd
//
//  Created by Sylvan Martin on 11/27/25.
//

import SwiftUI
import SwiftData

struct ComicDetailView: View {
    
    @Query private var matchingComics: [ComicDetail]
    @State private var showAltText: Bool = false
    
    @State private var comicTag: ComicTag
    
    private var comic: ComicDetail? {
        matchingComics.first
    }
    
    init(_ comicTag: ComicTag) {
    
        self.comicTag = comicTag
        self.comicTag.hasBeenRead = true
        
        _matchingComics = Query(
            filter: #Predicate<ComicDetail> { $0.number == comicTag.number }
        )
        
        // By default, comics are saved permanently.
        Task {
            await ComicManager.retrieve(number: comicTag.number) { comic in
                if let comic = comic {
                    ComicManager.model.addComic(comic: comic)
                    print("Comic \(comicTag.number) downloaded")
                } else {
                    print("No image available for comic \(comicTag.number)")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let comicDetail = comic {
                    ZoomableComicImageView(image: UIImage(data: comicDetail.imageData)!)
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                HStack { // Use HStack for multiple trailing items
                                    Button {
                                        showAltText = true
                                    } label: {
                                        Image(systemName: "pointer.arrow.motionlines")
                                    }
                                    
                                    Button {
                                        print("Going up")
                                    } label: {
                                        Image(systemName: "chevron.up")
                                    }
                                    
                                    Button {
                                        print("Going down")
                                    } label: {
                                        Image(systemName: "chevron.down")
                                    }
                                    
                                    Button {
                                        print("Going to random comic")
                                    } label: {
                                        Image(systemName: "shuffle")
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $showAltText) {
                            ScrollView {
                                Text(comicDetail.altText)
                                    .padding()
                            }
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                        }
                } else {
                    ProgressView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let url = URL(string: "https://www.explainxkcd.com/" + String(comicTag.number)) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .navigationTitle(comicTag.name)
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
