import Foundation

struct ArchiveIssue: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let severity: EnvironmentSeverity
    let affectedStorage: Int64
    let recommendation: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: EnvironmentSeverity,
        affectedStorage: Int64 = 0,
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
