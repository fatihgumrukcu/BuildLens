import SwiftUI

@Observable @MainActor
final class BuildEnvironmentViewModel {

    enum ScanState {
        case idle
        case scanning
        case loaded(BuildEnvironmentSummary)
        case error(String)
    }

    private(set) var scanState: ScanState = .idle
    var selectedCategory: BuildToolCategory? = nil
    var showOnlyIssues: Bool = false

    private let service: any BuildEnvironmentServiceProtocol

    init(service: any BuildEnvironmentServiceProtocol = BuildEnvironmentService()) {
        self.service = service
    }

    // MARK: - Derived

    var summary: BuildEnvironmentSummary? {
        if case .loaded(let s) = scanState { return s }
        return nil
    }

    var filteredTools: [BuildTool] {
        guard let summary else { return [] }
        var tools = summary.tools
        if let cat = selectedCategory { tools = tools.filter { $0.category == cat } }
        if showOnlyIssues { tools = tools.filter { !$0.issues.isEmpty || $0.isMissing } }
        return tools
    }

    var toolsByCategory: [(category: BuildToolCategory, tools: [BuildTool])] {
        BuildToolCategory.allCases.compactMap { cat in
            let catTools = filteredTools.filter { $0.category == cat }
            return catTools.isEmpty ? nil : (category: cat, tools: catTools)
        }
    }

    private(set) var isRescanning = false

    // MARK: - Actions

    func scan() async {
        guard case .idle = scanState else { return }
        scanState = .scanning
        do {
            let result = try await service.scan()
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
            let result = try await service.scan()
            scanState = .loaded(result)
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }
}
