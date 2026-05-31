import Foundation

struct BuildToolIssue: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let severity: EnvironmentSeverity
    let recommendation: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: EnvironmentSeverity,
        recommendation: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.recommendation = recommendation
    }
}
