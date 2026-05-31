import Foundation

struct NodeModulesProject: Identifiable, Hashable, Sendable {
    let id: URL                      // == projectPath; unique per project
    let projectName: String
    let projectPath: URL
    let nodeModulesPath: URL
    let nodeModulesSize: Int64
    let packageCount: Int
    let lastModifiedDate: Date
    let projectType: NodeModulesProjectType
    let isStale: Bool
    let issues: [NodeModulesIssue]

    // MARK: - Derived

    var isOversized: Bool {
        nodeModulesSize >= NodeModulesThresholds.projectSizeWarning
    }

    var isAbandoned: Bool {
        let abandonedThreshold = Calendar.current.date(
            byAdding: .day, value: -NodeModulesThresholds.abandonedDays, to: Date()
        ) ?? Date()
        return lastModifiedDate < abandonedThreshold
            && nodeModulesSize >= NodeModulesThresholds.abandonedSizeThreshold
    }

    var daysSinceModified: Int {
        Calendar.current.dateComponents([.day], from: lastModifiedDate, to: Date()).day ?? 0
    }

    var healthSeverity: EnvironmentSeverity {
        if issues.contains(where: { $0.severity == .critical }) { return .critical }
        if issues.contains(where: { $0.severity == .warning })  { return .warning  }
        return .healthy
    }
}
