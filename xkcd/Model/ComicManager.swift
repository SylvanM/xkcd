//
//  ComicManager.swift
//  xkcd
//
//  Created by Sylvan Martin on 10/9/25.
//

import Foundation
import SwiftUI
import SwiftData

class ComicManager {

    // MARK: Errors
    
    enum ComicFetchResult: Error {
        case success([Int])
        case unableToFetch
        case malformedResponse(String)
    }
    
    // MARK: Properties
    
    static let shared = ComicManager()
    static var model: BackgroundModelActor {
        shared.backgroundModelActor!
    }
    
    private var backgroundModelActor: BackgroundModelActor?
    private var container: ModelContainer?
    
    static let xkcdURL = URL(string: "https://xkcd.com/")!
    static let requestSuffix = "info.0.json"
    
    static var witnessedComicsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("witnessed.plist")
    }
    
    // MARK: Initializers
    
    private init() {
        // Just to create a singleton instance
    }
    
    
    
    // Call this function right after the ModelContainer is ready
    func initializeActor(container: ModelContainer) {
        self.container = container
        // Instantiate the actor in a detached Task at startup
        Task { @MainActor in
            self.backgroundModelActor = BackgroundModelActor(modelContainer: container)
            print("BackgroundDataActor initialized at app startup.")
        }
    }
    
    // MARK: Server Methods
    
    /// Saves all new unseen tags
    class func refresh(reportTotal: ((Int) -> ())? = nil, addOne: (() -> ())? = nil, completion: (() -> ())? = nil, errorCompletion: (() -> ())? = nil) async {
        await getUnseenTags { tagFetchResult in
            switch tagFetchResult {
            case .success(let numbers):
                
                reportTotal?(numbers.count)
                
                print("Downloading \(numbers)")
                
                let group = DispatchGroup()
                
                let tasks = numbers.map { number in
                    ComicManager.downloadTagTask(number: number) {
                        addOne?()
                        group.leave()
                    }
                }
                
                for task in tasks {
                    group.enter()
                    task.resume()
                }
                
                group.notify(queue: .main) {
                    print("Queue is done")
                    completion?()
                }
                
            case .unableToFetch:
                print("Unable to talk to server")
            case .malformedResponse(let string):
                print("Malformed response: \(string)")
            }
        }
    }
    
    /// Returns a list of numbers to record tags for
    class func getUnseenTags(completion: @escaping (ComicFetchResult) -> ()) async {
        
        let requestURL = xkcdURL.appendingPathComponent(requestSuffix)
        
        let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let data = data {
                
                do {
                    let comicInfo = try JSONSerialization.jsonObject(with: data) as! [String : Any]
                    
                    if let number = comicInfo["num"] as? Int {
                        
                        print("Latest comic is \(number)")
                        
                        // We have the newest number, what was the most recent number we recorded? We should
                        // download all new comics that we haven't seen yet.
                        
                        var toDownload = model.getMissingTags()
                        
                        print("missing tags:")
                        print(toDownload)
                        
                        let lastNumber = model.getLatestComicNumber()
                        
                        if lastNumber < number {
                            toDownload.append(contentsOf: Array((lastNumber + 1)...number))
                        }
                        
                        completion(.success(toDownload))
                        
                    } else {
                        completion(.malformedResponse(String(data: data, encoding: .utf8)!))
                    }
                } catch {
                    completion(.malformedResponse(String(data: data, encoding: .utf8)!))
                }
                
            } else {
                completion(.unableToFetch)
            }
        }
        
        task.resume()
        
    }
    
    class func downloadTagTask(number: Int, completion: @escaping () -> ()) -> URLSessionDataTask {
        let url = xkcdURL.appendingPathComponent(String(number)).appendingPathComponent(requestSuffix)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // There is a special joke that comic 404 returns a 404 error. We have to handle it differently because of this!
            if number == 404 {
                // Do not save any tags!
                completion()
            } else if let data = data {
                do {
                    let comicInfo = try JSONSerialization.jsonObject(with: data) as! [String : Any]
                    
                    if let name = comicInfo["title"] as? String {
                        let tag = ComicTag(name: name, number: number)
//                        modelContext.insert(tag)
                        ComicManager.shared.backgroundModelActor?.addTag(tag: tag)
                        completion()
                    } else {
                        print("Couldn't find title when trying to download the tag!")
                        completion()
                    }
                    
                } catch {
                    print("Error occurred when readong JSON: \(error)")
                    print("Downloaded JSON string was: \(String(describing: String(data: data, encoding: .utf8)))")
                }
            } else {
                print("Something terrible happened.")
            }
        }
        
        return task

    }
    
    class func retrieve(number: Int, completion: @escaping (ComicDetail?) -> ()) async {
        let url = xkcdURL.appendingPathComponent(String(number)).appendingPathComponent(requestSuffix)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let comicInfo = try JSONSerialization.jsonObject(with: data) as! [String : Any]
                    
                    if let imagePath = comicInfo["img"] as? String {
                        
                        // The images that come from the default path are pretty low-res, and not nice to look at.
                        // However, xkcd stores higher-res versions for normal website viewing, with a '_2x'
                        // appended after the image name. That's what we want!
                        var imagePath2x = imagePath
                        imagePath2x = imagePath2x.replacingOccurrences(of: ".png", with: "_2x.png")
                        
                        let imageURL = URL(string: imagePath2x)!
                        
                        let imageTask = URLSession.shared.dataTask(with: imageURL) { imageData, _, _ in
                            if let imageData = imageData {
                                
                                let comic = ComicDetail(
                                    number: comicInfo["num"] as! Int,
                                    name: comicInfo["title"] as! String,
                                    altText: comicInfo["alt"] as! String,
                                    imageData: imageData
                                )
                                
                                completion(comic)
                            }
                        }
                        
                        imageTask.resume()
                    } else {
                        
                        // no image for this comic! Maybe it's one of those special ones,
                        // in which case we only store the tag.
                        
                        completion(nil)
                        
                    }
                    
                    
                } catch {
                    print("Some error happened \(error)")
                }
            } else {
                print("Something terrible happened.")
            }
        }
        task.resume()
    }
    
    class func downloadAllComics(estimatedTotalAmount: @escaping (Int) -> (), progressUpdated: @escaping (Int, Int) -> (), completion: @escaping () -> (), errorCompletion: @escaping () -> ()) async {
        
//        await refresh {  in
//            <#code#>
//        } completion: {
//            <#code#>
//        } errorCompletion: {
//            <#code#>
//        }

    }
    
    // MARK: Local Pass-through Methods
    
    
    class func getTag(after tag: ComicTag) -> ComicTag? {
        ComicManager.shared.backgroundModelActor!.getTag(after: tag)
    }
    
    class func getTag(before tag: ComicTag) -> ComicTag? {
        ComicManager.shared.backgroundModelActor!.getTag(before: tag)
    }
    
    class func getRandomTag(preferUnread: Bool) -> ComicTag {
        ComicManager.shared.backgroundModelActor!.getRandomTag(preferUnread: preferUnread)
    }
    
    class func getComicDetail(forTag tag: ComicTag) -> ComicDetail? {
        ComicManager.shared.backgroundModelActor!.getComicDetail(forTag: tag)
    }
    
    class func getTag(forNumber number: Int) -> ComicTag {
        ComicManager.shared.backgroundModelActor!.getTag(forNumber: number)
    }
    
    class func getTagContext(forTag tag: ComicTag) -> (index: Int, allTags: [ComicTag]) {
        ComicManager.shared.backgroundModelActor!.getTagContext(forTag: tag)
    }

    /// Returns the oldest unread comic, or `nil` if all are read
    class func getOldestUnread() -> ComicTag? {
        ComicManager.shared.backgroundModelActor!.getOldestUnread()
    }
}
