//
//  Comic.swift
//  xkcd
//
//  Created by Sylvan Martin on 10/9/25.
//

import SwiftUI
import SwiftData

/// The extended detail of an XKCD comic.
///
/// This does *not* include the title, because that is stored in the tag. The number is only used
/// to match the detail with the tag. This stores:
///     - The `altText` of the comic, and
///     - the `imageData` of the comic.
///
/// **TODO:** Also include the date of publication
@Model
class ComicDetail: Codable {
    
    // MARK: Properties
    
    /// The comic number
    @Attribute(.unique) var number: Int
    
    /// The alt-text
    var altText: String
    
    /// The image data of the comic
    var imageData: Data
    
    // MARK: Enums
    
    private enum CodingKeys: String, CodingKey {
        case number
        case name
        case altText
        case imageData
    }
    
    // MARK: Initializers
    
    /// Creates an xkcd comic
    init(number: Int, name: String, altText: String, imageData: Data) {
        self.number = number
        self.altText = altText
        self.imageData = imageData
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = try container.decode(Int.self, forKey: .number)
        self.altText = try container.decode(String.self, forKey: .altText)
        self.imageData = try container.decode(Data.self, forKey: .imageData)
    }

    // MARK: Utilits
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(altText, forKey: .altText)
        try container.encode(imageData, forKey: .imageData)
    }
    
}
