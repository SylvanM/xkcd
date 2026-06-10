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
    
    // MARK: Methods
    
    // Call this function right after the ModelContainer is ready
    func initializeActor(container: ModelContainer) {
        self.container = container
        // Instantiate the actor in a detached Task at startup
        Task.detached {
            self.backgroundModelActor = BackgroundModelActor(modelContainer: container)
            print("BackgroundDataActor initialized at app startup.")
        }
    }
    
    /// Saves all new unseen tags
    class func refresh(reportTotal: ((Int) -> ())? = nil, addOne: (() -> ())? = nil, completion: (() -> ())? = nil, errorCompletion: (() -> ())? = nil) async {
        await getUnseenTags { tagFetchResult in
            switch tagFetchResult {
            case .success(let numbers):
                
                reportTotal?(numbers.count)
                
                do {
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
                } catch {
                    print("Error on creating model context: \(error)")
                    errorCompletion?()
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
                        let imageURL = URL(string: imagePath)!
                        
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
    
}
