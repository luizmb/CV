import Foundation

extension String {
    /// Converts "2024-04-07" → "Apr 2024", or returns "Present" for nil.
    func formattedAsMonthYear() -> String {
        let iso = DateFormatter()
        iso.dateFormat = "yyyy-MM-dd"
        iso.locale = Locale(identifier: "en_GB")
        guard let date = iso.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "MMM yyyy"
        out.locale = Locale(identifier: "en_GB")
        return out.string(from: date)
    }

    /// Strip emoji flag characters (used in location strings)
    func strippingFlagEmoji() -> String {
        self.unicodeScalars
            .filter { !($0.value >= 0x1F1E0 && $0.value <= 0x1F1FF) }
            .reduce("") { $0 + String($1) }
            .trimmingCharacters(in: .whitespaces)
    }
}
