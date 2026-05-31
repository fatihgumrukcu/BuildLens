import SwiftUI

@Observable @MainActor
final class DiagnosticsViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded(DiagnosticSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var selectedCategory: DiagnosticCategory? = nil
    var selectedSeverity: EnvironmentSeverity? = nil

    private let service: any DiagnosticsServiceProtocol

    init(service: any DiagnosticsServiceProtocol = DiagnosticsService()) {
        self.service = service
    }

    // MARK: - Derived State

    var summary: DiagnosticSummary? {
        if case .loaded(let s) = scanState { return s }
        return nil
    }

    var filteredCritical: [DiagnosticIssue] {
        filter(summary?.criticalIssues ?? [])
    }

    var filteredWarnings: [DiagnosticIssue] {
        filter(summary?.warningIssues ?? [])
    }

    private func filter(_ issues: [DiagnosticIssue]) -> [DiagnosticIssue] {
        guard let cat = selectedCategory else { return issues }
        return issues.filter { $0.category == cat }
    }

    var hasActiveFilter: Bool { selectedCategory != nil }

    private(set) var isRescanning = false

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let result = try await service.generateReport()
            scanState = .loaded(result)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func rescan() async {
        guard !isRescanning else { return }
        isRescanning = true
        defer { isRescanning = false }
        do {
            let result = try await service.generateReport()
            scanState = .loaded(result)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }
}
