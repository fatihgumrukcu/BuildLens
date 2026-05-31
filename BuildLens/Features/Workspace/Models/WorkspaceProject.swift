import Foundation

struct WorkspaceProject: Identifiable, Hashable, Sendable {
    let id: URL                         // == url; unique per project
    let url: URL
    let name: String
    let projectType: WorkspaceProjectType
    let totalSize: Int64
    let nodeModulesSize: Int64          // node_modules/
    let podsSize: Int64                 // Pods/
    let derivedDataEstimate: Int64      // .build/ + build/ + .dart_tool/ — local build artefacts
    let lastModified: Date
    let isGitRepository: Bool
    let issues: [WorkspaceIssue]

    // MARK: - Derived

    // Storage reclaimable by cleaning known bloat directories
    var reclaimableSize: Int64 { nodeModulesSize + podsSize + derivedDataEstimate }

    var issueCount: Int { issues.count }

    // 100 points, deducting per issue severity
    var healthScore: Int {
        let deductions = issues.reduce(0) { total, issue in
            switch issue.severity {
            case .critical: return total + 30
            case .warning:  return total + 15
            case .healthy:  return total
            }
        }
        return max(0, 100 - deductions)
    }

    var healthSeverity: EnvironmentSeverity {
        if healthScore >= 75 { return .healthy }
        if healthScore >= 40 { return .warning }
        return .critical
    }

    var isStale: Bool {
        let threshold = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        return lastModified < threshold
    }
}
