import Foundation

struct DiagnosticSummary: Sendable {
    let criticalIssues: [DiagnosticIssue]
    let warningIssues:  [DiagnosticIssue]
    let healthyItems:   [DiagnosticIssue]
    let totalAffectedStorage: Int64
    let reclaimableStorage:   Int64
    let categoryHealth: [DiagnosticCategory: EnvironmentSeverity]

    var allIssues: [DiagnosticIssue] { criticalIssues + warningIssues }
    var criticalCount: Int { criticalIssues.count }
    var warningCount:  Int { warningIssues.count }
    var healthyCount:  Int { healthyItems.count }
    var totalIssueCount: Int { criticalCount + warningCount }

    var overallSeverity: EnvironmentSeverity {
        if !criticalIssues.isEmpty { return .critical }
        if !warningIssues.isEmpty  { return .warning  }
        return .healthy
    }

    // MARK: - Factory

    static func build(from issues: [DiagnosticIssue]) -> DiagnosticSummary {
        let critical = issues.filter { $0.severity == .critical }
        let warnings = issues.filter { $0.severity == .warning }
        let healthy  = issues.filter { $0.severity == .healthy }

        let totalStorage = issues.compactMap(\.affectedStorage).reduce(0, +)
        let reclaimable  = (critical + warnings).compactMap(\.affectedStorage).reduce(0, +)

        var catHealth: [DiagnosticCategory: EnvironmentSeverity] = [:]
        for cat in DiagnosticCategory.allCases {
            let catIssues = issues.filter { $0.category == cat }
            if catIssues.contains(where: { $0.severity == .critical }) {
                catHealth[cat] = .critical
            } else if catIssues.contains(where: { $0.severity == .warning }) {
                catHealth[cat] = .warning
            } else {
                catHealth[cat] = .healthy
            }
        }

        return DiagnosticSummary(
            criticalIssues: critical.sorted { ($0.affectedStorage ?? 0) > ($1.affectedStorage ?? 0) },
            warningIssues:  warnings.sorted { ($0.affectedStorage ?? 0) > ($1.affectedStorage ?? 0) },
            healthyItems:   healthy,
            totalAffectedStorage: totalStorage,
            reclaimableStorage:   reclaimable,
            categoryHealth:       catHealth
        )
    }

    static let empty = DiagnosticSummary(
        criticalIssues: [], warningIssues: [], healthyItems: [],
        totalAffectedStorage: 0, reclaimableStorage: 0, categoryHealth: [:]
    )
}
