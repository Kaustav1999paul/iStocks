//
//  StockQuote.swift
//  iStocks
//
//  Created by Kaustav Paul on 12/07/25.
//

import Foundation

struct StockQuote: Codable, Identifiable, Equatable, Hashable {
    let id = UUID() // Always generate locally for Identifiable
    let symbol: String
    let name: String
    let currency: String
    let exchange: String
    let exchangeFullName: String

    // Explicitly define CodingKeys to exclude 'id' from decoding
    // All other properties that match JSON keys will be automatically decoded.
    private enum CodingKeys: String, CodingKey {
        case symbol, name, currency, exchange, exchangeFullName
        // Do NOT list 'id' here, so Codable ignores it during decoding.
    }
}
