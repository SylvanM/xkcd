//
//  ComicDetailView.swift
//  xkcd
//
//  Created by Sylvan Martin on 11/27/25.
//

import SwiftUI
import SwiftData
internal import Combine

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
                if let (comicDetail, possibleImage) = comicAndImage {
                    if let comicImage = possibleImage {
                        Image(uiImage: comicImage)
//                        ZoomableComicImageView(image: comicImage)
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
                                        
                                        reloadComic()
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
                                        
                                        reloadComic()
                                    } label: {
                                        Image(systemName: "chevron.down")
                                    }
                                    .disabled(tagAndIndex.index < 0)
                                }
                                ToolbarItem(placement: .bottomBar) {
                                    Button {
//                                        
//                                        
//                                        
//                                        let randomNumber = ComicManager.getRandomTag(preferUnread: preferUnread).number
//                                        self.number = randomNumber
                                    } label: {
                                        Image(systemName: "shuffle")
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
//                            .onLongPressGesture(minimumDuration: 1, maximumDistance: 5) {
//                                // Do nothing I guess?
//                            } onPressingChanged: { isPressed in
//                                if !timerIsRunning && isPressed {
//                                    timerIsRunning = true
//                                    startTime = Date()
//                                }
//                            }
//                            .onReceive(longPressTimer) { _ in
//                                if timerIsRunning {
//                                    let elapsed = Date().timeIntervalSince(self.startTime)
//                                    
//                                    if elapsed > altTextHoldTime {
//                                        timerIsRunning = false
//                                        showAltText = true
//                                    }
//                                }
//                            }
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
//        .task(id: number) {
//            print("Number updated to \(number)")
//            await loadComic(number)
//        }
    }
    
    private func reloadComic() {
        self.showAltText = false
        
        print("Reloading")
        
        if let existingComic = ComicManager.getComicDetail(forTag: tag) {
            self.comicAndImage = (existingComic, UIImage(data: existingComic.imageData))
            print("Comic exists, image updated")
            return
        }
        
        Task {
            await ComicManager.retrieve(number: tag.number) { downloadedComic in
                guard let downloadedComic else {
                    print("No image available for comic \(tag.number)")
                    return
                }
                
                Task {
                    await ComicManager.model.addComic(comic: downloadedComic)
                    
                    // Only update the screen if the user has not already moved on.
                    guard self.number == tag.number else {
                        return
                    }
                    
                    let possibleComicDetail = ComicManager.getComicDetail(forTag: tag)
                    
                    if let comicDetail = possibleComicDetail {
                        let image = UIImage(data: comicDetail.imageData)
                        
                        self.comicAndImage = (comicDetail, image)
                    } else {
                        fatalError("Something terrible happened")
                    }
                }
            }
        }
    }
    
}
