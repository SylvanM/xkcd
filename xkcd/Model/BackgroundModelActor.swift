//
//  BackgroundModelActor.swift
//  xkcd
//
//  Created by Sylvan Martin on 11/27/25.
//

import SwiftData
import Foundation

@ModelActor
actor BackgroundModelActor {
    
    // MARK: Properties
    
    private var context: ModelContext { modelExecutor.modelContext }
    
    // MARK: Methods
    
    func getLatestComicNumber() -> Int {
        do {
            
            var latestSavedComics = FetchDescriptor<ComicTag>(
                sortBy: [
                    .init(\.number, order: .reverse),
                ]
            )

            latestSavedComics.fetchLimit = 1
            latestSavedComics.includePendingChanges = true

            let results = try context.fetch(latestSavedComics)
            
            if let tag = results.first {
                return tag.number
            } else {
                return 0
            }
        
        } catch {
            fatalError("Couldn't get latest comic: \(error)")
        }
        
    }
    
    func getAllTags(onlyIfUnread: Bool = false) -> [ComicTag] {
        do {
            let descriptor = FetchDescriptor<ComicTag>(predicate: #Predicate { tag in
                if onlyIfUnread {
                    !tag.hasBeenRead
                } else {
                    true
                }
            }, sortBy: [
                .init(\.number)
            ].reversed() )
            
            
            let allTags = try context.fetch(descriptor)
            return allTags
        } catch {
            print("Error fetching all tags: \(error)")
            return []
        }
    }
    
    
    /// Out of the tags that we know exist, retrieve the one that comes next, if such a comic exists.
    func getTag(after tag: ComicTag) -> ComicTag? {
        let allTags = getAllTags()
        let tagIndex = allTags.firstIndex { otherTag in
            otherTag.number == tag.number
        }!
        
        if tagIndex == allTags.endIndex - 1 {
            return nil
        } else {
            return allTags[tagIndex + 1]
        }
    }
    
    /// Out of the tags that we know exist, retrieve the one that comes before this one, if such a comic exists.
    func getTag(before tag: ComicTag) -> ComicTag? {
        let allTags = getAllTags()
        let tagIndex = allTags.firstIndex { otherTag in
            otherTag.number == tag.number
        }!
        
        if tagIndex == 0 {
            return nil
        } else {
            return allTags[tagIndex - 1]
        }
    }
    
    func getTagContext(forTag tag: ComicTag) -> (index: Int, allTags: [ComicTag]) {
        let allTags = getAllTags()
        let tagIndex = allTags.firstIndex { otherTag in
            otherTag.number == tag.number
        }!
        return (tagIndex, allTags)
    }
    
    func getTag(forNumber number: Int) -> ComicTag {
        let allTags = getAllTags()
        let tagIndex = allTags.firstIndex { otherTag in
            otherTag.number == number
        }!
        
        return allTags[tagIndex]
    }
    
    /// Retrieves a particular comic detail
    func getComicDetail(forTag tag: ComicTag) -> ComicDetail? {
        let descriptor = FetchDescriptor<ComicDetail>(predicate: #Predicate { $0.number == tag.number } )
        return (try? context.fetch(descriptor))?.first
    }
    
    /// Returns a random Comic Tag. If `preferUnread` is true, it will return an random unread comic before
    /// it returns a read one.
    func getRandomTag(preferUnread: Bool) -> ComicTag {
        if preferUnread {
            let allUnread = getAllTags(onlyIfUnread: true)
            
            if allUnread.isEmpty {
                return getRandomTag(preferUnread: false)
            } else {
                return allUnread.randomElement()!
            }
        } else {
            let allTags = getAllTags()
            
            return allTags.randomElement()!
        }
    }
    
    func getMissingTags() -> [Int] {
        do {
            
            let descriptor = FetchDescriptor<ComicTag>()
            let locations = try context.fetch(descriptor)
            
            let savedNumbers = locations.map { $0.number }
            
            let latestComicNumber = getLatestComicNumber()
            
            if latestComicNumber == 0 {
                return []
            } else {
                // inefficient, but whatever
                let missedNumbers = Array(1...latestComicNumber).filter { !savedNumbers.contains($0) }
                
                return missedNumbers
            }
            
        } catch {
            fatalError("Couldn't get latest comic: \(error)")
        }
    }
        
    func addTag(tag: ComicTag) {
        context.insert(tag)
        do {
            try context.save()
        } catch {
            fatalError("[Model Actor] Could not save tag: \(error)")
        }
    }
    
    func addComic(comic: ComicDetail) {
        context.insert(comic)
        do {
            try context.save()
        } catch {
            fatalError("[Model Actor] Could not save comic: \(error)")
        }
    }
    
    func getOldestUnread() -> ComicTag? {
        getAllTags(onlyIfUnread: true).first
    }
    
}
