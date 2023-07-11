//
//  FeedModel.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import Foundation
import UIKit


// MARK: - Welcome
struct Welcome: Codable {
    let search: [Search]
    let totalResults, response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}

// MARK: - Search
class Search: Codable {
    var title = ""
    var year = ""
    var imdbID = ""
    var poster: String = ""
    var date: Date = Date()
    var imageData = Data()
    var downloadedImage: UIImage? = nil

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID = "imdbID"
        case poster = "Poster"
        
    }
}

