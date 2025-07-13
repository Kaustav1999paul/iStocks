import SwiftUI

struct NewsArticleRow: View {
    let article: Article // Ensure Article has 'link: String?'

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrlString = article.image, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(height: 150)
                        .cornerRadius(8)
                }
            }

            Text(article.title)
                .font(.headline)
                .lineLimit(2)

            Text(formatDate(article.date)) // Confirmed to be non-optional
                .font(.caption)
                .foregroundColor(.secondary)

            if let author = article.author, !author.isEmpty {
                Text("By \(author) on \(article.site ?? "Unknown Site")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        // No onTapGesture here, it's handled by the parent view (SearchPage)
    }

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
