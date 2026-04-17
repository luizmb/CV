import Foundation

private let isoParser: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_GB")
    return f
}()

private func cvFormatDate(_ dateString: String, format: String) -> String {
    guard let date = isoParser.date(from: dateString) else { return dateString }
    let f = DateFormatter()
    f.dateFormat = format
    f.locale = Locale(identifier: "en_GB")
    return f.string(from: date)
}

extension String {
    /// Converts "2024-04-07" → "Apr 2024"
    func formattedAsMonthYear() -> String {
        cvFormatDate(self, format: "MMM yyyy")
    }

    /// Converts "2024-04-07" → "April/2024"
    func formattedAsLongMonthYear() -> String {
        cvFormatDate(self, format: "MMMM/yyyy")
    }

    /// Converts "2024-04-07" → "2024"
    func formattedAsYear() -> String {
        cvFormatDate(self, format: "yyyy")
    }

    /// Strip emoji flag characters (used in location strings)
    func strippingFlagEmoji() -> String {
        self.unicodeScalars
            .filter { !($0.value >= 0x1F1E0 && $0.value <= 0x1F1FF) }
            .reduce("") { $0 + String($1) }
            .trimmingCharacters(in: .whitespaces)
    }
}
