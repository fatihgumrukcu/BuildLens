import Foundation

struct CleanupPreview: Sendable {
    let items: [CleanupItem]
    let scannedAt: Date

    var selectedItems: [CleanupItem] { items.filter(\.isSelected) }
    var totalSize: Int64 { items.reduce(0) { $0 + $1.size } }
    var selectedSize: Int64 { selectedItems.reduce(0) { $0 + $1.size } }
    var selectedCount: Int { selectedItems.count }

    var itemsByCategory: [(category: CleanupCategory, items: [CleanupItem])] {
        CleanupCategory.allCases.compactMap { category in
            let matching = items.filter { $0.category == category }
            guard !matching.isEmpty else { return nil }
            return (category: category, items: matching)
        }
    }
}
