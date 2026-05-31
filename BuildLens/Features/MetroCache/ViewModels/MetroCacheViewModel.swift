import SwiftUI

enum MetroCacheSortOrder: String, CaseIterable, Hashable {
    case size = "Size"
    case age  = "Age"
    case name = "Name"
}

@Observable @MainActor
final class MetroCacheViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded([MetroCacheEntry], MetroCacheSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var showOnlyStale: Bool = false
    var sortOrder: MetroCacheSortOrder = .size

    private let service: any MetroCacheServiceProtocol

    init(service: any MetroCacheServiceProtocol = MetroCacheService()) {
        self.service = service
    }

    // MARK: - Derived State

    var entries: [MetroCacheEntry] {
        if case .loaded(let e, _) = scanState { return e }
        return []
    }

    var summary: MetroCacheSummary? {
        if case .loaded(_, let s) = scanState { return s }
        return nil
    }

    var filteredEntries: [MetroCacheEntry] {
        var result = entries
        if showOnlyStale { result = result.filter(\.isStale) }

        switch sortOrder {
        case .size: result.sort { $0.size > $1.size }
        case .age:  result.sort { $0.lastModifiedDate < $1.lastModifiedDate }
        case .name: result.sort { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
        }
        return result
    }

    var totalEntries: Int { entries.count }
    var hasIssues: Bool { !(summary?.issues.isEmpty ?? true) }

    private(set) var isRescanning = false

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let results = try await service.scanEntries()
            let summary = MetroCacheSummary.build(from: results)
            scanState = .loaded(results, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        guard !isRescanning else { return }
        isRescanning = true
        defer { isRescanning = false }
        do {
            let results = try await service.scanEntries()
            let summary = MetroCacheSummary.build(from: results)
            scanState = .loaded(results, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }
}
