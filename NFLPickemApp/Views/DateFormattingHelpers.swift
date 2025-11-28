import Foundation

enum DateFormatters {
    static let iso8601 = ISO8601DateFormatter()
    
    static let short: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
}
