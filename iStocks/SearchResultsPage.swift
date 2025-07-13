//
//  SearchResultsPage.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//

import Swift

import SwiftUI

struct SearchResultsPage: View {
    // 1. Receive the search results from the previous view
    let searchResults: [StockQuote]
    
    // 2. We'll also need to be able to dismiss this page, if it's presented modally.
    // For NavigationLink, you navigate back automatically.
    // But if you wanted to pass a custom action for more complex dismissal,
    // you might use @Environment(\.dismiss) var dismiss

    var body: some View {
        // Use a List to display the results
        List {
            // Check if results are empty, though it should ideally be handled
            // before navigating to this page (e.g., in the ViewModel logic)
            if searchResults.isEmpty {
                Text("No stocks found for your search")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                // Iterate over the results and display each stock
                ForEach(searchResults) { stock in
                    // In a real app, you'd likely use NavigationLink here
                    // to go to a StockDetailPage, passing the selected stock.
                    NavigationLink(destination: StockDetailPage(stock: stock)) {
                        StockSearchResultRow(stock: stock)
                    }
                }
            }
        }
        .navigationTitle("Top Searches") // Title for this page
        .navigationBarTitleDisplayMode(.inline) // Compact title
    }
}

// Re-using the StockSearchResultRow view for consistency
// Ensure this struct is also defined in your project (can be in its own file
// or below SearchResultsPage if you prefer, but usually in a separate file for reuse).
struct StockSearchResultRow: View {
    let stock: StockQuote

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.name)
                    .font(.headline)
                Text(stock.symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(stock.exchangeFullName).font(.caption)
                Text(stock.currency).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
}


// MARK: - Preview Provider
struct SearchResultsPage_Previews: PreviewProvider {
    static var previews: some View {
        // Example data for preview
        let exampleStocks =
        [
            StockQuote(symbol: "AAPL", name: "Apple Inc.", currency: "USD", exchange: "NASDAQ", exchangeFullName: "NASDAQ Stock Exchange"),
            StockQuote(symbol: "GOOG", name: "Alphabet Inc.", currency: "USD", exchange: "NASDAQ", exchangeFullName: "NASDAQ Stock Exchange")
        ]
        
        // Wrap in NavigationStack for previewing navigation
        NavigationStack {
            SearchResultsPage(searchResults: exampleStocks)
        }
    }
}
