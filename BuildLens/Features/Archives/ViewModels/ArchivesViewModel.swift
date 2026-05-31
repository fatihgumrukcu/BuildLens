import SwiftUI

enum ArchivesSortOrder: String, CaseIterable, Hashable {
    case storage      = "Storage"
    case archiveCount = "Archives"
    case recent       = "Most Recent"
    case name         = "Name"
}

@Observable @MainActor
final class ArchivesViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded([ArchiveItem], ArchiveSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var sortOrder: ArchivesSortOrder = .storage
    var showOnlyStale: Bool = false
    var searchQuery: String = ""

    private let service: any ArchivesServiceProtocol

    init(service: any ArchivesServiceProtocol = ArchivesService()) {
        self.service = service
    }

    // MARK: - Derived State

    var summary: ArchiveSummary? {
        if case .loaded(_, let s) = scanState { return s }
        return nil
    }

    var filteredProjects: [ArchiveProject] {
        guard let summary else { return [] }
        var projects = summary.projects

        if !searchQuery.isEmpty {
            projects = projects.filter {
                $0.projectName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        if showOnlyStale {
            projects = projects.filter { $0.staleCount > 0 }
        }

        switch sortOrder {
        case .storage:      projects.sort { $0.totalStorage > $1.totalStorage }
        case .archiveCount: projects.sort { $0.archiveCount > $1.archiveCount }
        case .recent:       projects.sort { $0.latestArchiveDate > $1.latestArchiveDate }
        case .name:         projects.sort { $0.projectName.localizedCompare($1.projectName) == .orderedAscending }
        }
        return projects
    }

    var hasIssues: Bool { !(summary?.issues.isEmpty ?? true) }

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let items = try await service.scanArchives()
            let summary = ArchiveSummary.build(from: items)
            scanState = .loaded(items, summary)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        scanState = .idle
        await scan()
    }
}
