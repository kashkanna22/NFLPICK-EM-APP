import Foundation

struct NewsResponse: Decodable {
    let articles: [NewsArticle]
}

struct NewsArticle: Decodable, Identifiable {
    let id: String
    let headline: String
    let description: String?
    let published: String
    let links: NewsLinks
}

extension NewsArticle {
    var publishedDate: Date? {
        DateFormatters.iso8601.date(from: published)
    }

    var publishedShort: String {
        guard let date = publishedDate else { return "" }
        return DateFormatters.short.string(from: date)
    }

    var webURL: URL? {
        guard let href = links.web?.href else { return nil }
        return URL(string: href)
    }
}

struct NewsLinks: Decodable {
    let web: HrefContainer?
}

struct HrefContainer: Decodable {
    let href: String?
}
