//
//  CompanyProfile.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//

import Foundation

// Struct to decode the Company Profile API response
struct CompanyProfile: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let symbol: String
    let price: Double? // Price can be nil sometimes
    let marketCap: Double? // MarketCap can be nil
    let beta: Double?
    let lastDividend: Double?
    let range: String? // e.g., "142.66-208.7"
    let change: Double?
    let changePercentage: Double?
    let volume: Double? // FMP response sometimes shows as Double, sometimes Int
    let averageVolume: Double?
    let companyName: String
    let currency: String?
    let exchangeFullName: String?
    let exchange: String?
    let industry: String?
    let website: String?
    let description: String?
    let ceo: String?
    let sector: String?
    let country: String?
    let fullTimeEmployees: String? // FMP provides this as a String
    let phone: String?
    let address: String?
    let city: String?
    let state: String?
    let zip: String?
    let image: String? // URL to the company logo
    let ipoDate: String? // e.g., "2004-08-19"
    let isEtf: Bool?
    let isActivelyTrading: Bool?
    let isAdr: Bool?
    let isFund: Bool?

    // If any JSON key names differ from your struct property names,
    // you'd add a CodingKeys enum here. For now, assuming direct mapping.
    // However, it's good practice to always include CodingKeys for explicit mapping.
    private enum CodingKeys: String, CodingKey {
        case symbol, price, marketCap, beta, lastDividend, range, change, changePercentage, volume, averageVolume, companyName, currency, exchangeFullName, exchange, industry, website, description, ceo, sector, country, fullTimeEmployees, phone, address, city, state, zip, image, ipoDate, isEtf, isActivelyTrading, isAdr, isFund
    }
}
