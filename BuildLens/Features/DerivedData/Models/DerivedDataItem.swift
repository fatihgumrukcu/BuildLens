import Foundation

struct DerivedDataItem: Identifiable, Hashable, Sendable {
    let id: URL
    let url: URL
    let rawName: String
    let size: Int64
    let lastModified: Date

    // Xcode appends a 26-char lowercase alphanumeric hash to every DerivedData folder:
    // "MyApp-bjgmzpqacgxixccahnzufisqtzfj" → "MyApp"
    // Projects with dashes in their names are preserved: "My-App-hash" → "My-App"
    var displayName: String {
        let parts = rawName.components(separatedBy: "-")
        guard parts.count >= 2, let last = parts.last else { return rawName }
        let isHash = last.count >= 20 && last.allSatisfy { $0.isLowercase || $0.isNumber }
        return isHash ? parts.dropLast().joined(separator: "-") : rawName
    }
}

extension DerivedDataItem {
    // Convenience initialiser so the ViewModel can map [DirectoryItem] without a manual loop.
    init(from item: DirectoryItem) {
        self.id           = item.url
        self.url          = item.url
        self.rawName      = item.name
        self.size         = item.size
        self.lastModified = item.lastModified
    }
}
