//
//  APIService.swift
//  iStocks
//
//  Created by Kaustav Paul on 12/07/25.
//

import Foundation

class APIService {
    private let baseURL = "https://financialmodelingprep.com/stable"
    private let apiKey = "sOe9Eo35p7rB2UhMTdvuHHBKDZRmymIT"

//    Functions to fetch searchterm data
    func searchStockByNameList(for searchTerm: String) async throws -> [StockQuote] {
        let fullUrl = "\(baseURL)/search-name?query=\(searchTerm)&apikey=\(apiKey)"
        guard let url = URL(string: fullUrl) else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
                
        // Basic HTTP response check (optional but good practice)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        do {
            // Decoding directly into an array of StockQuote
            let quotes = try JSONDecoder().decode([StockQuote].self, from: data)
                    
            // Check if the array is empty
            guard !quotes.isEmpty else {
                throw NetworkError.noDataFound
            }
                    
            return quotes // Return the entire array of found stocks
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.networkRequestFailed(error)
        }
    }
    
//    Func to fetch company profile date based on symbol
    func fetchCompanyProfile(symbol: String) async throws -> CompanyProfile {
            let fullUrl = "\(baseURL)/profile?symbol=\(symbol)&apikey=\(apiKey)"
            
            print("DEBUG: Fetching profile URL: \(fullUrl)")

            guard let url = URL(string: fullUrl) else {
                print("DEBUG: Failed to create URL for profile: \(fullUrl)")
                throw NetworkError.badURL
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                print("DEBUG: Profile fetch - Invalid HTTP Response Status Code: \(statusCode)")
                if let apiErrorMessage = String(data: data, encoding: .utf8), !apiErrorMessage.isEmpty {
                     throw NetworkError.apiError("Server responded with: \(apiErrorMessage)")
                } else {
                     throw NetworkError.invalidResponse(statusCode: statusCode)
                }
            }
            
            do {
                let profiles = try JSONDecoder().decode([CompanyProfile].self, from: data)
                
                guard let profile = profiles.first else {
                    print("DEBUG: Profile fetch - No data found in response for symbol: \(symbol)")
                    throw NetworkError.noDataFound
                }
                
                print("DEBUG: Successfully decoded profile for \(profile.companyName)")
                return profile
            } catch let decodingError as DecodingError {
                print("DEBUG: Profile fetch - DecodingError: \(decodingError)")
                throw NetworkError.decodingError(decodingError)
            } catch {
                print("DEBUG: Profile fetch - Other error: \(error)")
                throw NetworkError.networkRequestFailed(error)
            }
        }
}
