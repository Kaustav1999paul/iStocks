import SwiftUI

struct SearchPage: View {
    @StateObject private var viewModel = StockSearchViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                
                Image("person").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .padding(.top, 60)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Your Financial Edge. Track stocks & gain insights.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.green)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("What's Your Next Move?")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                

                    TextField("Enter stock symbol or name", text: $viewModel.searchTerm)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal)
                        .onSubmit {
                            performSearchAndNavigate()
                        }
                
                HStack{
                    Button() {
                        performSearchAndNavigate()
                    }label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .disabled(viewModel.isLoading || viewModel.searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if let error = viewModel.errorMessage {
                    Text(error) // Display error message if present
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                Spacer() // Pushes content to the top
            }
            .navigationDestination(for: [StockQuote].self) { stocks in
                SearchResultsPage(searchResults: stocks)
            }
        }
        // Observe changes to viewModel.searchResults.
        // When `newResults` are available (and not empty), push them onto the navigation path.
        .onChange(of: viewModel.searchResults) { newResults in
            print("DEBUG: onChange(of: viewModel.searchResults) triggered. New Results Count: \(newResults.count)")
            if !newResults.isEmpty {
                path.append(newResults) // Navigates to SearchResultsPage, passing newResults
            }
        }
        // Observe changes to viewModel.errorMessage.
        // If an error occurs, clear the navigation path (pops any presented views).
        .onChange(of: viewModel.errorMessage) { newError in
            print("DEBUG: onChange(of: viewModel.errorMessage) triggered. New Error: \(newError ?? "nil")")
            if newError != nil {
                path = NavigationPath() // Reset path to pop back to root (SearchPage)
            }
        }
    }
    
    // Helper function to initiate the search process
    private func performSearchAndNavigate() {
        // Start an asynchronous task to call the ViewModel's search method.
        // The result will then be handled by the .onChange modifiers.
        Task {
            await viewModel.searchStock()
        }
    }
}

// MARK: - Preview Provider
// Used by Xcode's Canvas to display a live preview of the view.
struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
    }
}
