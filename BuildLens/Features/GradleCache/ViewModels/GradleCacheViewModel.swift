import SwiftUI

enum GradleCacheSortOrder: String, CaseIterable, Hashable {
    case size = "Size"
    case age  = "Age"
    case name = "Name"
}

@Observable @MainActor
final class GradleCacheViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded([GradleCacheEntry], GradleCacheSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var selectedCategory: GradleCacheCategory? = nil
    var showOnlyStale: Bool = false
    var sortOrder: GradleCacheSortOrder = .size

    private let service: any GradleCacheServiceProtocol

    init(service: any GradleCacheServiceProtocol = GradleCacheService()) {
        self.service = service
    }

    // MARK: - Derived State

    var entries: [GradleCacheEntry] {
        if case .loaded(let e, _) = scanState { return e }
        return []
    }

    var summary: GradleCacheSummary? {
        if case .loaded(_, let s) = scanState { return s }
        return nil
    }

    var filteredEntries: [GradleCacheEntry] {
        var result = entries
        if let cat = selectedCategory { result = result.filter { $0.category == cat } }
        if showOnlyStale { result = result.filter(\.isStale) }
        switch sortOrder {
        case .size: result.sort { $0.size > $1.size }
        case .age:  result.sort { $0.lastModifiedDate < $1.lastModifiedDate }
        case .name: result.sort { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
        }
        return result
    }

    // Entries grouped by category, ordered largest-first within each group.
    var entriesByCategory: [(category: GradleCacheCategory, entries: [GradleCacheEntry])] {
        GradleCacheCategory.allCases.compactMap { cat in
            let catEntries = entries.filter { $0.category == cat }.sorted { $0.size > $1.size }
            return catEntries.isEmpty ? nil : (category: cat, entries: catEntries)
        }
    }

    var hasIssues: Bool { !(summary?.issues.isEmpty ?? true) }
    var totalEntries: Int { entries.count }

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let results = try await service.scanEntries()
            let summary = GradleCacheSummary.build(from: results)
            scanState = .loaded(results, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        scanState = .idle
        await scan()
    }
}
