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
    
}
