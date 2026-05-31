import SwiftUI

enum WorkspaceSortOrder: String, CaseIterable, Hashable {
    case reclaimable  = "Reclaimable Storage"
    case totalSize    = "Total Size"
    case lastModified = "Last Modified"
    case name         = "Name"
    case issues       = "Issue Count"
}

@Observable @MainActor
final class WorkspaceViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded([WorkspaceProject], WorkspaceSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var searchQuery:        String = ""
    var selectedTypeFilter: WorkspaceProjectType? = nil
    var showOnlyWithIssues: Bool = false
    var showOnlyStale:      Bool = false
    var sortOrder:          WorkspaceSortOrder = .reclaimable

    private let service: any WorkspaceServiceProtocol

    init(service: any WorkspaceServiceProtocol) {
        self.service = service
    }

    convenience init() {
        self.init(service: WorkspaceService())
    }

    // MARK: - Derived State

    var projects: [WorkspaceProject] {
        if case .loaded(let p, _) = scanState { return p }
        return []
    }

    var summary: WorkspaceSummary? {
        if case .loaded(_, let s) = scanState { return s }
        return nil
    }

    var filteredProjects: [WorkspaceProject] {
        var result = projects

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.url.path.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        if let filter = selectedTypeFilter {
            result = result.filter { $0.projectType == filter }
        }
        if showOnlyWithIssues {
            result = result.filter { $0.issueCount > 0 }
        }
        if showOnlyStale {
            result = result.filter { $0.isStale }
        }

        switch sortOrder {
        case .reclaimable:  result.sort { $0.reclaimableSize > $1.reclaimableSize }
        case .totalSize:    result.sort { $0.totalSize > $1.totalSize }
        case .lastModified: result.sort { $0.lastModified < $1.lastModified }
        case .name:         result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .issues:       result.sort { $0.issueCount > $1.issueCount }
        }
        return result
    }

    var activeFiltersDescription: String? {
        var parts: [String] = []
        if let t = selectedTypeFilter { parts.append(t.rawValue) }
        if showOnlyWithIssues { parts.append("Has Issues") }
        if showOnlyStale      { parts.append("Stale") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private(set) var isRescanning = false

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let projects = try await service.scanProjects()
            let summary  = WorkspaceSummary.build(from: projects)
            scanState = .loaded(projects, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        guard !isRescanning else { return }
        isRescanning = true
        defer { isRescanning = false }
        do {
            let projects = try await service.scanProjects()
            let summary  = WorkspaceSummary.build(from: projects)
            scanState = .loaded(projects, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }
}

