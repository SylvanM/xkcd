//
//  ComicDetailView.swift
//  xkcd
//
//  Created by Sylvan Martin on 11/27/25.
//

import SwiftUI
import SwiftData

typealias ComicAndImage = (ComicDetail, UIImage?)
typealias TagAndIndex = (tag: ComicTag, index: Int)

struct ComicDetailView: View {
    
    private let allTags: [ComicTag]
    
    @State private var tagAndIndex: TagAndIndex
    
    private var tag: ComicTag {
        tagAndIndex.tag
    }
    
    private var index: Int {
        tagAndIndex.index
    }
    
    private var number: Int {
        tag.number
    }
    
    @State private var comicAndImage: ComicAndImage?
    
    @State private var isLoading = false
    @State private var showAltText: Bool = false
    
//    let longPressTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
//    @State private var startTime = Date()
//    @State private var timerIsRunning = false
//    
//    let altTextHoldTime = 0.7
//    
//    
    
//    private var comic: ComicDetail? {
//        ComicManager.getComicDetail(forTag: comicTag)
//    }
    
//    @State private var shouldUpdateView = true
    
    init(_ comicTag: ComicTag) {
        let (index, allTags) = ComicManager.getTagContext(forTag: comicTag)
        
        self.allTags = allTags
        
        self._tagAndIndex = State(initialValue: (comicTag, index))
        
        if let existingComic = ComicManager.getComicDetail(forTag: comicTag) {
            _comicAndImage = State(initialValue: (existingComic, UIImage(data: existingComic.imageData)))
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let (comicDetail, possibleImage) = comicAndImage, comicDetail.number == number {
                    if let comicImage = possibleImage {
                        ZoomableComicImage(image: comicImage, imageID: self.number)
                            .sheet(isPresented: $showAltText) {
                                ScrollView {
                                    Text(comicDetail.altText)
                                        .padding()
                                }
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                            }
                            .onAppear {
                                tagAndIndex.tag.hasBeenRead = true
                            }
                    } else {
                        Text("No image available for this comic")
                    }
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showAltText = true
                    } label: {
                        Image(systemName: "pointer.arrow.motionlines")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        let newIndex = tagAndIndex.index + 1
                        let newTag = allTags[newIndex]
                        
                        self.tagAndIndex = (newTag, newIndex)
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(tagAndIndex.index >= allTags.endIndex - 1)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        let newIndex = tagAndIndex.index - 1
                        let newTag = allTags[newIndex]
                        
                        self.tagAndIndex = (newTag, newIndex)
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(tagAndIndex.index < 0)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                        let newIndex = allTags.indices.randomElement()!
                        let newTag = allTags[newIndex]
                        
                        self.tagAndIndex = (newTag, newIndex)
                    } label: {
                        Image(systemName: "shuffle")
                    }
                    .disabled(allTags.isEmpty) // should never happen if we are in this view
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let url = URL(string: "https://www.explainxkcd.com/" + String(tagAndIndex.tag.number)) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .navigationTitle(tagAndIndex.tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: number, initial: true) {
            reloadComic()
        }
    }
    
    private func reloadComic() {
        self.showAltText = false
        
        print("Reloading")
        
        if let existingComic = ComicManager.getComicDetail(forTag: tag) {
            self.comicAndImage = (existingComic, UIImage(data: existingComic.imageData))
            print("Comic exists, image updated, image is \(comicAndImage!.1)")
            return
        }
        
        Task {
            print("Entering task")
            await ComicManager.retrieve(number: tag.number) { downloadedComic in
                print("Got \(String(describing: downloadedComic))")
                guard let downloadedComic else {
                    print("No image available for comic \(tag.number)")
                    return
                }
                
                Task {
                    print("Started the whole assignment task")
                    await ComicManager.model.addComic(comic: downloadedComic)
                    print("Added the comic to the stored DB")
                    
                    // Only update the screen if the user has not already moved on.
                    guard self.number == tag.number else {
                        return
                    }
                    
                    let possibleComicDetail = ComicManager.getComicDetail(forTag: tag)
                    
                    if let comicDetail = possibleComicDetail {
                        let image = UIImage(data: comicDetail.imageData)
                        
                        print("Setting new comicAndImage")
                        self.comicAndImage = (comicDetail, image)
                    } else {
                        print("SOMETHING TERRIBLE HAPPENED")
                        return
                    }
                }
            }
        }
    }
    
}
