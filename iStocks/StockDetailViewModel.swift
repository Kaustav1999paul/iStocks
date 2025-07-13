import Foundation
import Combine // Don't forget to import Combine for ObservableObject

// MARK: - StockDetailViewModel (Moved from StockDetailPage.swift)
class StockDetailViewModel: ObservableObject {
    @Published var companyProfile: CompanyProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Keep both initializers for live and preview scenarios
    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    init(previewProfile: CompanyProfile) {
        self.companyProfile = previewProfile
        self.isLoading = false
        self.errorMessage = nil
        self.apiService = APIService() // Still needs an instance, but won't be used for fetch
    }

    @MainActor
    func fetchProfile(for symbol: String) async {
        isLoading = true
        errorMessage = nil
        companyProfile = nil

        do {
            let profile = try await apiService.fetchCompanyProfile(symbol: symbol)
            companyProfile = profile
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("DEBUG: StockDetailViewModel NetworkError: \(networkError.localizedDescription)")
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            print("DEBUG: StockDetailViewModel Generic Error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
