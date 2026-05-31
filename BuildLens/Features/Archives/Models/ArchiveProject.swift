import Foundation

struct ArchiveProject: Identifiable, Hashable, Sendable {
    let id: String              // == projectName
    let projectName: String
    let archiveCount: Int
    let totalStorage: Int64
    let latestArchiveDate: Date
    let oldestArchiveDate: Date
    let archives: [ArchiveItem] // sorted newest-first

    // MARK: - Derived

    var isAbandoned: Bool {
        let threshold = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        return latestArchiveDate < threshold
    }

    var staleCount: Int    { archives.filter(\.isStale).count }
    var staleStorage: Int64 { archives.filter(\.isStale).reduce(0) { $0 + $1.size } }

    var uploadedCount: Int { archives.filter(\.wasUploaded).count }

    // Duplicate sets: (project, dateGroup) pairs with more than one archive.
    var duplicateDateGroups: [String] {
        let grouped = Dictionary(grouping: archives, by: \.dateGroup)
        return grouped.compactMap { group, items in items.count > 1 ? group : nil }
    }

    var daysSinceLatest: Int {
        Calendar.current.dateComponents([.day], from: latestArchiveDate, to: Date()).day ?? 0
    }
}
