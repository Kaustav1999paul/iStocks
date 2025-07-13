import SwiftUI

struct StockDetailPage: View {
    // 1. Receive the selected StockQuote from the previous page
    let stock: StockQuote

    @StateObject private var viewModel = StockDetailViewModel()
    @State private var showingFullDescriptionSheet = false

    var body: some View {
        ScrollView { // Use ScrollView for potentially long content
            VStack(alignment: .leading, spacing: 15) {
                // MARK: - Loading State
                if viewModel.isLoading {
                    ProgressView("Loading Profile...")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // MARK: - Error State
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                // MARK: - Display Profile Data
                if let profile = viewModel.companyProfile {
                    //                    MARK: Heading Area
                                        HStack{
                                            VStack{
                                                // Stock Name & Symbol
                                                Text(profile.companyName ?? stock.name)
                                                    .font(.largeTitle)
                                                    .fontWeight(.bold)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                            if let imageUrlString = profile.image, let url = URL(string: imageUrlString) {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 50, height: 50)
                                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                                } placeholder: {
                                                    ProgressView().frame(width: 100, height: 100)
                                                }
                                                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 0)
                                                .frame(maxWidth: .infinity, alignment: .trailing) // Center the image
                                            }
                                        }
                                        

                    HStack {
                                          Text("\(profile.price ?? 0.0, specifier: "%.2f") \(profile.currency ?? "")")
                                              .font(.largeTitle)
                                              .foregroundColor(profile.change ?? 0 >= 0 ? .green : .red)
                                          Spacer()
                                          Text(profile.symbol)
                                              .font(.title2)
                                              .fontWeight(Font.Weight.thin)
                                              .foregroundColor(Color.green)
                                      }

                    // Price Information
                    VStack {
                        if let change = profile.change, let changePercentage = profile.changePercentage {
                            HStack {
                                Text("Change:")
                                Spacer()
                                Text("\(change, specifier: "%.2f") (\(changePercentage, specifier: "%.2f")%)")
                                    .font(.subheadline)
                                    .foregroundColor(change >= 0 ? .green : .red)
                            }.padding(.horizontal).padding(.top).padding(.bottom, 5)
                        }

                        if let marketCap = profile.marketCap {
                            HStack {
                                Text("Market Cap:")
                                Spacer()
                                Text("\(formatMarketCap(marketCap))").font(.subheadline)
                            }.padding(.horizontal).padding(.bottom)
                        }
                    }.background(Color.green.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.vertical, 2)

                    // Company Details
                    VStack(alignment: .leading, spacing: 5) {
                        DetailRow(label: "Exchange", value: profile.exchangeFullName)
                        DetailRow(label: "Industry", value: profile.industry)
                        DetailRow(label: "Sector", value: profile.sector)
                        DetailRow(label: "CEO", value: profile.ceo)
                        DetailRow(label: "Website", value: profile.website)
                        DetailRow(label: "Employees", value: profile.fullTimeEmployees)
                        DetailRow(label: "IPO Date", value: profile.ipoDate)
                    }

                    Divider()

                    // Company Description
                    if let description = profile.description {
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("About \(profile.companyName ?? "the Company")")
                                .font(.headline)
                                .padding(.bottom, 5)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            Text(description)
                                .font(.body)
                                .lineLimit(5)
                                .padding(.horizontal)// Limit to 5 lines
                            
                            // Show "Read More" only if description might be truncated
                            if description.numberOfLines() > 5 { // This requires an extension
                                Button("Read More") {
                                    showingFullDescriptionSheet = true
                                }
                                .padding(.horizontal)
                                .font(.callout)
                                .foregroundColor(.green)
                                .padding(.top, 1)
                                .padding(.bottom)
                            }
                        }.background(Color.green.opacity(0.1))
                            .cornerRadius(15)
                            .padding(.vertical, 2)
                    }
                }
            }
            .padding() // Keep title compact
        }
        // When the view appears, fetch the profile
        .onAppear {
            Task {
                await viewModel.fetchProfile(for: stock.symbol)
            }
        }
        .sheet(isPresented: $showingFullDescriptionSheet) {
                    if let profile = viewModel.companyProfile {
                        FullDescriptionSheet(
                            companyName: profile.companyName ?? stock.name,
                            description: profile.description ?? "No description available."
                        )
                    }
                }
    }
    
    // Helper function to format large numbers like Market Cap
    func formatMarketCap(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        if value >= 1_000_000_000_000 { // Trillions
            let trillions = value / 1_000_000_000_000
            return (formatter.string(from: NSNumber(value: trillions)) ?? "") + "T"
        } else if value >= 1_000_000_000 { // Billions
            let billions = value / 1_000_000_000
            return (formatter.string(from: NSNumber(value: billions)) ?? "") + "B"
        } else if value >= 1_000_000 { // Millions
            let millions = value / 1_000_000
            return (formatter.string(from: NSNumber(value: millions)) ?? "") + "M"
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

// MARK: - Helper View for Detail Rows

// Creates a consistent layout for label-value pairs
struct DetailRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            if let value = value, !value.isEmpty {
                Text(value)
                    .font(.subheadline)
            } else {
                Text("N/A") // Or some other placeholder
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
        }
    }
}


struct FullDescriptionSheet: View {
    let companyName: String
    let description: String

    @Environment(\.dismiss) var dismiss // For dismissing the sheet

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {

                    Text(description)
                        .font(.body)
                        .lineLimit(nil)
                }
                .padding()
            }
            .navigationTitle(companyName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - String Extension to Estimate Line Count (Simple Approach)
// Note: A more accurate way would involve GeometryReader and Text.sizeThatFits
extension String {
    func numberOfLines() -> Int {
        // This is a rough estimation. For precise line counting, you'd need
        // to render the text with the actual font and width constraints.
        // A common character width assumption for a given font and lineLimit can be used.
        // For simplicity, we'll assume a line break every ~70 characters for average text.
        let estimatedCharactersPerLine = 60 // Adjust based on your typical font/device width
        return (self.count / estimatedCharactersPerLine) + 1
    }
}

// MARK: - Preview Provider (for Canvas)
struct StockDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        // Example StockQuote for previewing
        let exampleStock = StockQuote(
            symbol: "AAPL",
            name: "Alphabet Inc.",
            currency: "USD",
            exchange: "NASDAQ",
            exchangeFullName: "NASDAQ Global Select"
        )
        
        NavigationStack {
            StockDetailPage(stock: exampleStock)
        }
    }
}
