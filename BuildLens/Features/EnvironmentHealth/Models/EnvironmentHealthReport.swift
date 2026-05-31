import Foundation

struct EnvironmentHealthReport: Sendable {
    let overallScore: Int           // 0-100 weighted average of section scores
    let status: EnvironmentSeverity
    let generatedAt: Date
    let sections: [EnvironmentHealthSection]
    let recommendations: [String]   // ordered by priority, pre-deduplicated

    // Computed aggregates
    var issueCount: Int { allIssues.count }

    var reclaimableStorage: Int64 {
        allIssues.compactMap(\.affectedStorage).reduce(0, +)
    }

    var allIssues: [EnvironmentIssue] {
        sections
            .flatMap(\.issues)
            .sorted { $0.severity > $1.severity }
    }

    var criticalIssues: [EnvironmentIssue] {
        allIssues.filter { $0.severity == .critical }
    }

    var warningIssues: [EnvironmentIssue] {
        allIssues.filter { $0.severity == .warning }
    }

    // True when every section scanned without anomalies
    var isClean: Bool { issueCount == 0 }
}
