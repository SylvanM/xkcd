//
//  ComicTag.swift
//  xkcd
//
//  Created by Sylvan Martin on 10/13/25.
//

import Foundation
import SwiftData

/// The "nametag" for a comic to be shown in the table view
@Model
final class ComicTag: Comparable, Codable, CustomDebugStringConvertible, Identifiable {
    
    /// Title of the comic
    @Attribute var name: String
    
    /// The number of the comic
    @Attribute(.unique) var number: Int
    
    /// Whether or not this comic has been read yet
    @Attribute var hasBeenRead: Bool
    
    /// Whether or not this comic is saved
    var isSaved: Bool {
        let fetchDescriptor = FetchDescriptor<ComicDetail>(predicate: #Predicate { $0.number == self.number })
        do {
            if let modelContext = modelContext {
                let count = try modelContext.fetchCount(fetchDescriptor)
                if count > 1 {
                    print("Detected duplicate of \(number)")
                }
                return count > 0
            }
            return false
        } catch {
            print("Error checking item existence: \(error)")
            return false
        }
    }
    
    var debugDescription: String {
        "Comic \(number):\n\tTitle: \(name)\n\tSaved: \(isSaved)\n"
    }
    
    // MARK: Persistance
    
    private enum CodingKeys: String, CodingKey {
        case name
        case number
        case hasBeenRead
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(hasBeenRead, forKey: .hasBeenRead)
    }
    
    // MARK: Initializers
    
    init(name: String, number: Int) {
        self.name = name
        self.number = number
        self.hasBeenRead = false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int.self, forKey: .number)
        self.hasBeenRead = try container.decode(Bool.self, forKey: .hasBeenRead)
    }
    
    
    // MARK: Comparison
    
    static func < (lhs: ComicTag, rhs: ComicTag) -> Bool {
        lhs.number < rhs.number
    }
    
    static func == (lhs: ComicTag, rhs: ComicTag) -> Bool {
        lhs.number < rhs.number
    }
    
}
