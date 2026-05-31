import Foundation

// A single detected anomaly within a workspace project.
// Reuses EnvironmentSeverity so the health model is consistent across the app.
struct WorkspaceIssue: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let severity: EnvironmentSeverity
    let affectedStorage: Int64?
    let recommendation: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: EnvironmentSeverity,
        affectedStorage: Int64? = nil,
        recommendation: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.affectedStorage = affectedStorage
        self.recommendation = recommendation
    }
}
