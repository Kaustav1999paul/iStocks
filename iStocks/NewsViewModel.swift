//
//  NewsViewModel.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//
import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService = APIService() // Assuming APIService is correctly initialized

    init() {}

    @MainActor
    func fetchArticles() async {
        // Only set isLoading to true if not already loading.
        // This prevents multiple simultaneous fetches if refresh is pulled repeatedly.
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil // Clear any previous error
        // articles = [] // Consider whether you want to clear articles immediately or only on success/first load

        do {
            // Add a small artificial delay for better UI feedback during refresh
            // if your actual API calls are very fast. Remove in production if not needed.
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay

            let fetchedArticles = try await apiService.fetchArticles()
            self.articles = fetchedArticles
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("DEBUG: NewsViewModel NetworkError: \(networkError.localizedDescription)")
        } catch is CancellationError {
            // Handle explicit task cancellation (e.g., user pulls to refresh again quickly)
            print("DEBUG: NewsViewModel fetchArticles was cancelled.")
            // Don't set error message for cancellation, as it's not a true error to the user
            // You might revert isLoading if you want, but the system handles the UI.
            errorMessage = nil // Clear any error that might have been there
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            print("DEBUG: NewsViewModel Generic Error: \(error.localizedDescription)")
        }
        isLoading = false // Ensure isLoading is set to false regardless of success/failure/cancellation
    }
}
