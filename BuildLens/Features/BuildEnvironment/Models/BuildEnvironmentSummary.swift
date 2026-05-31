import Foundation

struct BuildEnvironmentSummary: Sendable {
    let tools: [BuildTool]

    // MARK: - Aggregates

    var installedCount: Int { tools.filter(\.isInstalled).count }
    var missingCount:   Int { tools.filter(\.isMissing).count }
    var outdatedCount:  Int { tools.filter { $0.status == .outdated }.count }

    var allIssues: [BuildToolIssue] {
        tools.flatMap(\.issues).sorted { $0.severity > $1.severity }
    }

    var issueCount: Int { allIssues.count }

    var toolsByCategory: [(category: BuildToolCategory, tools: [BuildTool])] {
        BuildToolCategory.allCases.compactMap { cat in
            let catTools = tools.filter { $0.category == cat }
            return catTools.isEmpty ? nil : (category: cat, tools: catTools)
        }
    }

    // 0-100 score: deduct per missing/outdated/issue.
    var healthScore: Int {
        let deductions = missingCount * 8 + outdatedCount * 4 + issueCount * 2
        return max(0, 100 - deductions)
    }

    var healthSeverity: EnvironmentSeverity {
        HealthScoring.severity(for: healthScore)
    }

    static let empty = BuildEnvironmentSummary(tools: [])
}
