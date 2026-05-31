import Foundation

struct CleanupItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let category: CleanupCategory
    let url: URL
    let name: String
    let size: Int64
    let detail: String
    let riskLevel: CleanupRiskLevel
    var isSelected: Bool

    init(
        id: UUID = UUID(),
        category: CleanupCategory,
        url: URL,
        name: String,
        size: Int64,
        detail: String = "",
        riskLevel: CleanupRiskLevel? = nil,
        isSelected: Bool = true
    ) {
        self.id = id
        self.category = category
        self.url = url
        self.name = name
        self.size = size
        self.detail = detail
        self.riskLevel = riskLevel ?? category.riskLevel
        self.isSelected = isSelected
    }
}
