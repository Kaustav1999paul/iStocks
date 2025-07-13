import SwiftUI

struct SearchPage: View {
    @StateObject private var stockSearchViewModel = StockSearchViewModel() // Renamed for clarity
    @StateObject private var newsViewModel = NewsViewModel()
    @State private var path = NavigationPath()
    @State private var selectedArticleForSheet: Article?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) { // Set spacing to 0 for precise control with padding

                // MARK: - Header Text
                (Text("Your Financial Edge.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.black) +
                 Text(" Track stocks & gain insights.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.green))
                .padding(.horizontal)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30) // Add padding below this entire text block

                // MARK: - Search Bar and Button
                HStack {
                    TextField("Search any stocks", text: $stockSearchViewModel.searchTerm)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.leading)

                    Button {
                        performSearchAndNavigate()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .padding(.trailing)
                    .disabled(stockSearchViewModel.isLoading || stockSearchViewModel.searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.bottom, 20) // Padding below search bar/button and before news

                // MARK: - Loading/Error/News List
                // Consolidated loading and error display
                if stockSearchViewModel.isLoading || newsViewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer() // Keep Spacer if you want the ProgressView to be centered vertically
                } else if let combinedError = stockSearchViewModel.errorMessage ?? newsViewModel.errorMessage { // <--- Consolidated error check
                    Text(combinedError)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer() // Keep Spacer if you want the error to be centered vertically
                } else {
                    List {
                        Section(header: Text("Latest News").font(.title).foregroundStyle(Color.black)) {
                            if newsViewModel.articles.isEmpty {
                                Text("No news articles found.")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(newsViewModel.articles) { article in
                                    NewsArticleRow(article: article)
                                        .onTapGesture {
                                            self.selectedArticleForSheet = article
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await newsViewModel.fetchArticles()
                    }
                }
            }
            .navigationTitle("") // Hide default title
            .navigationBarHidden(true) // Hide navigation bar completely for full custom layout

            // MARK: - Navigation Destinations
            .navigationDestination(for: [StockQuote].self) { stocks in
                SearchResultsPage(searchResults: stocks)
            }
            .sheet(item: $selectedArticleForSheet) { article in 
                NewsArticleDetailSheet(article: article)
            }
            // Add other navigation destinations here if needed (e.g., for StockDetailPage)
            // .navigationDestination(for: StockQuote.self) { stock in
            //     StockDetailPage(stock: stock)
            // }
        }
        .onAppear {
            Task {
                await newsViewModel.fetchArticles()
            }
        }
        .onChange(of: stockSearchViewModel.searchResults) { newResults in
            print("DEBUG: onChange(of: stockSearchViewModel.searchResults) triggered. New Results Count: \(newResults.count)")
            if !newResults.isEmpty {
                path.append(newResults)
            }
        }
        .onChange(of: stockSearchViewModel.errorMessage) { newError in
            print("DEBUG: onChange(of: stockSearchViewModel.errorMessage) triggered. New Error: \(newError ?? "nil")")
            // No need to reset path here if alert is handling error display
            // path = NavigationPath() // Only uncomment if you explicitly want to pop
        }
        // Use an alert to display the search error
        .alert("Search Error", isPresented: .constant(stockSearchViewModel.errorMessage != nil), presenting: stockSearchViewModel.errorMessage) { errorMessage in
            Button("OK") { stockSearchViewModel.errorMessage = nil }
        } message: { errorMessage in
            Text(errorMessage)
        }
    }

    private func performSearchAndNavigate() {
        Task {
            await stockSearchViewModel.searchStock()
        }
    }
}

// MARK: - Preview Provider
struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
    }
}
