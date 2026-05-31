import Foundation

struct HealthSnapshot: Codable, Identifiable, Sendable {
    let id: UUID
    let score: Int
    let status: EnvironmentSeverity
    let date: Date

    init(id: UUID = UUID(), score: Int, status: EnvironmentSeverity, date: Date = Date()) {
        self.id = id
        self.score = score
        self.status = status
        self.date = date
    }
}
