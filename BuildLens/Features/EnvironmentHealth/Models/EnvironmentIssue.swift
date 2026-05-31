import Foundation

struct EnvironmentIssue: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let severity: EnvironmentSeverity
    let recommendation: String
    let affectedStorage: Int64?  // nil when not storage-related
    let category: EnvironmentHealthCategory

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: EnvironmentSeverity,
        recommendation: String,
        affectedStorage: Int64? = nil,
        category: EnvironmentHealthCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.recommendation = recommendation
        self.affectedStorage = affectedStorage
        self.category = category
    }
}
