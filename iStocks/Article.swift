//
//  Article.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//

import Foundation

struct Article: Identifiable, Codable {
    // FMP does not provide a unique ID in the article response directly,
    // so we'll use UUID for Identifiable conformance required by ForEach in SwiftUI.
    let id = UUID()

    let title: String
    let date: String
    let content: String // Note: This contains HTML, you'll need to handle it if displaying
    let tickers: String? // Optional, as it might not always be present or relevant
    let image: String? // URL string for the image
    let link: String? // URL string for the full article
    let author: String?
    let site: String?

    // Add CodingKeys if your property names differ from JSON keys, or if you want to be explicit.
    // In this case, they largely match, so you might not strictly need them, but it's good practice.
    enum CodingKeys: String, CodingKey {
        case title, date, content, tickers, image, link, author, site
    }
}
