import Foundation

struct CleanupResult: Sendable {
    let deletedItems: [CleanupItem]
    let failedItems: [(item: CleanupItem, error: String)]
    let freedBytes: Int64
    let completedAt: Date

    var deletedCount: Int { deletedItems.count }
    var failedCount: Int { failedItems.count }
    var totalAttempted: Int { deletedCount + failedCount }
    var wasFullSuccess: Bool { failedItems.isEmpty }
}
