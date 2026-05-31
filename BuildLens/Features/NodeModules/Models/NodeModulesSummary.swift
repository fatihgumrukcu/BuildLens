import Foundation

struct NodeModulesSummary: Sendable {
    let totalProjects: Int
    let totalNodeModulesStorage: Int64
    let largestProject: NodeModulesProject?
    let staleProjects: Int
    let abandonedProjects: Int
    let reclaimableStorage: Int64       // storage from stale or oversized projects
    let topIssues: [NodeModulesIssue]   // cross-project issues, severity-sorted

    static func build(from projects: [NodeModulesProject]) -> NodeModulesSummary {
        let total  = projects.reduce(0) { $0 + $1.nodeModulesSize }
        let stale  = projects.filter(\.isStale).count
        let abandoned = projects.filter(\.isAbandoned).count
        let largest = projects.max(by: { $0.nodeModulesSize < $1.nodeModulesSize })

        let reclaimable = projects
            .filter { $0.isStale || $0.isOversized }
            .reduce(0) { $0 + $1.nodeModulesSize }

        let crossProjectIssues = buildCrossProjectIssues(
            total: total,
            abandoned: abandoned,
            projects: projects
        )

        let allIssues = (projects.flatMap(\.issues) + crossProjectIssues)
            .sorted { $0.severity > $1.severity }

        return NodeModulesSummary(
            totalProjects: projects.count,
            totalNodeModulesStorage: total,
            largestProject: largest,
            staleProjects: stale,
            abandonedProjects: abandoned,
            reclaimableStorage: reclaimable,
            topIssues: Array(allIssues.prefix(6))
        )
    }

    // MARK: - Cross-project issue generation

    private static func buildCrossProjectIssues(
        total: Int64,
        abandoned: Int,
        projects: [NodeModulesProject]
    ) -> [NodeModulesIssue] {
        var issues: [NodeModulesIssue] = []
        let T = NodeModulesThresholds.self

        if total >= T.totalSizeWarning {
            let severity: EnvironmentSeverity = total >= T.totalSizeCritical ? .critical : .warning
            issues.append(NodeModulesIssue(
                title: "Total node_modules exceeds \(total.formattedBytes)",
                description: "Combined node_modules across \(projects.count) projects is \(total.formattedBytes). This puts significant pressure on disk space.",
                severity: severity,
                affectedStorage: total,
                recommendation: "Delete node_modules in inactive projects and reinstall on demand."
            ))
        }

        if abandoned >= 2 {
            let abandonedStorage = projects.filter(\.isAbandoned).reduce(0) { $0 + $1.nodeModulesSize }
            issues.append(NodeModulesIssue(
                title: "\(abandoned) abandoned projects with large node_modules",
                description: "\(abandoned) projects haven't been touched in \(T.abandonedDays)+ days but collectively hold \(abandonedStorage.formattedBytes) in node_modules.",
                severity: .warning,
                affectedStorage: abandonedStorage,
                recommendation: "Archive or delete node_modules in projects you are no longer actively developing."
            ))
        }

        return issues
    }

    static let empty = NodeModulesSummary(
        totalProjects: 0,
        totalNodeModulesStorage: 0,
        largestProject: nil,
        staleProjects: 0,
        abandonedProjects: 0,
        reclaimableStorage: 0,
        topIssues: []
    )
}
