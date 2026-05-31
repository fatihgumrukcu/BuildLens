import Foundation

struct EnvironmentHealthSection: Identifiable, Sendable {
    var id: EnvironmentHealthCategory { category }

    let category: EnvironmentHealthCategory
    let score: Int          // 0-100; deterministic, see HealthScoring
    let issues: [EnvironmentIssue]
    let summary: String     // one-line human description of this section's state
    let severity: EnvironmentSeverity

    // Convenience
    var hasIssues: Bool { !issues.isEmpty }
    var criticalIssues: [EnvironmentIssue] { issues.filter { $0.severity == .critical } }
    var warningIssues: [EnvironmentIssue]  { issues.filter { $0.severity == .warning  } }
}
