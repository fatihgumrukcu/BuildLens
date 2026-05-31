import SwiftUI

enum NodeModulesSortOrder: String, CaseIterable, Hashable {
    case size         = "Size"
    case packageCount = "Packages"
    case lastModified = "Last Modified"
    case name         = "Name"
}

@Observable @MainActor
final class NodeModulesViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded([NodeModulesProject], NodeModulesSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var searchQuery:          String = ""
    var selectedTypeFilter:   NodeModulesProjectType? = nil
    var showOnlyStale:        Bool = false
    var showOnlyOversized:    Bool = false
    var sortOrder:            NodeModulesSortOrder = .size

    private let service: any NodeModulesServiceProtocol

    init(service: any NodeModulesServiceProtocol = NodeModulesService()) {
        self.service = service
    }

    // MARK: - Derived State

    var projects: [NodeModulesProject] {
        if case .loaded(let p, _) = scanState { return p }
        return []
    }

    var summary: NodeModulesSummary? {
        if case .loaded(_, let s) = scanState { return s }
        return nil
    }

    var filteredProjects: [NodeModulesProject] {
        var result = projects

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.projectName.localizedCaseInsensitiveContains(searchQuery) ||
                $0.projectPath.path.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        if let filter = selectedTypeFilter {
            result = result.filter { $0.projectType == filter }
        }
        if showOnlyStale     { result = result.filter(\.isStale) }
        if showOnlyOversized { result = result.filter(\.isOversized) }

        switch sortOrder {
        case .size:         result.sort { $0.nodeModulesSize > $1.nodeModulesSize }
        case .packageCount: result.sort { $0.packageCount > $1.packageCount }
        case .lastModified: result.sort { $0.lastModifiedDate < $1.lastModifiedDate }
        case .name:         result.sort { $0.projectName.localizedCompare($1.projectName) == .orderedAscending }
        }
        return result
    }

    var activeFiltersDescription: String? {
        var parts: [String] = []
        if let t = selectedTypeFilter { parts.append(t.rawValue) }
        if showOnlyStale     { parts.append("Stale") }
        if showOnlyOversized { parts.append("Oversized") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let results = try await service.scanProjects()
            let summary = NodeModulesSummary.build(from: results)
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
