import Foundation

struct DiagnosticIssue: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let severity: EnvironmentSeverity
    let affectedStorage: Int64?
    let recommendation: String
    let category: DiagnosticCategory
    let source: String            // feature name, e.g. "DerivedData", "Metro Cache"

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: EnvironmentSeverity,
        affectedStorage: Int64? = nil,
        recommendation: String,
        category: DiagnosticCategory,
        source: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.affectedStorage = affectedStorage
        self.recommendation = recommendation
        self.category = category
        self.source = source
    }
}
