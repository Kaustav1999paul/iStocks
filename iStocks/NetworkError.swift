//
//  NetworkError.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//

import Foundation

// This NetworkError enum is now assumed to be in your project for better error handling
// (e.g., in a separate file like NetworkError.swift or at the top of APIService.swift)
enum NetworkError: Error, LocalizedError {
    case badURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case networkRequestFailed(Error)
    case noDataFound // For empty search results when expected
    case apiError(String) // For errors returned by the API itself (e.g., "Invalid API Key")

    var errorDescription: String? {
        switch self {
        case .badURL: return "The URL was malformed. Please check the address."
        case .invalidResponse(let statusCode): return "Received an invalid response from the server. Status code: \(statusCode)"
        case .decodingError(let error): return "Failed to process data from the server. \(error.localizedDescription)"
        case .networkRequestFailed(let error): return "Network request failed: \(error.localizedDescription)"
        case .noDataFound: return "No matching stock found for your search term."
        case .apiError(let message): return "API Error: \(message). Please check your API key or try again later."
        }
    }
}
