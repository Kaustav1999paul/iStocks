//
//  NewsArticleDetailSheet.swift
//  iStocks
//
//  Created by Kaustav Paul on 13/07/25.
//

import SwiftUI
import WebKit // Needed for WebView to render HTML content

// UIViewRepresentable for rendering HTML content
struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}


struct NewsArticleDetailSheet: View {
    let article: Article // The article data passed from SearchPage
    @Environment(\.dismiss) var dismiss // To dismiss the sheet

    var body: some View {
        NavigationView { // Use NavigationView for the sheet to get a navigation bar
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    
                    if let imageUrlString = article.image, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView().frame(width: 100, height: 100)
                        }
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 0)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    if let author = article.author, !author.isEmpty {
                        Text("By \(author) on \(article.site ?? "Unknown Site")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(formatDate(article.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    WebView(htmlString: article.content)
                        .frame(minHeight: 200, idealHeight: 400, maxHeight: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 5)
                }.padding()
            }
            .navigationTitle("Article Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Helper function to format the date string (can reuse from NewsArticleRow)
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Preview
struct NewsArticleDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy article for preview purposes
        let dummyArticle = Article(
            title: "Example Article Title: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            date: "2025-07-13 10:00:00",
            content: "<p>This is some <b>sample HTML content</b> for the article body.</p><p>It can include <a href='https://example.com'>links</a> and other basic formatting.</p><p>More content to make it scrollable.</p><p>Final paragraph of the article.</p>",
            tickers: "AAPL",
            image: nil, // Provide a dummy image URL if you have one for preview
            link: "https://financialmodelingprep.com/market-news/example-article",
            author: "John Doe",
            site: "Sample News Site"
        )
        NewsArticleDetailSheet(article: dummyArticle)
    }
}
