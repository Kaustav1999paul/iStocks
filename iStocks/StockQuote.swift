//
//  StockQuote.swift
//  iStocks
//
//  Created by Kaustav Paul on 12/07/25.
//

import Foundation

struct StockQuote: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let symbol: String
    let name: String
    let currency: String
    let exchange: String
    let exchangeFullName: String

    private enum CodingKeys: String, CodingKey {
        case symbol, name, currency, exchange, exchangeFullName
    }
}
