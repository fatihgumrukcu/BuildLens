import SwiftUI

@Observable @MainActor
final class EnvironmentHealthViewModel {

    enum LoadState {
        case idle
        case loading
        case loaded(EnvironmentHealthReport)
        case error(String)  // reserved for future service implementations that may throw
    }

    private(set) var loadState: LoadState = .idle
    var selectedSeverityFilter: EnvironmentSeverity? = nil

    private let service: any EnvironmentHealthServiceProtocol

    init(service: any EnvironmentHealthServiceProtocol) {
        self.service = service
    }

    @MainActor
    convenience init() {
        self.init(service: EnvironmentHealthService())
    }

    // MARK: - Derived State

    var report: EnvironmentHealthReport? {
        if case .loaded(let r) = loadState { return r }
        return nil
    }

    var isLoading: Bool {
        if case .loading = loadState { return true }
        return false
    }

    // All issues from the current report, filtered by the selected severity.
    var filteredIssues: [EnvironmentIssue] {
        guard let r = report else { return [] }
        guard let filter = selectedSeverityFilter else { return r.allIssues }
        return r.allIssues.filter { $0.severity == filter }
    }

    var criticalIssues: [EnvironmentIssue] { report?.criticalIssues ?? [] }
    var warningIssues:  [EnvironmentIssue] { report?.warningIssues  ?? [] }

    var issueCountByCategory: [EnvironmentHealthCategory: Int] {
        guard let r = report else { return [:] }
        return Dictionary(
            r.allIssues.map { ($0.category, 1) },
            uniquingKeysWith: +
        )
    }

    private(set) var isRescanning = false

    // MARK: - Actions

    func load() async {
        guard case .idle = loadState else { return }
        loadState = .loading
        let report = await service.generateReport()
        loadState = .loaded(report)
        HealthHistoryService.append(score: report.overallScore, status: report.status)
    }

    func refresh() async {
        guard !isRescanning else { return }
        isRescanning = true
        defer { isRescanning = false }
        let report = await service.generateReport()
        loadState = .loaded(report)
        HealthHistoryService.append(score: report.overallScore, status: report.status)
    }
}

