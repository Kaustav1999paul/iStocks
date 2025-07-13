import Foundation
import Combine

class StockSearchViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var searchResults: [StockQuote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService = APIService()

    @MainActor
    func searchStock() async {
        isLoading = true
        errorMessage = nil
        searchResults = []

        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a stock symbol or name."
            isLoading = false
            print("DEBUG: ViewModel Guard failed - empty search term.") // ADD THIS
            return
        }

        do {
            let stocks = try await apiService.searchStockByNameList(for: searchTerm)
            searchResults = stocks
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("DEBUG: ViewModel Caught NetworkError: \(networkError.localizedDescription)") // ADD THIS
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            print("DEBUG: ViewModel Caught Generic Error: \(error.localizedDescription)") // ADD THIS
        }
        
        isLoading = false
        print("DEBUG: ViewModel searchStock() end. ErrorMessage: \(errorMessage ?? "nil"), Results Count: \(searchResults.count)") // ADD THIS
    }
}
